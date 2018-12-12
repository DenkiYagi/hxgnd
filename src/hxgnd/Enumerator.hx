package hxgnd;

class Enumerator {
    public static inline function fromArray<T>(array: Array<T>): Enumerable<T> {
        return new ArrayEnumerator(array, Pipeline.empty());
    }
}

typedef Enumerable<T> = {
    function forEach(fn: T -> Void): Void;
    function map<U>(fn: T -> U): Enumerable<U>;
    function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U>;
}

class ArrayEnumerator<S, T> {
    var source: Array<S>;
    var pipeline: Pipeline<S, T>;

    public function new(source: Array<S>, pipeline: Pipeline<S, T>) {
        this.source = source;
        this.pipeline = pipeline;
    }

    public function forEach(fn: T -> Void): Void {
        var pl = pipeline.chain(fn);
        for (x in source) pl.call(x);
    }

    public inline function map<U>(fn: T -> U): Enumerable<U> {
        return new ArrayEnumerator(source, pipeline.chain(fn));
    }

    public inline function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U> {
        return new FlattenEnumerator(new ArrayEnumerator(source, pipeline.chain(fn)), Pipeline.empty());
    }
}

class FlattenEnumerator<S, T> {
    var source: Enumerable<Enumerable<S>>;
    var pipeline: Pipeline<S, T>;

    public function new(source: Enumerable<Enumerable<S>>, pipeline: Pipeline<S, T>) {
        this.source = source;
        this.pipeline = pipeline;
    }

    public function forEach(fn: T -> Void): Void {
        var pl = pipeline.chain(fn);
        source.forEach(function (x) {
            x.forEach(pl.call);
        });
    }

    public inline function map<U>(fn: T -> U): Enumerable<U> {
        return new FlattenEnumerator(source, pipeline.chain(fn));
    }

    public inline function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U> {
        return new FlattenEnumerator(new FlattenEnumerator(source, pipeline.chain(fn)), Pipeline.empty());
    }
}
