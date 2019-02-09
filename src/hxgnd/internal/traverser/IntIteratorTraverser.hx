package hxgnd.internal.traverser;

import extype.Maybe;

class IntIteratorTraverser implements ITraverser<Int> {
    var iterator: IntIterator;
    public var current(default, null): Maybe<Int>;

    public function new(iterator: IntIterator) {
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
