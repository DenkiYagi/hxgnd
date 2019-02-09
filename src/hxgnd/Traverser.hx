package hxgnd;

import hxgnd.internal.traverser.*;

@:forward
abstract Traverser<T>(ITraverser<T>) from ITraverser<T> {
    public static function from<T>(source: TraverserSource<T>): Traverser<T> {
        return source;
    }
}

abstract TraverserSource<T>(ITraverser<T>) from ITraverser<T> to Traverser<T> {
    // public function create()

    @:extern @:from static inline function fromArray<T>(array: Array<T>): TraverserSource<T> {
        return new ArrayTraverser(array);
    }

    @:extern @:from static inline function fromIntIterator(iterator: IntIterator): TraverserSource<Int> {
        return new IntIteratorTraverser(iterator);
    }

    @:extern @:from static inline function fromIterator<T>(iterator: Iterator<T>): TraverserSource<T> {
        return new IteratorTraverser(iterator);
    }

    @:extern @:from static inline function formIterable<T>(iterable: Iterable<T>): TraverserSource<T> {
        return new IteratorTraverser(iterable.iterator());
    }
}
