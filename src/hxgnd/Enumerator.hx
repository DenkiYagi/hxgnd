package hxgnd;

import hxgnd.internal.EnumeratorImpl;
import hxgnd.internal.ForEacherImpl;

class Enumerator {
    public static inline function from<T>(source: EnumeratorSource<T>): Enumerable<T> {
        return new GenericEnumerator(source);
    }
}

typedef ForEachable<T> = {
    function forEach(fn: T -> Void): Void;
    function forEachWhile(fn: T -> Bool): Void;
}

typedef Enumerable<T> = {>ForEachable<T>,
    function map<U>(fn: T -> U): Enumerable<U>;
    function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U>;
    function filter(fn: T -> Bool): Enumerable<T>;
    function take(count: Int): Enumerable<T>;
    function takeWhile(fn: T -> Bool): Enumerable<T>;
    function skip(count: Int): Enumerable<T>;
    function skipWhile(fn: T -> Bool): Enumerable<T>;

    // slice

    // grouped
    // sliding

    // span
    // partition

    // concat
    // zip
    // zipAll
    // zipWithIndex
    // unzip

    // head: Option<T>
    // last: Option<T>
    // reduce()
    // reduceRight
    // exists
    // count
    // isEmpty()
    // nonEmpty()
    // find
    // groupBy
    // max
    // min
    // sum



    function toArray(): Array<T>;
    // toIterator
    // toList
}

@:forward
abstract EnumeratorSource<T>(ForEachable<T>) from ForEachable<T> to ForEachable<T> {
    @:from public static inline function fromArray<T>(source: Array<T>): EnumeratorSource<T> {
        return new ArrayForEacher(source);
    }

    @:from public static inline function fromIntIterator<T>(source: IntIterator): EnumeratorSource<Int> {
        return new IntIteratorForEacher(source);
    }

    @:from public static inline function fromIterator<T>(source: Iterator<T>): EnumeratorSource<T> {
        return new IteratorForEacher(source);
    }

    @:from public static inline function fromIterable<T>(source: Iterable<T>): EnumeratorSource<T> {
        return new IterableForEacher(source);
    }
}