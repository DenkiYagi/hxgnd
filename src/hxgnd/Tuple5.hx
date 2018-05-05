package hxgnd;

abstract Tuple5<T1, T2, T3, T4, T5>(Array<Dynamic>) {
    public var value1(get, never): T1;
    public var value2(get, never): T2;
    public var value3(get, never): T3;
    public var value4(get, never): T4;
    public var value5(get, never): T5;

    public inline function new(v1: T1, v2: T2, v3: T3, v4: T4, v5: T5) {
        this = [v1, v2, v3, v4, v5];
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

    inline function get_value4(): T4 {
        return this[3];
    }

    inline function get_value5(): T5 {
        return this[4];
    }
}