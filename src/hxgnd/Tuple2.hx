package hxgnd;

abstract Tuple2<T1, T2>(Array<Dynamic>) {
    public var value1(get, never): T1;
    public var value2(get, never): T2;

    public inline function new(v1: T1, v2: T2) {
        this = [v1, v2];
    }

    inline function get_value1(): T1 {
        return this[0];
    }

    inline function get_value2(): T2 {
        return this[1];
    }
}