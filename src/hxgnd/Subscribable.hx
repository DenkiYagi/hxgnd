package hxgnd;

typedef Subscribable<T> = {
    function subscribe(fn: T -> Void): Void -> Void;
}