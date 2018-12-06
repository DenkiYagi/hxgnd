package hxgnd;

import hxgnd.Delegate;

class Subscription<T> {
    public var isDisposed(default, null): Bool;

    var subscriber: Delegate<T>;
    var disposer: Delegate0;

    public function new<U>(subscribable: Subscribable<U>, collector: (T -> Void) -> U -> Void) {
        this.isDisposed = false;
        this.subscriber = new Delegate();
        this.disposer = new Delegate0([
            subscribable.subscribe(function (x) collector(onEmit, x))
        ]);
    }

    function onEmit(x: T): Void {
        subscriber.invoke(x);
    }

    public function subscribe(fn: T -> Void): Void -> Void {
        subscriber.add(fn);
        return subscriber.remove.bind(fn);
    }

    public function map<U>(fn: T -> U): Subscription<U> {
        var subscription = new Subscription(this, function (emit, x) {
            emit(fn(x));
        });
        disposer.add(subscription.dispose);
        return subscription;
    }

    public function dispose(): Void {
        subscriber.removeAll();
        disposer.invoke();
        disposer.removeAll();
        isDisposed = true;
    }
}
