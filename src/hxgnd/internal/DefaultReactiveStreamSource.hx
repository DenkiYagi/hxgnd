package hxgnd.internal;

import hxgnd.Delegate;
import hxgnd.Dispatcher;
import hxgnd.Maybe;
import hxgnd.AbortedError;
import hxgnd.StreamClosedError;

class DefaultReactiveStreamSource<T> {
    var middleware: (T -> Void) -> (Void -> Void) -> (Dynamic -> Void) -> (Void -> Void);
    var isStarted: Bool;
    var isClosed: Bool;
    var thrownError: Maybe<Dynamic>;
    var valueSubscribers: Delegate<T>;
    var endSubscribers: Delegate0;
    var errorSubscribers: Delegate<Dynamic>;
    var abortCallback: Void -> Void;

    public function new(middleware: (T -> Void) -> (Void -> Void) -> (Dynamic -> Void) -> (Void -> Void)) {
        this.middleware = middleware;

        isStarted = false;
        isClosed = false;
        thrownError = Maybe.empty();

        valueSubscribers = new Delegate();
        endSubscribers = new Delegate0();
        errorSubscribers = new Delegate();
    }

    public function start(): Void {
        if (isStarted) return;

        isStarted = true;
        Dispatcher.dispatch(function start_middleware() {
            try {
                abortCallback = middleware(emitValue, emitEnd, emitError);
            } catch (e: Dynamic) {
                emitError(e);
            }
        });
    }

    public function subscribe(fn: T -> Void): Void -> Void {
        return if (isClosed) {
            function unsubscribe_empty() {};
        } else {
            valueSubscribers.add(fn);
            valueSubscribers.remove.bind(fn);
        }
    }

    public function subscribeEnd(fn: Void -> Void): Void -> Void {
        return if (isClosed && thrownError.isEmpty()) {
            Dispatcher.dispatch(fn);
            function unsubscribe_empty() {};
        } else {
            endSubscribers.add(fn);
            endSubscribers.remove.bind(fn);
        }
    }

    public function subscribeError(fn: Dynamic -> Void): Void -> Void {
        return if (isClosed && thrownError.nonEmpty()) {
            Dispatcher.dispatch(fn.bind(thrownError.get()));
            function unsubscribe_empty() {};
        } else {
            errorSubscribers.add(fn);
            errorSubscribers.remove.bind(fn);
        }
    }

    public function abort(): Void {
        if (isClosed) return;
        abortCallback();
        emitError(new AbortedError());
    }

    function emitValue(value: T): Void {
        if (isClosed) throw new StreamClosedError();
        valueSubscribers.invoke(value);
    }

    function emitEnd(): Void {
        if (isClosed) throw new StreamClosedError();
        isClosed = true;
        endSubscribers.invoke();
        removeAllsubscribers();
    }

    function emitError(error: Dynamic): Void {
        if (isClosed) throw new StreamClosedError();
        isClosed = true;
        thrownError = Maybe.of(error);
        errorSubscribers.invoke(error);
        removeAllsubscribers();
    }

    inline function removeAllsubscribers(): Void {
        valueSubscribers.removeAll();
        endSubscribers.removeAll();
        errorSubscribers.removeAll();
    }
}
