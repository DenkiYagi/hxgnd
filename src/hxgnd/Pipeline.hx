package hxgnd;

import haxe.Constraints.Function;

abstract Pipeline<T, U>(Array<Function>) {
    inline function new(functions: Array<Function>) {
        this = functions;
    }

    public inline function chain<V>(fn: U -> V): Pipeline<T, V> {
        return new Pipeline(this.concat([fn]));
    }

    public function call(x: T): U {
        var acc: Dynamic = x;
        for (f in this) {
            acc = f(acc);
        }
        return acc;
    }

    public static inline function empty<T>(): Pipeline<T, T> {
        return new Pipeline([]);
    }

    @:from public static inline function from<T, U>(fn: T -> U): Pipeline<T, U> {
        return new Pipeline([fn]);
    }
}