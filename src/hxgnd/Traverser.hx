package hxgnd;

import hxgnd.internal.traverser.*;

@:forward
abstract Traverser<T>(ITraverser<T>) from ITraverser<T> {
    @:from @:extern public static inline function fromArray<T>(array: Array<T>): Traverser<T> {
        return new ArrayTraverser(array);
    }

    @:from @:extern public static inline function fromIntIterator(iterator: IntIterator): Traverser<Int> {
        return new IntIteratorTraverser(iterator);
    }

    @:from @:extern public static inline function fromIterator<T>(iterator: Iterator<T>): Traverser<T> {
        return new IteratorTraverser(iterator);
    }

    @:from @:extern public static inline function formIterable<T>(iterable: Iterable<T>): Traverser<T> {
        return new IteratorTraverser(iterable.iterator());
    }
}
