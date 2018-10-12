package hxgnd;

import hxgnd.Delegate;
import hxgnd.Dispatcher;
using hxgnd.LangTools;

class ReactiveStream<T> {
    var processor: Processor<T>;
    var valueSubscribers: Delegate<T>;
    var endSubscribers: Delegate0;
    var errorSubscribers: Delegate<Dynamic>;

    function new() { }

    public static function create<T>(middleware: ReactableStreamMiddleware<T>): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.valueSubscribers = new Delegate();
        stream.endSubscribers = new Delegate0();
        stream.errorSubscribers = new Delegate();
        stream.becomeIdle(middleware);
        return stream;
    }

    /**
    * Create a closed empty stream.
    * @return ReactiveStream<T>
     */
    public static function empty<T>(): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.endSubscribers = new Delegate0();
        stream.becomeClosed();
        return stream;
    }

    /**
    * Create a unclosed empty stream.
    * @return ReactiveStream<T>
     */
    public static function never<T>(): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.endSubscribers = new Delegate0();
        stream.becomeNever();
        return stream;
    }

    /**
    * Create a failed stream.
    * @param error an error infomation
    * @return ReactiveStream<T>
     */
    public static function throwError<T>(error: Dynamic): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.becomeFailed(error);
        return stream;
    }

    function becomeIdle(middleware: ReactableStreamMiddleware<T>): Void {
        var init = onInit.bind(middleware);
        processor = {
            subscribe: function (fn) {
                valueSubscribers.add(fn);
                init();
            },
            subscribeEnd: function (fn) {
                endSubscribers.add(fn);
                init();
            },
            subscribeError: function (fn) {
                errorSubscribers.add(fn);
                init();
            },
            close: onEmitEnd
        }
    }

    function becomeInitializing(): Void {
        processor = {
            onInited: onInited,
            onInitFailed: onInitFailed,
            subscribe: valueSubscribers.add,
            unsubscribe: valueSubscribers.remove,
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: errorSubscribers.add,
            unsubscribeError: errorSubscribers.remove,
            onEmit: onEmit,
            onEmitEnd: onEmitEnd,
            onthrowError: onThrowError,
            close: onEmitEnd
        }
    }

    function becomeRunning(controller: ReactableStreamMiddlewareController): Void {
        var pause = onPause.bind(controller);
        processor = {
            subscribe: valueSubscribers.add,
            unsubscribe: function (fn) {
                valueSubscribers.remove(fn);
                if (hasNoSubscribers()) pause();
            },

            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: function (fn) {
                endSubscribers.remove(fn);
                if (hasNoSubscribers()) pause();
            },

            subscribeError: errorSubscribers.add,
            unsubscribeError: function (fn) {
                errorSubscribers.remove(fn);
                if (hasNoSubscribers()) pause();
            },

            onEmit: onEmit,
            onEmitEnd: onEmitEnd,
            onthrowError: onThrowError,
            close: onClose.bind(controller)
        }
    }

    function becomePaused(controller: ReactableStreamMiddlewareController): Void {
        var resume = onResume.bind(controller);
        processor = {
            subscribe: function (fn) {
                resume();
                valueSubscribers.add(fn);
            },
            unsubscribe: valueSubscribers.remove,

            subscribeEnd: function (fn) {
                resume();
                endSubscribers.add(fn);
            },
            unsubscribeEnd: endSubscribers.remove,

            subscribeError: function (fn) {
                resume();
                errorSubscribers.add(fn);
            },
            unsubscribeError: errorSubscribers.remove,

            onEmitEnd: onEmitEnd,
            onthrowError: onThrowError,
            close: onClose.bind(controller)
        }
    }

    function becomeClosed(): Void {
        processor = {
            subscribeEnd: Dispatcher.dispatch
        }
    }

    function becomeFailed(error: Dynamic): Void {
        processor = {
            subscribeError: function (fn: Dynamic -> Void) {
                Dispatcher.dispatch.bind(fn.bind(error));
            }
        }
    }

    function becomeNever(): Void {
        processor = {
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: endSubscribers.remove,
            close: onEmitEnd
        }
    }

    function onInit(middleware: ReactableStreamMiddleware<T>) {
        becomeInitializing();
        Dispatcher.dispatch(function init() {
            try {
                var controller = middleware({
                    emit: function (value) {
                        processor.onEmit.callIfNotNull(value);
                    },
                    emitEnd: function () {
                        processor.onEmitEnd.callIfNotNull();
                    },
                    throwError: function (error) {
                        processor.onthrowError.callIfNotNull(error);
                    }
                });
                processor.onInited.callIfNotNull(controller);
            } catch (e: Dynamic) {
                processor.onInitFailed.callIfNotNull(e);
            }
        });
    }

    function onInited(controller: ReactableStreamMiddlewareController): Void {
        if (hasNoSubscribers()) {
            becomePaused(controller);
        } else {
            becomeRunning(controller);
            controller.attach();
        }
    }

    function onInitFailed(error: Dynamic): Void {
        becomeFailed(error);
        errorSubscribers.invoke(error);
        removeAllsubscribers();
    }

    function onEmit(value: T): Void {
        Dispatcher.dispatch(function () {
            valueSubscribers.invoke(value);
        });
    }

    function onEmitEnd(): Void {
        becomeClosed();
        if (endSubscribers.nonEmpty()) {
            var delegate = endSubscribers.copy();
            Dispatcher.dispatch(function () {
                delegate.invoke();
            });
        }
        removeAllsubscribers();
    }

    function onThrowError(error: Dynamic): Void {
        if (errorSubscribers.nonEmpty()) {
            var delegate = errorSubscribers.copy();
            Dispatcher.dispatch(function () {
                delegate.invoke(error);
            });
        }
        removeAllsubscribers();
    }

    function onPause(controller: ReactableStreamMiddlewareController): Void {
        becomePaused(controller);
        controller.detach();
    }

    function onResume(controller: ReactableStreamMiddlewareController): Void {
        becomeRunning(controller);
        controller.attach();
    }

    function onClose(controller: ReactableStreamMiddlewareController): Void {
        try {
            controller.close();
            onEmitEnd();
        } catch (error: Dynamic) {
            onThrowError(error);
        }
    }

    inline function hasNoSubscribers(): Bool {
        return valueSubscribers.isEmpty()
            && endSubscribers.isEmpty()
            && errorSubscribers.isEmpty();
    }

    inline function removeAllsubscribers(): Void {
        valueSubscribers.removeAll();
        endSubscribers.removeAll();
        errorSubscribers.removeAll();
    }

    public function subscribe(fn: T -> Void): Void -> Void {
        processor.subscribe.callIfNotNull(fn);
        return function unsubscribe() {
            processor.unsubscribe.callIfNotNull(fn);
        }
    }

    public function subscribeEnd(fn: Void -> Void): Void -> Void {
        processor.subscribeEnd.callIfNotNull(fn);
        return function unsubscribeEnd() {
            processor.unsubscribeEnd.callIfNotNull(fn);
        }
    }

    public function subscribeError(fn: Dynamic -> Void): Void -> Void {
        processor.subscribeError.callIfNotNull(fn);
        return function unsubscribeError() {
            processor.unsubscribeError.callIfNotNull(fn);
        }
    }

    public function catchError(fn: Dynamic -> ReactiveStream<T>): ReactiveStream<T> {
        var wrapper = new ReactiveStream();
        wrapper.valueSubscribers = new Delegate();
        wrapper.endSubscribers = new Delegate0();
        wrapper.errorSubscribers = new Delegate();

        var detacher = new Delegate0();
        function attach() {
            detacher.add(subscribe(wrapper.onEmit));
            detacher.add(subscribeEnd(wrapper.onEmitEnd));
            detacher.add(subscribeError(function rescue(error) {
                detacher.removeAll();

                var nextStream = fn(error);
                detacher.add(nextStream.subscribe(wrapper.onEmit));
                detacher.add(nextStream.subscribeEnd(wrapper.onEmitEnd));
                detacher.add(nextStream.subscribeError(wrapper.onThrowError));
            }));
        }

        wrapper.becomeRunning({
            attach: attach,
            detach: detacher.invoke,
            close: detacher.invoke
        });

        return wrapper;
    }

    public function finally(fn: Void -> Void): Void {
        processor.subscribeEnd(fn);
        processor.subscribeError(function (_) fn());
    }

    public function close(): Void {
        processor.close.callIfNotNull();
    }

    // public function pull(): Promise<T> {
    //     return new SyncPromise(function (fulfill, reject) {
    //         var unsubscribes: Array<Void -> Void> = [];
    //         unsubscribes.push(source.subscribe(function next_onvalue(x) {
    //             for (f in unsubscribes) f();
    //             fulfill(x);
    //         }));
    //         unsubscribes.push(source.subscribeEnd(function next_onend() {
    //             for (f in unsubscribes) f();
    //             reject(new StreamClosedError());
    //         }));
    //         unsubscribes.push(source.subscribeError(function next_onerror(e) {
    //             for (f in unsubscribes) f();
    //             reject(e);
    //         }));
    //     });
    // }


    // public function forEach(fn: T -> Void): Void {
    //     subscribe(fn);
    // }

    // public function map<U>(fn: T -> U): Reactable<U> {
    //     return ReactableHelper.map(this, fn);
    // }

    // public function flatMap<U>(fn: T -> Reactable<U>): Reactable<U> {
    //     return ReactableHelper.flatMap(this, fn);
    // }

    // public function filter(fn: T -> Bool): Reactable<T> {
    //     return ReactableHelper.filter(this, fn);
    // }

    // public function reduce(fn: T -> T -> T): Reactable<T> {
    //     return ReactableHelper.reduce(this, fn);
    // }

    // public function fold<U>(init: U, fn: U -> T -> U): Reactable<U> {
    //     return ReactableHelper.fold(this, init, fn);
    // }

    // public function skip(count: Int): Reactable<T> {
    //     return ReactableHelper.skip(this, count);
    // }

    // public function throttle(msec: Int): Reactable<T> {
    //     return ReactableHelper.throttle(this, msec);
    // }

    // public function debounce(msec: Int): Reactable<T> {
    //     return ReactableHelper.debounce(this, msec);
    // }

}

typedef ReactableStreamMiddleware<T> = ReactableStreamContext<T> -> ReactableStreamMiddlewareController;

typedef ReactableStreamContext<T> = {
    function emit(value: T): Void;
    function emitEnd(): Void;
    function throwError(error: Dynamic): Void;
}

typedef ReactableStreamMiddlewareController = {
    function attach(): Void;
    function detach(): Void;
    function close(): Void;
}

private typedef Processor<T> = {
    @:optional var onInited: ReactableStreamMiddlewareController -> Void;
    @:optional var onInitFailed: Dynamic -> Void;

    @:optional var subscribe: (T -> Void) -> Void;
    @:optional var unsubscribe: (T -> Void) -> Void;

    @:optional var subscribeEnd: (Void -> Void) -> Void;
    @:optional var unsubscribeEnd: (Void -> Void) -> Void;

    @:optional var subscribeError: (Dynamic -> Void) -> Void;
    @:optional var unsubscribeError: (Dynamic -> Void) -> Void;

    @:optional var onEmit: T -> Void;
    @:optional var onEmitEnd: Void -> Void;
    @:optional var onthrowError: Dynamic -> Void;

    @:optional var close: Void -> Void;
}
