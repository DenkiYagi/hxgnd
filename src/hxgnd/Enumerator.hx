package hxgnd;

import hxgnd.Traverser;
import hxgnd.internal.enumerator.Pipeline;
import hxgnd.internal.traverser.FlattenTraverser;

class Enumerator<T> {
    var source: Traverser<Dynamic>;
    var pipeline: Pipeline<Dynamic, T>;

    function new<S>(source: Traverser<S>, pipeline: Pipeline<S, T>) {
        this.source = source;
        this.pipeline = pipeline;
    }

    public function traverser(): Traverser<T> {
        return pipeline.createTraverser(source);
    }

    public inline function forEach(fn: T -> Void): Void {
        var traverser = pipeline.createTraverser(source);
        while (traverser.next()) {
            fn(traverser.current.get());
        }
    }

    public function map<U>(fn: T -> U): Enumerator<U> {
        return new Enumerator(source, pipeline.map(fn));
    }

    public function flatMap<U>(fn: T -> Traverser<U>): Enumerator<U> {
        return new Enumerator(
            new FlattenTraverser(pipeline.map(fn).createTraverser(source)),
            new Pipeline<U, U>()
        );
    }

    // function flatMap<U>(fn: T -> Traverser<U>): Enumerable<U>;
    // function filter(fn: T -> Bool): Enumerable<T>;
    // function take(count: Int): Enumerable<T>;
    // function takeWhile(fn: T -> Bool): Enumerable<T>;
    // function skip(count: Int): Enumerable<T>;
    // function skipWhile(fn: T -> Bool): Enumerable<T>;

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



    // function toArray(): Array<T>;
    // toIterator
    // toList


    public static function from<T>(source: EnumeratorSource<T>): Enumerator<T> {
        return new Enumerator(source, new Pipeline());
    }
}

abstract EnumeratorSource<T>(Traverser<T>) from Traverser<T> to Traverser<T> {
    @:extern @:from static inline function fromArray<T>(array: Array<T>): EnumeratorSource<T> {
        return Traverser.fromArray(array);
    }

    @:extern @:from static inline function fromIntIterator(iterator: IntIterator): EnumeratorSource<Int> {
        return Traverser.fromIntIterator(iterator);
    }

    @:extern @:from static inline function fromIterator<T>(iterator: Iterator<T>): EnumeratorSource<T> {
        return Traverser.fromIterator(iterator);
    }

    @:extern @:from static inline function fromIterable<T>(iterable: Iterable<T>): EnumeratorSource<T> {
        return Traverser.formIterable(iterable);
    }
}
