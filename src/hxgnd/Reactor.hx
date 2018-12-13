package hxgnd;

import hxgnd.Delegate;

class Reactor<T> {
    public var isDisposed(default, null): Bool;

    var subscriber: Delegate<T>;
    var disposer: Delegate0;

    public function new<S>(source: Subscribable<S>, collector: (T -> Void) -> S -> Void) {
        this.isDisposed = false;
        this.subscriber = new Delegate();

        function handle(x) collector(subscriber.invoke, x);
        this.disposer = new Delegate0([
            source.unsubscribe.bind(handle)
        ]);
        source.subscribe(handle);
    }

    public function subscribe(fn: T -> Void): Void {
        if (isDisposed) return;
        subscriber.add(fn);
    }

    public function unsubscribe(fn: T -> Void): Void {
        if (isDisposed) return;
        subscriber.remove(fn);
    }

    public function map<U>(fn: T -> U): Reactor<U> {
        var reactor = new Reactor(this, function (emit, x) {
            emit(fn(x));
        });
        disposer.add(reactor.dispose);
        return reactor;
    }

    public function flatMap<U>(fn: T -> Reactor<U>): Reactor<U> {
        var reactor = new Reactor(this, function (emit, x) {
            var ret = fn(x);
            disposer.add(ret.dispose);
            ret.subscribe(emit);
        });
        disposer.add(reactor.dispose);
        return reactor;
    }

    public function dispose(): Void {
        subscriber.removeAll();
        disposer.invoke();
        disposer.removeAll();
        isDisposed = true;
    }


    // public static function createFrom
}

// abstract _Reactor<T>(Dynamic) {

//     @:from public static function fromArray<T>(x: Array<T>) {

//     }

//     @:from public static function fromIntIterator(x: IntIterator) {

//     }

//     @:from public static function fromIterator<T>(x: Iterator<T>) {

//     }

//     @:from public static function fromSubscribable<T>(x: )
// }