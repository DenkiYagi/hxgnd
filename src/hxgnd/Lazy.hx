package hxgnd;

/**
 * Provides support for lazy initialization.
 */
abstract Lazy<T>(Void -> T) {
    /**
     * Creates a new lazy initializer.
     * @param factory The function that returns the lazily initialized value.
     */
    @:extern public inline function new(factory: Void -> T) {
        this = function lazy_factory() {
            var value = factory();
            set(retunValue.bind(value));
            return value;
        };
    }

    inline function set(factory: Void -> T): Void {
        this = factory;
    }

    function retunValue(value: T): T {
        return value;
    }

    /**
    * Gets the lazily initialized value.
    * @return T The lazily initialized value.
     */
    @:to
    @:extern public inline function get(): T {
        return this();
    }
}
