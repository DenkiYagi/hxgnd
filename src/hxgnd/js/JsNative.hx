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

    public static var setImmediate(default, null): (Void -> Void) -> Int;

    public static var clearImmediate(default, null): Int -> Void;

    public static macro function debugger(): ExprOf<Void> {
        return macro untyped __js__("debugger");
    }

    public static macro function delete(expression: Expr): ExprOf<Void> {
        return macro untyped __js__("delete {0}", ${expression});
    }

    static function __init__() {
        if (untyped __js__("setImmediate")) {
            JsNative.setImmediate = untyped __js__("setImmediate");
            JsNative.clearImmediate = untyped __js__("clearImmediate");
        } else if (untyped __js__("MessageChannel")) {
            var channel = untyped __js__("new MessageChannel()");
            var functions = [];
            channel.onmessage = function (i) {
                var fn = functions[i];
                untyped __js__("delete {0}", functions[i]);
                if (untyped fn) fn();
            }
            JsNative.setImmediate = function setImmediateMC(fn) {
                var i = functions.length;
                functions[i] = fn;
                channel.postMessage(i);
                return i;
            }
            JsNative.clearImmediate = function clearImmediateMC(i) {
                untyped __js__("delete {0}", functions[i]);
            }
        } else {
            JsNative.setImmediate = function setImmediateTO(fn) {
                return untyped __js__("setTimeout({0}, {1})", fn, 0);
            }
            JsNative.clearImmediate = function clearImmediateTO(i) {
                untyped __js__("clearTimeout({0})", i);
            }
        }

    }
}

extern class Arguments implements ArrayAccess<Int> {
    var callee(default, never): Function;
    var caller(default, never): Function;
    var length(default, never): Int;
}
