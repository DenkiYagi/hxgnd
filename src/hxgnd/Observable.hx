package hxgnd;

typedef Observable<T> = {
    function observe(fn: T -> Void): Void;
    function unobserve(fn: T -> Void): Void;
}