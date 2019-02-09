package hxgnd.internal.traverser;

import extype.Maybe;

class ArrayTraverser<T> implements ITraverser<T> {
    var array: Array<T>;
    var length: Int;
    var index: Int;
    public var current(default, null): Maybe<T>;

    public function new(array: Array<T>) {
        this.array = array;
        this.length = array.length;
        this.index = 0;
        this.current = Maybe.empty();
    }

    public function next(): Bool {
        return if (index < length) {
            this.current = array[index++];
            true;
        } else {
            this.current = Maybe.empty();
            false;
        }
    }
}