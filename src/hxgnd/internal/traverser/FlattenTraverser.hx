package hxgnd.internal.traverser;

import extype.Maybe;

class FlattenTraverser<T> implements ITraverser<T> {
    var source: Traverser<Traverser<T>>;
    var currentTraverser: Maybe<Traverser<T>>;
    public var current(default, null): Maybe<T>;

    public function new(source: Traverser<Traverser<T>>) {
        this.source = source;
        this.currentTraverser = Maybe.empty();
        this.current = Maybe.empty();
    }

    public function next(): Bool {
        if (currentTraverser.isEmpty()) nextTraverser();

        while (currentTraverser.nonEmpty()) {
            var t = currentTraverser.get();
            if (t.next()) {
                current = t.current;
                return true;
            } else {
                nextTraverser();
            }
        }

        return false;
    }

    inline function nextTraverser(): Void {
        if (source.next()) {
            currentTraverser = source.current;
        } else {
            currentTraverser = Maybe.empty();
        }
    }
}