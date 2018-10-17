package hxgnd;

import hxgnd.Delegate;
using hxgnd.LangTools;

class ReactiveStream<T> {
    // TODO add Middleware controller tests : attach detach close
    var receiver: Receiver<T>;
    var valueSubscribers: Delegate<T>;
    var endSubscribers: Delegate0;
    var errorSubscribers: Delegate<Dynamic>;

    /**
     * Get the state of this stream.
     */
    public var state(get, never): ReactiveStreamState;

    function new() {
        valueSubscribers = new Delegate();
        endSubscribers = new Delegate0();
        errorSubscribers = new Delegate();
    }

    /**
    * Create a stream from middleware.
    * @param middleware
    * @return ReactiveStream<T>
     */
    public static function create<T>(middleware: ReactableStreamMiddleware<T>): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.becomeInit(middleware, true);
        return stream;
    }

    /**
    * Create an empty stream that is closed.
    * @return ReactiveStream<T>
     */
    public static function empty<T>(): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.becomeEnded();
        return stream;
    }

    /**
    * Create a stream that is failed.
    * @param error The error information
    * @return ReactiveStream<T>
     */
    public static function fail<T>(error: Dynamic): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.becomeFailed(error);
        return stream;
    }

    /**
    * Create an empty stram that is never closed.
    * @return ReactiveStream<T>
     */
    public static function never<T>(): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.becomeNever();
        return stream;
    }

    inline function createContext(): ReactableStreamContext<T> {
        return {
            stream: this,
            emit: function (value) {
                receiver.onEmit.callIfNotNull(value);
            },
            emitEnd: function () {
                receiver.onEmitEnd.callIfNotNull();
            },
            throwError: function (error) {
                receiver.onThrowError.callIfNotNull(error);
            }
        };
    }

    function becomeInit(middleware: ReactableStreamMiddleware<T>, async: Bool): Void {
        function startPreparing(middleware: ReactableStreamMiddleware<T>): Void {
            var promise = if (async) {
                new Promise(function (f, _) f(middleware(createContext())));
            } else {
                new SyncPromise(function (f, _) f(middleware(createContext())));
            }
            becomePreparing(promise);
        }

        receiver = {
            state: Init,
            subscribe: function (fn) {
                valueSubscribers.add(fn);
                startPreparing(middleware);
            },
            subscribeEnd: function (fn) {
                endSubscribers.add(fn);
                startPreparing(middleware);
            },
            subscribeError: function (fn) {
                errorSubscribers.add(fn);
                startPreparing(middleware);
            },
            close: emitEnd
        }
    }

    function becomePreparing(promise: Promise<ReactableStreamMiddlewareController>): Void {
        promise.then(function (controller) {
            if (hasNoSubscribers()) {
                becomeSuspended(controller);
            } else {
                becomeRunning(controller);
                controller.attach();
            }
        }, function (error) {
            throwError(error);
        });

        receiver = {
            state: Running,
            subscribe: valueSubscribers.add,
            unsubscribe: valueSubscribers.remove,
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: errorSubscribers.add,
            unsubscribeError: errorSubscribers.remove,
            onEmit: emit,
            onEmitEnd: emitEnd,
            onThrowError: throwError,
            close: emitEnd
        }
    }

    function becomeRunning(controller: ReactableStreamMiddlewareController): Void {
        receiver = {
            state: Running,
            subscribe: valueSubscribers.add,
            unsubscribe: function (fn) {
                valueSubscribers.remove(fn);
                trySuspend(controller);
            },
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: function (fn) {
                endSubscribers.remove(fn);
                trySuspend(controller);
            },
            subscribeError: errorSubscribers.add,
            unsubscribeError: function (fn) {
                errorSubscribers.remove(fn);
                trySuspend(controller);
            },
            onEmit: emit,
            onEmitEnd: emitEnd,
            onThrowError: throwError,
            close: onClose.bind(controller)
        }
    }

    function becomeSuspended(controller: ReactableStreamMiddlewareController): Void {
        receiver = {
            state: Suspended,
            subscribe: function (fn) {
                valueSubscribers.add(fn);
                resume(controller);
            },
            unsubscribe: valueSubscribers.remove,
            subscribeEnd: function (fn) {
                endSubscribers.add(fn);
                resume(controller);
            },
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: function (fn) {
                errorSubscribers.add(fn);
                resume(controller);
            },
            unsubscribeError: errorSubscribers.remove,
            onEmitEnd: emitEnd,
            onThrowError: throwError,
            close: onClose.bind(controller)
        }
    }

    function becomeEnded(): Void {
        receiver = {
            state: Ended,
            subscribeEnd: function (fn: Void -> Void) {
                fn();
            },
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
                fn(error);
            },
            catchError: function (fn: Dynamic -> ReactiveStream<T>) {
                var nextStream = new ReactiveStream();
                nextStream.becomeRecovering(error, fn);
                return nextStream;
            },
        }
    }

    function becomeRecovering(error: Dynamic, recoverFn: Dynamic -> ReactiveStream<T>): Void {
        receiver = {
            state: Init,
            subscribe: function (fn) {
                valueSubscribers.add(fn);
                recover(error, recoverFn);
            },
            unsubscribe: valueSubscribers.remove,
            subscribeEnd: function (fn) {
                endSubscribers.add(fn);
                recover(error, recoverFn);
            },
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: function (fn) {
                errorSubscribers.add(fn);
                recover(error, recoverFn);
            },
            unsubscribeError: errorSubscribers.remove,
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
                subscribeEnd(nextStream.emitEnd);
                return nextStream;
            },
            close: emitEnd
        }
    }

    function emit(value: T): Void {
        // TODO delegate側にcopyとdispatchを任せたい
        if (valueSubscribers.nonEmpty()) {
            var delegate = valueSubscribers.copy();
            delegate.invoke(value);
        }
    }

    function emitEnd(): Void {
        becomeEnded();
        if (endSubscribers.nonEmpty()) {
            var delegate = endSubscribers.copy();
            delegate.invoke();
        }
        removeAllsubscribers();
    }

    function throwError(error: Dynamic): Void {
        becomeFailed(error);
        if (errorSubscribers.nonEmpty()) {
            var delegate = errorSubscribers.copy();
            delegate.invoke(error);
        }
        removeAllsubscribers();
    }

    function trySuspend(controller: ReactableStreamMiddlewareController): Void {
        if (hasNoSubscribers()) {
            controller.detach();
            becomeSuspended(controller);
        }
    }

    function resume(controller: ReactableStreamMiddlewareController): Void {
        becomeRunning(controller);
        controller.attach();
    }

    function recover(error: Dynamic, fn: Dynamic -> ReactiveStream<T>): Void {
        try {
            var internal = fn(error);
            switch (internal.state) {
                case Ended:
                    valueSubscribers.removeAll();
                    errorSubscribers.removeAll();
                    emitEnd();
                case Failed(e):
                    valueSubscribers.removeAll();
                    endSubscribers.removeAll();
                    throwError(e);
                case Never:
                    valueSubscribers.removeAll();
                    errorSubscribers.removeAll();
                    becomeNever();
                case _:
                    var detach = new Delegate0();
                    function attach() {
                        detach.add(internal.subscribe(emit));
                        detach.add(internal.subscribeEnd(emitEnd));
                        detach.add(internal.subscribeError(throwError));
                    }

                    becomeRunning({
                        attach: attach,
                        detach: detach.invoke,
                        close: function () {
                            internal.close();
                            detach.invoke();
                        }
                    });
                    attach();
            }
        } catch (e: Dynamic) {
            throwError(e);
        }
    }

    function onClose(controller: ReactableStreamMiddlewareController): Void {
        try {
            controller.close();
            emitEnd();
        } catch (error: Dynamic) {
            throwError(error);
        }
    }

    inline function hasAnySubscribers(): Bool {
        return valueSubscribers.nonEmpty()
            && endSubscribers.nonEmpty()
            && errorSubscribers.nonEmpty();
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
            var middleware = function (ctx: ReactableStreamContext<T>) {
                var detach = new Delegate0();
                var close: Null<Void -> Void> = null;
                function attach() {
                    detach.add(this.subscribe(ctx.emit));
                    detach.add(this.subscribeEnd(ctx.emitEnd));
                    detach.add(this.subscribeError(function rescue(error) {
                        detach.removeAll();
                        // bug
                        ctx.stream.recover(error, fn);
                    }));
                }

                return {
                    attach: attach,
                    detach: detach.invoke,
                    close: function () {
                        close.callIfNotNull();
                        detach.invoke();
                    },
                }
            }

            var stream = new ReactiveStream();
            stream.becomeInit(middleware, false);
            stream;

            // var nextStream = new ReactiveStream();

            // var detach = new Delegate0();
            // var close: Null<Void -> Void> = null;
            // function attach() {
            //     detach.add(subscribe(nextStream.emit));
            //     detach.add(subscribeEnd(nextStream.emitEnd));
            //     detach.add(subscribeError(function rescue(error) {
            //         detach.removeAll();
            //         nextStream.recover(error, fn);
            //     }));
            // }

            // nextStream.receiver = {
            //     state: Init,
            //     subscribe: function (fn) {
            //         attach();
            //         valueSubscribers.add(fn);
            //     },
            //     unsubscribe: valueSubscribers.remove,
            //     subscribeEnd: function (fn) {
            //         attach();
            //         endSubscribers.add(fn);
            //     },
            //     unsubscribeEnd: endSubscribers.remove,
            //     subscribeError: function (fn) {
            //         attach();
            //         errorSubscribers.add(fn);
            //     },
            //     unsubscribeError: errorSubscribers.remove,
            //     onEmitEnd: emitEnd,
            //     onThrowError: throwError,
            //     close: function () {
            //         close.callIfNotNull();
            //         detach.invoke();
            //     }
            // }
            // nextStream;
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
    var stream(default, never): ReactiveStream<T>;
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

    @:optional var subscribe: (T -> Void) -> Void;
    @:optional var unsubscribe: (T -> Void) -> Void;

    @:optional var subscribeEnd: (Void -> Void) -> Void;
    @:optional var unsubscribeEnd: (Void -> Void) -> Void;

    @:optional var subscribeError: (Dynamic -> Void) -> Void;
    @:optional var unsubscribeError: (Dynamic -> Void) -> Void;

    @:optional var onEmit: T -> Void;
    @:optional var onEmitEnd: Void -> Void;
    @:optional var onThrowError: Dynamic -> Void;

    @:optional var catchError: Dynamic -> ReactiveStream<T>;
    @:optional var close: Void -> Void;
}
