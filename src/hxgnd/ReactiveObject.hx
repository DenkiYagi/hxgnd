package hxgnd;

import hxgnd.Delegate;

class ReactiveObject<TState, TMessage> {
    var state: TState;
    var middleware: TState -> TMessage -> (Progress<TState> -> Void) -> (Void -> Void);
    var subscribers: Delegate<TState>;
    var abortSubscribers: Delegate0;

    public function new(middleware: TState -> TMessage -> (Progress<TState> -> Void) -> (Void -> Void)) {
        this.middleware = middleware;
        this.subscribers = new Delegate();
        this.abortSubscribers = new Delegate0();
    }

    public function dispatch(action: TMessage): AbortablePromise<Void> {
        var promise = new AbortablePromise(function (fulfill, reject) {
            function emit(progress: Progress<TState>): Void {
                switch (progress) {
                    case Updated(x):
                        state = x;
                        subscribers.invoke(x);
                    case Completed(x):
                        state = x;
                        subscribers.invoke(x);
                        fulfill();
                    case Failed(e):
                        reject(e);
                }
            }
            return middleware(state, action, emit);
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

enum Progress<T> {
    Updated(value: T);
    Completed(value: T);
    Failed(error: Dynamic);
}