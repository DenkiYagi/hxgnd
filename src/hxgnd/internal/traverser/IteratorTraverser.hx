package hxgnd.internal.traverser;

import extype.Maybe;

class IteratorTraverser<T> implements ITraverser<T> {
    var iterator: Iterator<T>;
    public var current(default, null): Maybe<T>;

    public function new(iterator: Iterator<T>) {
        this.iterator = iterator;
        this.current = Maybe.empty();
    }

    public function next(): Bool {
        return if (iterator.hasNext()) {
            this.current = iterator.next();
            true;
        } else {
            this.current = Maybe.empty();
            false;
        }
    }
}