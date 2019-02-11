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

    public function filter(fn: T -> Bool): Enumerator<T> {
        return new Enumerator(source, pipeline.filter(fn));
    }

    public function skip(count: Int): Enumerator<T> {
        return new Enumerator(source, pipeline.skip(count));
    }

    public function skipWhile(fn: T -> Bool): Enumerator<T> {
        return new Enumerator(source, pipeline.skipWhile(fn));
    }

    public function take(count: Int): Enumerator<T> {
        return new Enumerator(source, pipeline.take(count));
    }

    public function takeWhile(fn: T -> Bool): Enumerator<T> {
        return new Enumerator(source, pipeline.takeWhile(fn));
    }

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

typedef EnumeratorSource<T> = Traverser.TraverserSource<T>;
