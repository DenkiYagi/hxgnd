package hxgnd;

abstract Tuple3<T1, T2, T3>(Array<Dynamic>) {
    public var value1(get, never): T1;
    public var value2(get, never): T2;
    public var value3(get, never): T3;

    public inline function new(v1: T1, v2: T2, v3: T3) {
        this = [v1, v2, v3];
    }

    inline function get_value1(): T1 {
        return this[0];
    }

    inline function get_value2(): T2 {
        return this[1];
    }

    inline function get_value3(): T3 {
        return this[2];
    }
}