package hxgnd;

import hxgnd.internal.traverser.*;

@:forward
abstract Traverser<T>(ITraverser<T>) from TraverserSource<T> {
    @:from public static inline function from<T>(source: TraverserSource<T>): Traverser<T> {
        return source;
    }

    public inline function forEach(fn: T -> Void): Void {
        while (this.next()) fn(this.current.get());
    }
}

abstract TraverserSource<T>(ITraverser<T>) from ITraverser<T> to ITraverser<T> {
    @:from public extern static inline function fromArray<T>(array: Array<T>): TraverserSource<T> {
        return new ArrayTraverser(array);
    }

    @:from public extern static inline function fromIntIterator(iterator: IntIterator): TraverserSource<Int> {
        return new IntIteratorTraverser(iterator);
    }

    @:from public extern static inline function fromIterator<T>(iterator: Iterator<T>): TraverserSource<T> {
        return new IteratorTraverser(iterator);
    }

    @:from public extern static inline function fromIterable<T>(iterable: Iterable<T>): TraverserSource<T> {
        return new IteratorTraverser(iterable.iterator());
    }
}