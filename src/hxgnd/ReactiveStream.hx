package hxgnd;

import hxgnd.Delegate;
import hxgnd.Dispatcher;
using hxgnd.LangTools;

class ReactiveStream<T> {
    // TODO add Middleware controller tests : attach detach close
    var receiver: Receiver<T>;
    var valueSubscribers: Delegate<T>;
    var endSubscribers: Delegate0;
    var errorSubscribers: Delegate<Dynamic>;

    public var state(get, never): ReactiveStreamState;

    function new() {
        valueSubscribers = new Delegate();
        endSubscribers = new Delegate0();
        errorSubscribers = new Delegate();
    }

    /**
    * Create a stream from middleware.
    * @return ReactiveStream<T>
     */
    public static function create<T>(middleware: ReactableStreamMiddleware<T>): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.becomeInit(middleware);
        return stream;
    }

    /**
    * Create a closed empty stream.
    * @return ReactiveStream<T>
     */
    public static function empty<T>(): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.becomeEnded();
        return stream;
    }

    /**
    * Create a failed stream.
    * @param error an error infomation
    * @return ReactiveStream<T>
     */
    public static function fail<T>(error: Dynamic): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.becomeFailed(error);
        return stream;
    }

    /**
    * Create a never stream.
    * @return ReactiveStream<T>
     */
    public static function never<T>(): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.becomeNever();
        return stream;
    }

    function becomeInit(middleware: ReactableStreamMiddleware<T>): Void {
        receiver = {
            state: Init,
            subscribe: function (fn) {
                valueSubscribers.add(fn);
                onInit(middleware);
            },
            subscribeEnd: function (fn) {
                endSubscribers.add(fn);
                onInit(middleware);
            },
            subscribeError: function (fn) {
                errorSubscribers.add(fn);
                onInit(middleware);
            },
            close: onEmitEnd
        }
    }

    function becomePreparing(): Void {
        receiver = {
            state: Running,
            onPrepared: onPrepared,
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
        receiver = {
            state: Running,
            subscribe: valueSubscribers.add,
            unsubscribe: function (fn) {
                valueSubscribers.remove(fn);
                if (hasNoSubscribers()) onPause(controller);
            },
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: function (fn) {
                endSubscribers.remove(fn);
                if (hasNoSubscribers()) onPause(controller);
            },
            subscribeError: errorSubscribers.add,
            unsubscribeError: function (fn) {
                errorSubscribers.remove(fn);
                if (hasNoSubscribers()) onPause(controller);
            },
            onEmit: onEmit,
            onEmitEnd: onEmitEnd,
            onthrowError: onThrowError,
            close: onClose.bind(controller)
        }
    }

    function becomeSuspended(controller: ReactableStreamMiddlewareController): Void {
        receiver = {
            state: Suspended,
            subscribe: function (fn) {
                onResume(controller);
                valueSubscribers.add(fn);
            },
            unsubscribe: valueSubscribers.remove,
            subscribeEnd: function (fn) {
                onResume(controller);
                endSubscribers.add(fn);
            },
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: function (fn) {
                onResume(controller);
                errorSubscribers.add(fn);
            },
            unsubscribeError: errorSubscribers.remove,
            onEmitEnd: onEmitEnd,
            onthrowError: onThrowError,
            close: onClose.bind(controller)
        }
    }

    function becomeEnded(): Void {
        receiver = {
            state: Ended,
            subscribeEnd: Dispatcher.dispatch,
            catchError: function (fn: Dynamic -> ReactiveStream<T>) {
                var nextStream = new ReactiveStream();
                nextStream.becomeEnded();
                return nextStream;
            },
        }
    }

    function becomeFailed(error: Dynamic): Void {
        receiver = {
            state: Failed(error),
            subscribeError: function (fn: Dynamic -> Void) {
                Dispatcher.dispatch(fn.bind(error));
            },
            catchError: function (fn: Dynamic -> ReactiveStream<T>) {
                var nextStream = new ReactiveStream();
                nextStream.becomePreCatchError(error, fn);
                return nextStream;
            },
        }
    }

    function becomePreCatchError(error: Dynamic, catchError: Dynamic -> ReactiveStream<T>): Void {
        receiver = {
            state: Init,
            subscribe: function (fn) {
                onCatchError(error, catchError);
                valueSubscribers.add(fn);
            },
            unsubscribe: valueSubscribers.remove,
            subscribeEnd: function (fn) {
                onCatchError(error, catchError);
                endSubscribers.add(fn);
            },
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: function (fn) {
                onCatchError(error, catchError);
                errorSubscribers.add(fn);
            },
            unsubscribeError: errorSubscribers.remove,
            onEmitEnd: onEmitEnd,
            onthrowError: onThrowError,
            close: becomeEnded
        }
    }

    function becomeNever(): Void {
        receiver = {
            state: Never,
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: endSubscribers.remove,
            catchError: function (fn: Dynamic -> ReactiveStream<T>) {
                var nextStream = new ReactiveStream();
                nextStream.becomeNever();
                return nextStream;
            },
            close: onEmitEnd
        }
    }

    function onInit(middleware: ReactableStreamMiddleware<T>) {
        becomePreparing();
        Dispatcher.dispatch(function init() {
            try {
                var controller = middleware({
                    emit: function (value) {
                        receiver.onEmit.callIfNotNull(value);
                    },
                    emitEnd: function () {
                        receiver.onEmitEnd.callIfNotNull();
                    },
                    throwError: function (error) {
                        receiver.onthrowError.callIfNotNull(error);
                    }
                });
                receiver.onPrepared.callIfNotNull(controller);
            } catch (e: Dynamic) {
                receiver.onthrowError.callIfNotNull(e);
            }
        });
    }

    function onPrepared(controller: ReactableStreamMiddlewareController): Void {
        if (hasNoSubscribers()) {
            becomeSuspended(controller);
        } else {
            becomeRunning(controller);
            controller.attach();
        }
    }

    function onEmit(value: T): Void {
        // TODO delegate側にcopyとdispatchを任せたい
        if (valueSubscribers.nonEmpty()) {
            var delegate = valueSubscribers.copy();
            Dispatcher.dispatch(function () {
                delegate.invoke(value);
            });
        }
    }

    function onEmitEnd(): Void {
        becomeEnded();
        if (endSubscribers.nonEmpty()) {
            var delegate = endSubscribers.copy();
            Dispatcher.dispatch(function () {
                delegate.invoke();
            });
        }
        removeAllsubscribers();
    }

    function onThrowError(error: Dynamic): Void {
        becomeFailed(error);
        if (errorSubscribers.nonEmpty()) {
            var delegate = errorSubscribers.copy();
            Dispatcher.dispatch(function () {
                delegate.invoke(error);
            });
        }
        removeAllsubscribers();
    }

    function onPause(controller: ReactableStreamMiddlewareController): Void {
        becomeSuspended(controller);
        controller.detach();
    }

    function onResume(controller: ReactableStreamMiddlewareController): Void {
        becomeRunning(controller);
        controller.attach();
    }

    function onCatchError(error: Dynamic, fn: Dynamic -> ReactiveStream<T>): Void {
        try {
            var internal = fn(error);
            switch (internal.state) {
                case Ended: onEmitEnd();
                case Failed(e): onThrowError(e);
                case Never: becomeNever();
                case _:
                    var detach = new Delegate0();
                    function attach() {
                        detach.add(internal.subscribe(onEmit));
                        detach.add(internal.subscribeEnd(onEmitEnd));
                        detach.add(internal.subscribeError(onThrowError));
                    }
                    becomeRunning({
                        attach: attach,
                        detach: detach.invoke,
                        close: internal.close
                    });
            }
        } catch (e: Dynamic) {
            onThrowError(e);
        }
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

    function get_state(): ReactiveStreamState {
        return receiver.state;
    }

    public function subscribe(fn: T -> Void): Void -> Void {
        receiver.subscribe.callIfNotNull(fn);
        return function unsubscribe() {
            receiver.unsubscribe.callIfNotNull(fn);
        }
    }

    public function subscribeEnd(fn: Void -> Void): Void -> Void {
        receiver.subscribeEnd.callIfNotNull(fn);
        return function unsubscribeEnd() {
            receiver.unsubscribeEnd.callIfNotNull(fn);
        }
    }

    public function subscribeError(fn: Dynamic -> Void): Void -> Void {
        receiver.subscribeError.callIfNotNull(fn);
        return function unsubscribeError() {
            receiver.unsubscribeError.callIfNotNull(fn);
        }
    }

    public function catchError(fn: Dynamic -> ReactiveStream<T>): ReactiveStream<T> {
        // TODO receiverで処理する

        return if (receiver.catchError.nonNull()) {
            receiver.catchError(fn);
        } else {
            var nextStream = new ReactiveStream();

            var detacher = new Delegate0();
            var close: Null<Void -> Void> = null;
            function attach() {
                detacher.add(subscribe(nextStream.onEmit));
                detacher.add(subscribeEnd(nextStream.onEmitEnd));
                detacher.add(subscribeError(function rescue(error) {
                    detacher.removeAll();

                    var retStream;
                    try {
                        retStream = fn(error);
                    } catch (e: Dynamic) {
                        retStream = ReactiveStream.fail(e);
                    }
                    close = retStream.close;
                    detacher.add(retStream.subscribe(nextStream.onEmit));
                    detacher.add(retStream.subscribeEnd(nextStream.onEmitEnd));
                    detacher.add(retStream.subscribeError(nextStream.onThrowError));
                }));
            }

            nextStream.becomeSuspended({
                attach: attach,
                detach: detacher.invoke,
                close: function () {
                    detacher.invoke();
                    close.callIfNotNull();
                }
            });

            nextStream;
        }
    }

    public function finally(fn: Void -> Void): Void -> Void {
        var delegate = new Delegate0();
        delegate.add(subscribeEnd(fn));
        delegate.add(subscribeError(function onerror(_) fn()));
        return delegate.invoke;
    }

    public function close(): Void {
        receiver.close.callIfNotNull();
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

enum ReactiveStreamState {
    Init;
    Running;
    Suspended;
    Ended;
    Failed(error: Dynamic);
    Never;
}

private typedef Receiver<T> = {
    var state: ReactiveStreamState;

    @:optional var onPrepared: ReactableStreamMiddlewareController -> Void;

    @:optional var subscribe: (T -> Void) -> Void;
    @:optional var unsubscribe: (T -> Void) -> Void;

    @:optional var subscribeEnd: (Void -> Void) -> Void;
    @:optional var unsubscribeEnd: (Void -> Void) -> Void;

    @:optional var subscribeError: (Dynamic -> Void) -> Void;
    @:optional var unsubscribeError: (Dynamic -> Void) -> Void;

    @:optional var onEmit: T -> Void;
    @:optional var onEmitEnd: Void -> Void;
    @:optional var onthrowError: Dynamic -> Void;

    @:optional var catchError: Dynamic -> ReactiveStream<T>;
    @:optional var close: Void -> Void;
}
