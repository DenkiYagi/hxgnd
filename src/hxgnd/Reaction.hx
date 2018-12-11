package hxgnd;

import hxgnd.Delegate;

class Reaction<T> {
    public var isDisposed(default, null): Bool;

    var subscriber: Delegate<T>;
    var disposer: Delegate0;

    public function new<U>(subscribable: Subscribable<U>, collector: (T -> Void) -> U -> Void) {
        function subscriber(x) collector(onEmit, x);

        this.isDisposed = false;
        this.subscriber = new Delegate();
        this.disposer = new Delegate0([
            subscribable.unsubscribe.bind(subscriber)
        ]);
        subscribable.subscribe(subscriber);
    }

    function onEmit(x: T): Void {
        subscriber.invoke(x);
    }

    public function subscribe(fn: T -> Void): Void {
        subscriber.add(fn);
    }

    public function unsubscribe(fn: T -> Void): Void {
        subscriber.remove(fn);
    }

    public function map<U>(fn: T -> U): Reaction<U> {
        var subscription = new Reaction(this, function (emit, x) {
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


    // public static function createFrom
}

// abstract _Reaction<T>(Dynamic) {

//     @:from public static function fromArray<T>(x: Array<T>) {

//     }

//     @:from public static function fromIntIterator(x: IntIterator) {

//     }

//     @:from public static function fromIterator<T>(x: Iterator<T>) {

//     }

//     @:from public static function fromSubscribable<T>(x: )
// }