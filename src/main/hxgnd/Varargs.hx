package hxgnd;

@:forward
abstract Varargs<T>(Array<T>) from Array<T> to Array<T> {

    inline function new(x: Array<T>) {
        this = x;
    }

    @:from
    public static function fromValue<T>(x: T) {
        return new Varargs([x]);
    }


}