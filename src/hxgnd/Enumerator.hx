package hxgnd;

class Enumerator<S, T> {
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
        return new Enumerator(source, pipeline.chain(fn));
    }

    public function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U> {
        return new FlattenEnumerator(new Enumerator(source, pipeline.chain(fn)), Pipeline.empty());
    }

    public function filter(fn: T -> Bool): Enumerable<T> {
        return new FilterEnumerator(this, [fn]);
    }

    public function take(count: Int): Enumerable<T> {
        return new TaskEnumerator(this, count);
    }
    // takeWhile

    // skip
    // skipWhile
    // slice

    // grouped
    // sliding

    // head: Option<T>
    // last: Option<T>

    // span
    // partition

    // concat
    // zip
    // zipAll
    // zipWithIndex
    // unzip

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

    public inline function toArray(): Array<T> {
        return [];
    }

    public static inline function from<T>(source: EnumeratorSource<T>): Enumerable<T> {
        return new Enumerator(source, Pipeline.empty());
    }
}

typedef ForEachable<T> = {
    function forEach(fn: T -> Void): Void;
    function forEachWhile(fn: T -> Bool): Void;
}

typedef Enumerable<T> = {>ForEachable<T>,
    function map<U>(fn: T -> U): Enumerable<U>;
    function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U>;
}

@:forward
abstract EnumeratorSource<T>(ForEachable<T>) from ForEachable<T> to ForEachable<T> {
    @:from public static inline function fromArray<T>(source: Array<T>): EnumeratorSource<T> {
        return {
            forEach: function (fn: T -> Void): Void {
                for (x in source) fn(x);
            },
            forEachWhile: function (fn: T -> Bool): Void {
                for (x in source) {
                    if (!fn(x)) break;
                }
            }
        }
    }

    @:from public static inline function fromIntIterator<T>(source: IntIterator): EnumeratorSource<Int> {
        return {
            forEach: function (fn: Int -> Void): Void {
                for (x in source) fn(x);
            },
            forEachWhile: function (fn: Int -> Bool): Void {
                for (x in source) {
                    if (!fn(x)) break;
                }
            }
        }
    }

    @:from public static inline function fromIterator<T>(source: Iterator<T>): EnumeratorSource<T> {
        return {
            forEach: function (fn: T -> Void): Void {
                for (x in source) fn(x);
            },
            forEachWhile: function (fn: T -> Bool): Void {
                for (x in source) {
                    if (!fn(x)) break;
                }
            }
        }
    }

    @:from public static inline function fromIterable<T>(source: Iterable<T>): EnumeratorSource<T> {
        return {
            forEach: function (fn: T -> Void): Void {
                for (x in source) fn(x);
            },
            forEachWhile: function (fn: T -> Bool): Void {
                for (x in source) {
                    if (!fn(x)) break;
                }
            }
        }
    }
}

class FlattenEnumerator<S, T> {
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

class FilterEnumerator<T> {
    var source: EnumeratorSource<T>;
    var filters: Array<T -> Bool>;

    public function new(source: EnumeratorSource<T>, filters: Array<T -> Bool>) {
        this.source = source;
        this.filters = filters;
    }

    public function forEach(fn: T -> Void): Void {
        source.forEach(function (x) {
            if (applyFilter(x)) fn(x);
        });
    }

    public function forEachWhile(fn: T -> Bool): Void {
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

    public function map<U>(fn: T -> U): Enumerable<U> {
        return new Enumerator(this, Pipeline.from(fn));
    }

    public function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U> {
        return new FlattenEnumerator(new Enumerator(this, Pipeline.from(fn)), Pipeline.empty());
    }
}

class TaskEnumerator<T> {
    var source: EnumeratorSource<T>;
    var count: Int;

    public function new(source: EnumeratorSource<T>, count: Int) {
        this.source = source;
        this.count = count;
    }

    public function forEach(fn: T -> Void): Void {
        var i = 0;
        source.forEachWhile(function (x) {
            fn(x);
            return ++i < count;
        });
    }

    public function forEachWhile(fn: T -> Bool): Void {
        var i = 0;
        source.forEachWhile(function (x) {
            return fn(x) && (++i < count);
        });
    }

    public function map<U>(fn: T -> U): Enumerable<U> {
        return new Enumerator(this, Pipeline.from(fn));
    }

    public function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U> {
        return new FlattenEnumerator(new Enumerator(this, Pipeline.from(fn)), Pipeline.empty());
    }
}

// class TaskWhileEnumerator<T> {
//     var source: EnumeratorSource<T>;
//     var pipeline: Pipeline<T, T>;

//     public function new(source: EnumeratorSource<T>, count: Int) {
//         this.source = source;
//         this.count = count;
//     }

//     public function forEach(fn: T -> Void): Void {
//         var i = 0;
//         source.forEachWhile(function (x) {
//             fn(x);
//             return ++i < count;
//         });
//     }

//     public function forEachWhile(fn: T -> Bool): Void {
//         var i = 0;
//         source.forEachWhile(function (x) {
//             return fn(x) && (++i < count);
//         });
//     }

//     public function map<U>(fn: T -> U): Enumerable<U> {
//         return null;
//     }

//     public function flatMap<U>(fn: T -> EnumeratorSource<U>): Enumerable<U> {
//         return null;
//     }
// }




@:remove
@:autoBuild(hxgnd.internal.EnumeratorBuilder.build())
interface IEnumerator {}
