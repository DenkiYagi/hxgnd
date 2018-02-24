package hxgnd.js;

@:native("Array")
extern class JsArray {
	@:overload(function<T>(arrayLike: Dynamic, ?thisArg: Dynamic): Array<T> {})
	static function from<T, U>(arrayLike: Dynamic, mapFn: T -> U, ?thisArg: Dynamic): Array<U>;
	static function isArray(obj: Dynamic): Bool;
	static function of<T>(element: haxe.extern.Rest<T>): Array<T>; 
}