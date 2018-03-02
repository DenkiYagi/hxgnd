package hxgnd.js;

#if macro
import haxe.macro.Expr;
#end
import haxe.Constraints.Function;

class JsNative {
    public static var nativeThis(get, never): Dynamic;
    @:extern inline static function get_nativeThis(): Dynamic {
        return untyped __js__("this");
    }

    public static var nativeArguments(get, never): Arguments;
    @:extern inline static function get_nativeArguments(): Arguments {
        return untyped __js__("arguments");
    }
    
    public static var undefined(get, never): Dynamic;
    @:extern inline static function get_undefined(): Dynamic {
        return untyped __js__("void 0");
    }

    public static inline function encodeURI(x: String): String {
        return untyped __js__("encodeURI")(x);
    }
   
    public static inline function encodeURIComponent(x: String): String {
        return untyped __js__("encodeURIComponent")(x);
    }

    public static inline function decodeURI(x: String): String {
        return untyped __js__("decodeURI")(x);
    }
   
    public static inline function decodeURIComponent(x: String): String {
        return untyped __js__("decodeURIComponent")(x);
    }

    public static inline function toString(object: Dynamic): String {
        return untyped __js__("{0}.toString()", object);
    }

    public static macro function debugger(): ExprOf<Void> {
        return macro untyped __js__("debugger");
    }

    public static macro function delete(expression: Expr): ExprOf<Void> {
        return macro untyped __js__("delete {0}", ${expression});
    }

    public static macro function async(expr: ExprOf<Function>): ExprOf<Function> {
        return macro untyped __js__("(async {0})", ${expr});
    }

    public static macro function await<T>(p: ExprOf<js.Promise<T>>): ExprOf<T> {
        return macro untyped __js__("await {0}", ${p});
    }
}

extern class Arguments implements ArrayAccess<Int> {
    var callee(default, never): Function;
    var caller(default, never): Function;
    var length(default, never): Int;
}
