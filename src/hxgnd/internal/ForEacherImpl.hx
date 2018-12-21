package hxgnd.internal;

class ArrayForEacher<T> {
    var source: Array<T>;

    public function new(source: Array<T>) {
        this.source = source;
    }

    public inline function forEach(fn: T -> Void): Void {
        for (x in source) fn(x);
    }

    public inline function forEachWhile(fn: T -> Bool): Void {
        for (x in source) {
            if (!fn(x)) break;
        }
    }
}

class IntIteratorForEacher {
    var source: IntIterator;

    public function new(source: IntIterator) {
        this.source = source;
    }

    public inline function forEach(fn: Int -> Void): Void {
        for (x in source) fn(x);
    }

    public inline function forEachWhile(fn: Int -> Bool): Void {
        for (x in source) {
            if (!fn(x)) break;
        }
    }
}

class IteratorForEacher<T> {
    var source: Iterator<T>;

    public function new(source: Iterator<T>) {
        this.source = source;
    }

    public inline function forEach(fn: T -> Void): Void {
        for (x in source) fn(x);
    }

    public inline function forEachWhile(fn: T -> Bool): Void {
        for (x in source) {
            if (!fn(x)) break;
        }
    }
}

class IterableForEacher<T> {
    var source: Iterable<T>;

    public function new(source: Iterable<T>) {
        this.source = source;
    }

    public inline function forEach(fn: T -> Void): Void {
        for (x in source) fn(x);
    }

    public inline function forEachWhile(fn: T -> Bool): Void {
        for (x in source) {
            if (!fn(x)) break;
        }
    }
}
