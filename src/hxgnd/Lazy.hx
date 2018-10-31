package hxgnd;

/**
 * Provides support for lazy initialization.
 */
abstract Lazy<T>(State<T>) {
    /**
     * Creates a new lazy initializer.
     * @param factory The function that returns the lazily initialized value.
     */
    @:extern public inline function new(factory: Void -> T) {
        this = Pending(factory);
    }

    /**
    * Gets the lazily initialized value.
    * @return T The lazily initialized value.
     */
    @:to
    @:extern public inline function get(): T {
        return switch (this) {
            case Pending(factroy):
                var value = factroy();
                this = Initialized(value);
                value;
            case Initialized(value):
                value;
        }
    }
}

private enum State<T> {
    Pending(factory: Void -> T);
    Initialized(value: T);
}