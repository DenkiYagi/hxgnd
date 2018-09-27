package hxgnd;

typedef Reactable<T> = {
    > Observable<T>,

    function next(): Promise<T>;

    // function forEach(fn: T ->  Void): Void;

    function map<U>(fn: T -> U): Reactable<U>;
    function flatMap<U>(fn: T -> Reactable<U>): Reactable<U>;

    function filter(fn: T -> Bool): Reactable<T>;
    function skip(count: Int): Reactable<T>;
    function skipWhile(fn: T -> Bool): Reactable<T>;
    function skipUntil(promise: Promise<Dynamic>): Reactable<T>;
    function take(count: Int): Reactable<T>;
    function takeWhile(fn: T -> Bool): Reactable<T>;
    function takeUntil(promise: Promise<Dynamic>): Reactable<T>;

    function reduce(fn: T -> T -> T): Reactable<T>;
    function fold<U>(init: U, fn: U -> T -> U): Reactable<U>;

    function toArray(): Promise<Array<T>>;
    function groupBy(key: T -> String): Promise<Map<String, Array<T>>>;
    function exists(cond: T -> Bool): Promise<Bool>;
    function forAll(cond: T -> Bool): Promise<Bool>;
    function count(?cond: T -> Bool): Promise<Int>;
    function isEmpty(): Promise<Bool>;
    function nonEmpty(): Promise<Bool>;

    function delay(msec: Int): Reactable<T>;
    function throttle(msec: Int): Reactable<T>;
    function debounce(msec: Int): Reactable<T>;
    function timeout(msec: Int): Reactable<T>;

    // function end(): Promise<Void>;
    // catchError
    // finally

    function retry(count: Int): Reactable<T>;
    // function retryWhile
    // function retryUntil
}