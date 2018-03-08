package hxgnd.js;

@:native("Date")
extern class JsDate {
    static function UTC(year: Int, month: Int, ?day: Int, ?hour: Int, ?minute: Int, ?second: Int, ?millisecond: Int): JsDate;
    static function now(): Int;
    static function parse(dateString: String): JsDate;

    @:overload(function (value: Int): Void {})
    @:overload(function (dateString: String): Void {})
    @:overload(function (year: Int, month: Int, ?day: Int, ?hour: Int, ?minute: Int, ?second: Int, ?millisecond: Int): Void {})
    function new();

    // TODO add methods

    function valueOf(): Int;

    public static inline function fromHaxeDate(x: Date): JsDate {
        return cast x;
    }

    public inline function toHaxeDate(): Date {
        return cast this;
    }
}