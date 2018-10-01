package hxgnd;

import hxgnd.Delegate;

class ReactiveActor<TState, TMessage> {
    var state: TState;
    var middleware: Middleware<TState, TMessage>;
    var equaler: TState -> TState -> Bool;
    var subscribers: Delegate<TState>;
    var abortSubscribers: Delegate0;

    public function new(initState: TState, middleware: Middleware<TState, TMessage>, ?equaler: TState -> TState -> Bool) {
        this.state = initState;
        this.middleware = middleware;
        this.equaler = LangTools.getOrElse(equaler, LangTools.eq);
        this.subscribers = new Delegate();
        this.abortSubscribers = new Delegate0();
    }

    public function getState(): TState {
        return state;
    }

    public function dispatch(message: TMessage): AbortablePromise<Unit> {
        var promise = new AbortablePromise(function (fulfill, reject) {
            var complated = false;
            var context = {
                emit: function (recuder: TState -> TState, hasNext = false): Void {
                    if (complated) return;

                    var newState;
                    try {
                        newState = recuder(state);
                        if (equaler(state, newState)) return;
                    } catch (e: Dynamic) {
                        reject(e);
                        return;
                    }

                    state = newState;
                    subscribers.invoke(newState);

                    if (!hasNext) {
                        complated = true;
                        fulfill(new Unit());
                    }
                },
                throwError: function (e: Dynamic): Void {
                    if (complated) return;
                    complated = true;
                    reject(e);
                }
            }
            return middleware(context, state, message);
        });

        var onAbort = promise.abort;
        abortSubscribers.add(onAbort);
        promise.finally(abortSubscribers.remove.bind(onAbort));

        return promise;
    }

    public function subscribe(onValue: TState -> Void): Void -> Void {
        subscribers.add(onValue);
        return function unsbscribe() { subscribers.remove(onValue); }
    }

    public function abort(): Void {
        abortSubscribers.invoke();
        subscribers.removeAll();
    }

    // public function map<U>(fn: TState -> U): Reactable<U> {
    //     return ReactableHelper.map(this, fn);
    // }

    // public function flatMap<U>(fn: TState -> Reactable<U>): Reactable<U> {
    //     return ReactableHelper.flatMap(this, fn);
    // }

    // public function filter(fn: TState -> Bool): Reactable<TState> {
    //     return ReactableHelper.filter(this, fn);
    // }

    // public function reduce(fn: TState -> TState -> TState): Reactable<TState> {
    //     return ReactableHelper.reduce(this, fn);
    // }

    // public function fold<U>(init: U, fn: U -> TState -> U): Reactable<U> {
    //     return ReactableHelper.fold(this, init, fn);
    // }

    // public function skip(count: Int): Reactable<TState> {
    //     return ReactableHelper.skip(this, count);
    // }

    // public function throttle(msec: Int): Reactable<TState> {
    //     return ReactableHelper.throttle(this, msec);
    // }

    // public function debounce(msec: Int): Reactable<TState> {
    //     return ReactableHelper.debounce(this, msec);
    // }
}

typedef Middleware<TState, TMessage> = Context<TState> -> TState -> TMessage -> (Void -> Void);

typedef Context<TState> = {
    function emit(reducer: TState -> TState, ?haxeNext: Bool): Void;
    function throwError(error: Dynamic): Void;
}
