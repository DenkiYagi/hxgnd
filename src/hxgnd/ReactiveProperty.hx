package hxgnd;

class ReactiveProperty<T> {
    var value: T;
    var equaler: T -> T -> Bool;
    var subscribers: Delegate<T>;

    public function new(initValue: T, ?equaler: T -> T -> Bool) {
        this.value = initValue;
        this.equaler = LangTools.getOrElse(equaler, function eq(a, b) return LangTools.eq(a, b));
        this.subscribers = new Delegate();
    }

    public function get(): T {
        return value;
    }

    public function set(x: T): Void {
        if (equaler(value, x)) return;

        #if debug
        value = LangTools.freeze(x);
        #else
        value = x;
        #end

        subscribers.invoke(x);
    }

    public function subscribe(fn: T -> Void): Void -> Void {
        subscribers.add(fn);
        return function unsubscribe() {
            subscribers.remove(fn);
        }
    }

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
