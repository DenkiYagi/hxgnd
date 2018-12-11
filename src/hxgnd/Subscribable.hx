package hxgnd;

typedef Subscribable<T> = {
    function subscribe(fn: T -> Void): Void;
    function unsubscribe(fn: T -> Void): Void;
}