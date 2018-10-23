package hxgnd;

import hxgnd.Delegate;
import hxgnd.Result;
using hxgnd.LangTools;

class ReactiveStream<T> {
    var receiver: Receiver<T>;
    var dataSubscribers: Delegate<T>;
    var endSubscribers: Delegate0;
    var errorSubscribers: Delegate<Dynamic>;
    var childClosers: Delegate0;
    var wrapped: Bool;

    /**
     * Get the state of this stream.
     */
    public var state(get, never): ReactiveStreamState;

    function new() {
        dataSubscribers = new Delegate();
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
        function startPreparing(): Void {
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
            attach: startPreparing,
            subscribe: dataSubscribers.add,
            subscribeEnd: endSubscribers.add,
            subscribeError: errorSubscribers.add,
            close: end.bind()
        }
    }

    function becomePreparing(prepare: (Result<ReactableStreamMiddlewareController> -> Void) -> Void): Void {
        receiver = {
            #if debug internalName: "preparing", #end
            state: Running,
            subscribe: dataSubscribers.add,
            unsubscribe: dataSubscribers.remove,
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
        function suspend(): Void {
            becomeSuspended(controller);
            dispatch(controller.detach);
        }

        receiver = {
            #if debug internalName: "running", #end
            state: Running,
            subscribe: dataSubscribers.add,
            unsubscribe: dataSubscribers.remove,
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: errorSubscribers.add,
            unsubscribeError: errorSubscribers.remove,
            detach: suspend,
            onEmit: emit,
            onEmitEnd: end.bind(),
            onThrowError: throwError,
            close: end.bind(controller.close)
        }
    }

    function becomeSuspended(controller: ReactableStreamMiddlewareController): Void {
        function resume(): Void {
            becomeRunning(controller);
            dispatch(controller.attach);
        }

        receiver = {
            #if debug internalName: "suspended", #end
            state: Suspended,
            subscribe: dataSubscribers.add,
            unsubscribe: dataSubscribers.remove,
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: errorSubscribers.add,
            unsubscribeError: errorSubscribers.remove,
            attach: resume,
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
            subscribe: dataSubscribers.add,
            unsubscribe: dataSubscribers.remove,
            subscribeEnd: endSubscribers.add,
            unsubscribeEnd: endSubscribers.remove,
            subscribeError: errorSubscribers.add,
            unsubscribeError: errorSubscribers.remove,
            attach: recover.bind(error, recoverFn),
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
        if (dataSubscribers.nonEmpty()) {
            dataSubscribers.copy().invoke(value);
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

            switch (internal.state) {
                case Ended:
                    dataSubscribers.removeAll();
                    errorSubscribers.removeAll();
                    end();
                case Failed(e):
                    dataSubscribers.removeAll();
                    endSubscribers.removeAll();
                    throwError(e);
                case Never:
                    dataSubscribers.removeAll();
                    errorSubscribers.removeAll();
                    becomeNever();
                case _:
                    var detach = new Delegate0();
                    function attach() {
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
        return dataSubscribers.nonEmpty()
            && endSubscribers.nonEmpty()
            && errorSubscribers.nonEmpty();
    }

    inline function hasNoSubscribers(): Bool {
        return dataSubscribers.isEmpty()
            && endSubscribers.isEmpty()
            && errorSubscribers.isEmpty();
    }

    inline function release(): Void {
        dataSubscribers.removeAll();
        endSubscribers.removeAll();
        errorSubscribers.removeAll();
        childClosers.removeAll();
    }

    function get_state(): ReactiveStreamState {
        return receiver.state;
    }

    public function subscribe(fn: T -> Void): Void -> Void {
        receiver.subscribe.callIfNotNull(fn);
        receiver.attach.callIfNotNull();
        return function unsubscribe() {
            receiver.unsubscribe.callIfNotNull(fn);
            if (receiver.detach.nonNull() && hasNoSubscribers()) {
                receiver.detach();
            }
        }
    }

    public function subscribeEnd(fn: Void -> Void): Void -> Void {
        receiver.subscribeEnd.callIfNotNull(fn);
        receiver.attach.callIfNotNull();
        return function unsubscribeEnd() {
            receiver.unsubscribeEnd.callIfNotNull(fn);
            if (receiver.detach.nonNull() && hasNoSubscribers()) {
                receiver.detach();
            }
        }
    }

    public function subscribeError(fn: Dynamic -> Void): Void -> Void {
        receiver.subscribeError.callIfNotNull(fn);
        receiver.attach.callIfNotNull();
        return function unsubscribeError() {
            receiver.unsubscribeError.callIfNotNull(fn);
            if (receiver.detach.nonNull() && hasNoSubscribers()) {
                receiver.detach();
            }
        }
    }

    public function subscribeEach(onData: Null<T -> Void>, onEnd: Null<Void -> Void>, onError: Null<Dynamic -> Void>): Void -> Void {
        if (onData.isNull() && onEnd.isNull() && onError.isNull()) {
            return function () {};
        }

        if (onData.nonNull())  receiver.subscribe(onData);
        if (onEnd.nonNull())   receiver.subscribeEnd(onEnd);
        if (onError.nonNull()) receiver.subscribeError(onError);
        receiver.attach.callIfNotNull();

        return function unsubscribe() {
            if (onData.nonNull())  receiver.unsubscribe(onData);
            if (onEnd.nonNull())   receiver.unsubscribeEnd(onEnd);
            if (onError.nonNull()) receiver.unsubscribeError(onError);
            if (receiver.detach.nonNull() && hasNoSubscribers()) {
                receiver.detach.callIfNotNull();
            }
        }
    }

    public function catchError(fn: Dynamic -> ReactiveStream<T>): ReactiveStream<T> {
        // TODO receiverで処理する
        return if (receiver.catchError.nonNull()) {
            receiver.catchError(fn);
        } else {
            var child = ReactiveStream.create(function (ctx) {
                var detach = new Delegate0();
                function attach() {
                    detach.add(subscribeEach(ctx.emit, ctx.emitEnd, ctx.stream.recover.bind(_, fn)));
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

    @:optional dynamic function attach(): Void;
    @:optional dynamic function detach(): Void;

    @:optional dynamic function onEmit(data: T): Void;
    @:optional dynamic function onEmitEnd(): Void;
    @:optional dynamic function onThrowError(error: Dynamic): Void;

    @:optional dynamic function catchError(error: Dynamic): ReactiveStream<T>;
    @:optional dynamic function close(): Void;
}
