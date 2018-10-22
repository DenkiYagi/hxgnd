package hxgnd;

/**
 * Provides support for lazy initialization.
 */
abstract Lazy<T>(Void -> T) {
    /**
     * Creates a new lazy initializer.
     * @param factory The function that returns the lazily initialized value.
     */
    public inline function new(factory: Void -> T) {
        this = function lazy_factory() {
            var value = factory();
            this = retunValue.bind(value);
            return value;
        };
    }

    function retunValue(value: T): T {
        return value;
    }

    /**
    * Gets the lazily initialized value.
    * @return T The lazily initialized value.
     */
    @:to
    public inline function get(): T {
        return this();
    }
}
