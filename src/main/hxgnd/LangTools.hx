package hxgnd;

class LangTools {
    public static var nop(default, null) = function () { };

    public inline static function orElse<T>(a: Null<T>, b: T): T {
        return (a != null) ? a : b;
    }
}