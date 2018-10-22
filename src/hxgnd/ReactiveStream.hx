package hxgnd;

import hxgnd.Delegate;
import hxgnd.Result;
using hxgnd.LangTools;

class ReactiveStream<T> {
    var receiver: Receiver<T>;
    var valueSubscribers: Delegate<T>;
    var endSubscribers: Delegate0;
    var errorSubscribers: Delegate<Dynamic>;
    var childClosers: Delegate0;
    var wrapped: Bool;

    /**
     * Get the state of this stream.
     */
    public var state(get, never): ReactiveStreamState;

    function new() {
        valueSubscribers = new Delegate();
        endSubscribers = new Delegate0();
        errorSubscribers = new Delegate();
        childClosers = new Delegate0();
        wrapped = false;
    }

    /**
    * Create a stream from middleware.
    * @param middleware
    * @return ReactiveStream<T>
     */
    public static function create<T>(middleware: ReactableStreamMiddleware<T>): ReactiveStream<T> {
        var stream = new ReactiveStream();
        stream.becomeInit(middleware);
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

    function becomeInit(middleware: ReactableStreamMiddleware<T>): Void {
        inline function startPreparing(): Void {
            becomePreparing(function (callback) {
                function prepare() {
                    if (Type.enumEq(receiver.state, Ended)) return;
                    try {
                        var controller = middleware(createContext());
                        callback(Success(controller));
                    } catch (e: Dynamic) {
                        callback(Failure(e));
                    }
                }
                Dispatcher.dispatch(prepare);
            });
        }

        receiver = {
            #if debug internalName: "init", #end
            state: Init,
            subscribe: function (fn) {
                valueSubscribers.add(fn);
                startPreparing();
            },
            subscribeEnd: function (fn) {
                endSubscribers.add(fn);
                startPreparing();
            },
            subscribeError: function (fn) {
                errorSubscribers.add(fn);
                startPreparing();
            },
            close: end.bind()
        }
    }

    function becomePreparing(prepare: (Result<ReactableStreamMiddlewareController> -> Void) -> Void): Void {
        receiver = {
            #if debug internalName: "preparing", #end
            state: Running,
            subscribe: valueSubscribers.add,
            unsubscribe: valueSubscribers.remove,
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: errorSubscribers.add,
            unsubscribeError: errorSubscribers.remove,
            onEmit: emit,
            onEmitEnd: end.bind(),
            onThrowError: throwError,
            close: end.bind()
        }

        prepare(function (result) {
            switch (result) {
                case Success(controller):
                    if (hasNoSubscribers()) {
                        becomeSuspended(controller);
                    } else {
                        becomeRunning(controller);
                        controller.attach();
                    }
                case Failure(error):
                    throwError(error);
            }
        });
    }

    function becomeRunning(controller: ReactableStreamMiddlewareController): Void {
        inline function trySuspend(): Void {
            if (hasNoSubscribers()) {
                becomeSuspended(controller);
                dispatch(controller.detach);
            }
        }

        receiver = {
            #if debug internalName: "running", #end
            state: Running,
            subscribe: valueSubscribers.add,
            unsubscribe: function (fn) {
                valueSubscribers.remove(fn);
                trySuspend();
            },
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: function (fn) {
                endSubscribers.remove(fn);
                trySuspend();
            },
            subscribeError: errorSubscribers.add,
            unsubscribeError: function (fn) {
                errorSubscribers.remove(fn);
                trySuspend();
            },
            onEmit: emit,
            onEmitEnd: end.bind(),
            onThrowError: throwError,
            close: end.bind(controller.close)
        }
    }

    function becomeSuspended(controller: ReactableStreamMiddlewareController): Void {
        inline function resume(): Void {
            becomeRunning(controller);
            dispatch(controller.attach);
        }

        receiver = {
            #if debug internalName: "suspended", #end
            state: Suspended,
            subscribe: function (fn) {
                valueSubscribers.add(fn);
                resume();
            },
            unsubscribe: valueSubscribers.remove,
            subscribeEnd: function (fn) {
                endSubscribers.add(fn);
                resume();
            },
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: function (fn) {
                errorSubscribers.add(fn);
                resume();
            },
            unsubscribeError: errorSubscribers.remove,
            onEmitEnd: end.bind(),
            onThrowError: throwError,
            close: end.bind(controller.close)
        }
    }

    function becomeEnded(): Void {
        receiver = {
            #if debug internalName: "ended", #end
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
            #if debug internalName: "failed", #end
            state: Failed(error),
            subscribeError: function (fn: Dynamic -> Void) {
                fn(error);
            },
        }
    }

    function becomeRecovering(error: Dynamic, recoverFn: Dynamic -> ReactiveStream<T>): Void {
        receiver = {
            #if debug internalName: "recovering", #end
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
            #if debug internalName: "never", #end
            state: Never,
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: endSubscribers.remove,
            catchError: function (fn: Dynamic -> ReactiveStream<T>) {
                var nextStream = new ReactiveStream();
                nextStream.becomeNever();
                subscribeEnd(nextStream.end.bind());
                return nextStream;
            },
            close: end.bind()
        }
    }

    inline function emit(value: T): Void {
        // TODO delegate側にcopyとdispatchを任せたい
        if (valueSubscribers.nonEmpty()) {
            valueSubscribers.copy().invoke(value);
        }
    }

    function end(?closeMiddleware: Void -> Void): Void {
        if (closeMiddleware.nonNull()) {
            try {
                closeMiddleware();
            } catch (e: Dynamic) {
                throwError(e);
                return;
            }
        }

        becomeEnded();
        if (endSubscribers.nonEmpty()) {
            endSubscribers.copy().invoke();
        }
        childClosers.invoke();
        release();
    }

    function throwError(error: Dynamic): Void {
        trace("throwError");
        trace(errorSubscribers);
        becomeFailed(error);
        if (errorSubscribers.nonEmpty()) {
            errorSubscribers.copy().invoke(error);
        }
        release();
    }

    function recover(error: Dynamic, fn: Dynamic -> ReactiveStream<T>): Void {
        try {
            var internal = fn(error);
            internal.wrapped = true;

            trace("recover");
            trace(internal.receiver.internalName);
            switch (internal.state) {
                case Ended:
                    valueSubscribers.removeAll();
                    errorSubscribers.removeAll();
                    end();
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
                        trace("attach recover");
                        detach.add(internal.subscribe(emit));
                        detach.add(internal.subscribeEnd(end.bind()));
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

    inline function dispatch(fn: Void -> Void): Void {
        if (wrapped) {
            fn();
        } else {
            Dispatcher.dispatch(fn);
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

    inline function release(): Void {
        valueSubscribers.removeAll();
        endSubscribers.removeAll();
        errorSubscribers.removeAll();
        childClosers.removeAll();
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
            trace("catchError");
            var child = ReactiveStream.create(function (ctx) {
                trace("catchError middleware");
                var detach = new Delegate0();
                function attach() {
                    trace("attach : catchError");
                    detach.add(subscribe(ctx.emit));
                    detach.add(subscribeEnd(ctx.emitEnd));
                    detach.add(subscribeError(function rescue(error) {
                        trace("rescue : catchError");
                        detach.removeAll();
                        ctx.stream.recover(error, fn);
                    }));
                    trace(this.errorSubscribers);
                }
                return {
                    attach: attach,
                    detach: detach.invoke,
                    close: detach.invoke,
                }
            });
            childClosers.add(child.close);
            return child;
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
    #if debug var internalName: String; #end
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
