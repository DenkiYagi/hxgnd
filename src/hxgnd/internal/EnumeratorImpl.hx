package hxgnd.internal;

import hxgnd.Enumerator;

class GenericEnumerator<T> implements IEnumerator {
    var source: EnumeratorSource<T>;

    public function new(source: EnumeratorSource<T>) {
        this.source = source;
    }
}

class MapEnumerator<S, T> implements IEnumerator {
    var source: EnumeratorSource<S>;
    var pipeline: Pipeline<S, T>;

    public function new(source: EnumeratorSource<S>, pipeline: Pipeline<S, T>) {
        this.source = source;
        this.pipeline = pipeline;
    }

    public function forEach(fn: T -> Void): Void {
        source.forEach(function (x) {
            fn(pipeline.call(x));
        });
    }

    public function forEachWhile(fn: T -> Bool): Void {
        source.forEachWhile(function (x) {
            return fn(pipeline.call(x));
        });
    }

    public function map<U>(fn: T -> U): Enumerable<U> {
        return new MapEnumerator(source, pipeline.chain(fn));
    }

    public function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U> {
        return new FlattenEnumerator(new MapEnumerator(source, pipeline.chain(fn)), Pipeline.empty());
    }
}

class FlattenEnumerator<S, T> implements IEnumerator {
    var source: EnumeratorSource<EnumeratorSource<S>>;
    var pipeline: Pipeline<S, T>;

    public function new(source: EnumeratorSource<EnumeratorSource<S>>, pipeline: Pipeline<S, T>) {
        this.source = source;
        this.pipeline = pipeline;
    }

    public function forEach(fn: T -> Void): Void {
        var pl = pipeline.chain(fn);
        source.forEach(function (x) {
            x.forEach(pl.call);
        });
    }

    public function forEachWhile(fn: T -> Bool): Void {
        var next = true;
        source.forEachWhile(function (eachable) {
            eachable.forEachWhile(function (x) {
                next = fn(pipeline.call(x));
                return next;
            });
            return next;
        });
    }

    public function map<U>(fn: T -> U): Enumerable<U> {
        return new FlattenEnumerator(source, pipeline.chain(fn));
    }

    public function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U> {
        return new FlattenEnumerator(new FlattenEnumerator(source, pipeline.chain(fn)), Pipeline.empty());
    }
}

class FilterEnumerator<T> extends GenericEnumerator<T> {
    var filters: Array<T -> Bool>;

    public function new(source: EnumeratorSource<T>, filters: Array<T -> Bool>) {
        super(source);
        this.filters = filters;
    }

    public override function forEach(fn: T -> Void): Void {
        source.forEach(function (x) {
            if (applyFilter(x)) fn(x);
        });
    }

    public override function forEachWhile(fn: T -> Bool): Void {
        source.forEachWhile(function (x) {
            if (applyFilter(x)) {
                if (!fn(x)) return false;
            }
            return true;
        });
    }

    function applyFilter(x: T): Bool {
        for (f in filters) {
            if (!f(x)) return false;
        }
        return true;
    }
}

class TaskEnumerator<T> extends GenericEnumerator<T> {
    var count: Int;

    public function new(source: EnumeratorSource<T>, count: Int) {
        super(source);
        this.count = count;
    }

    public override function forEach(fn: T -> Void): Void {
        var i = count;
        source.forEachWhile(function (x) {
            return if (i-- >= 0) {
                fn(x);
                true;
            } else {
                false;
            }
        });
    }

    public override function forEachWhile(fn: T -> Bool): Void {
        var i = count;
        source.forEachWhile(function (x) {
            return (i-- >= count) && fn(x);
        });
    }
}

class TaskWhileEnumerator<T> extends GenericEnumerator<T> {
    var predicate: T -> Bool;

    public function new(source: EnumeratorSource<T>, predicate: T -> Bool) {
        super(source);
        this.predicate = predicate;
    }

    public override function forEach(fn: T -> Void): Void {
        source.forEachWhile(function (x) {
            return if (predicate(x)) {
                fn(x);
                true;
            } else {
                false;
            }
        });
    }

    public override function forEachWhile(fn: T -> Bool): Void {
        source.forEachWhile(function (x) {
            return predicate(x) && fn(x);
        });
    }
}

class SkipEnumerator<T> extends GenericEnumerator<T> {
    var count: Int;

    public function new(source: EnumeratorSource<T>, count: Int) {
        super(source);
        this.count = count;
    }

    public override function forEach(fn: T -> Void): Void {
        var i = count;
        source.forEach(function (x) {
            if (i <= 0) {
                fn(x);
            } else {
                --i;
            }
        });
    }

    public override function forEachWhile(fn: T -> Bool): Void {
        var i = count;
        source.forEachWhile(function (x) {
            return if (i <= 0) {
                fn(x);
            } else {
                --i;
                true;
            }
        });
    }
}

class SkipWhileEnumerator<T> extends GenericEnumerator<T> {
    var predicate: T -> Bool;

    public function new(source: EnumeratorSource<T>, predicate: T -> Bool) {
        super(source);
        this.predicate = predicate;
    }

    public override function forEach(fn: T -> Void): Void {
        var skipping = true;
        source.forEach(function (x) {
            if (skipping) {
                skipping = predicate(x);
                if (!skipping) fn(x);
            } else {
                fn(x);
            }
        });
    }

    public override function forEachWhile(fn: T -> Bool): Void {
        var skipping = true;
        source.forEachWhile(function (x) {
            return if (skipping) {
                skipping = predicate(x);
                skipping ? true : fn(x);
            } else {
                fn(x);
            }
        });
    }
}