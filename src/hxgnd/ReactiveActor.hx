package hxgnd;

import extype.Unit;
import hxgnd.Delegate;

class ReactiveActor<TState, TMessage> {
    var state: TState;
    var middleware: ReactiveActorMiddleware<TState, TMessage>;
    var equaler: TState -> TState -> Bool;
    var subscribers: Delegate<TState>;
    var abortHanlders: Delegate0;

    public function new(initState: TState, middleware: ReactiveActorMiddleware<TState, TMessage>, ?equaler: TState -> TState -> Bool) {
        this.state = initState;
        this.middleware = middleware;
        this.equaler = LangTools.getOrElse(equaler, function eq(a, b) return LangTools.eq(a, b));
        this.subscribers = new Delegate();
        this.abortHanlders = new Delegate0();
    }

    public function getState(): TState {
        return state;
    }

    public function dispatch(message: TMessage): AbortablePromise<Unit> {
        var promise = new AbortablePromise(function (fulfill, reject) {
            var completed = false;
            var context = {
                getState: getState,
                emit: function (newState: TState, hasNext = false): Void {
                    if (completed || equaler(state, newState)) return;

                    #if (js && debug)
                    state = LangTools.freeze(newState);
                    #else
                    state = newState;
                    #end

                    try {
                        subscribers.invoke(state);
                    } catch (e: Dynamic) {
                        trace(e);
                    }

                    if (!hasNext) {
                        completed = true;
                        fulfill(new Unit());
                    }
                },
                emitEnd: function (): Void {
                    if (completed) return;
                    completed = true;
                    fulfill(new Unit());
                },
                throwError: function (e: Dynamic): Void {
                    if (completed) return;
                    completed = true;
                    reject(e);
                },
                become: function (newMiddleware: ReactiveActorMiddleware<TState, TMessage>): Void {
                    middleware = newMiddleware;
                },
                dispatch: dispatch
            }
            return middleware(context, message);
        });

        var onAbort = promise.abort;
        abortHanlders.add(onAbort);
        promise.finally(abortHanlders.remove.bind(onAbort));

        return promise;
    }

    public function subscribe(onValue: TState -> Void): Void -> Void {
        subscribers.add(onValue);
        return function unsbscribe() { subscribers.remove(onValue); }
    }

    public function abort(): Void {
        abortHanlders.invoke();
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

    // function skip(count: Int): Reactable<T>;
    // function skipWhile(fn: T -> Bool): Reactable<T>;
    // function skipUntil(promise: Promise<Dynamic>): Reactable<T>;
    // function take(count: Int): Reactable<T>;
    // function takeWhile(fn: T -> Bool): Reactable<T>;
    // function takeUntil(promise: Promise<Dynamic>): Reactable<T>;

    // public function reduce(fn: TState -> TState -> TState): Reactable<TState> {
    //     return ReactableHelper.reduce(this, fn);
    // }

    // public function fold<U>(init: U, fn: U -> TState -> U): Reactable<U> {
    //     return ReactableHelper.fold(this, init, fn);
    // }

    // public function throttle(msec: Int): Reactable<TState> {
    //     return ReactableHelper.throttle(this, msec);
    // }

    // public function debounce(msec: Int): Reactable<TState> {
    //     return ReactableHelper.debounce(this, msec);
    // }

    // function delay(msec: Int): Reactable<T>;
    // function timeout(msec: Int): Reactable<T>;
}

typedef ReactiveActorMiddleware<TState, TMessage> = ReactiveActorContext<TState, TMessage> -> TMessage -> (Void -> Void);

typedef ReactiveActorContext<TState, TMessage> = {
    function getState(): TState;
    function emit(newState: TState, ?hasNext: Bool): Void;
    function emitEnd(): Void;
    function throwError(error: Dynamic): Void;
    function become(middleware: ReactiveActorMiddleware<TState, TMessage>): Void;
    function dispatch(message: TMessage): AbortablePromise<Unit>;
}
