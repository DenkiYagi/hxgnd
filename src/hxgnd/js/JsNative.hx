package hxgnd.js;

#if macro
import haxe.macro.Expr;
#end
import haxe.Constraints.Function;
import js.Syntax;

class JsNative {
    static inline var IMMEDIATE_QUEUE_SIZE = 65536; //2^16

    public static var nativeArguments(get, never): Arguments;
    @:extern inline static function get_nativeArguments(): Arguments {
        return untyped __js__("arguments");
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

    static var functions = [];
    static var index = 0;

    static function __init__() {
        // NOTE setImmediate() of Edge/IE11 is very slow.
        // https://jsfiddle.net/terurou/Lsxrjmpd/3/
        if (!js.Lib.global.navigator && js.Lib.global.setImmediate) {
            JsNative.setImmediate = untyped __js__("setImmediate");
            JsNative.clearImmediate = untyped __js__("clearImmediate");
        } else if  (untyped js.Lib.global.Promise) {
            function invoke(id) {
                var fn = functions[id];
                if (untyped fn) {
                    untyped __js__("delete {0}", functions[id]);
                    fn();
                }
            }

            JsNative.setImmediate = function setImmediatePromise(fn) {
                if (Syntax.strictEq(index, IMMEDIATE_QUEUE_SIZE)) index = 0;
                functions[index] = fn;
                js.lib.Promise.resolve(index).then(invoke);
                return index++;
            };
            JsNative.clearImmediate = function clearImmediatePromise(id) {
                untyped __js__("delete {0}", functions[id]);
            };
        } else if (untyped js.Lib.global.MessageChannel) {
            var channel = new js.html.MessageChannel();
            var functions = [];
            var index = 0;

            channel.port1.onmessage = function (e) {
                var id = e.data;
                var fn = functions[id];
                if (untyped fn) {
                    untyped __js__("delete {0}", functions[id]);
                    fn();
                }
            }
            channel.port1.start();
            channel.port2.start();

            JsNative.setImmediate = function setImmediateMessageChannel(fn) {
                if (Syntax.strictEq(index, IMMEDIATE_QUEUE_SIZE)) index = 0;
                functions[index] = fn;
                channel.port2.postMessage(index);
                return index++;
            }
            JsNative.clearImmediate = function clearImmediateMessageChannel(i) {
                untyped __js__("delete {0}", functions[i]);
            }
        } else {
            JsNative.setImmediate = function setImmediateTimeout(fn) {
                return untyped __js__("setTimeout({0}, {1})", fn, 0);
            }
            JsNative.clearImmediate = function clearImmediateTimeout(i) {
                untyped __js__("clearTimeout({0})", i);
            }
        }
        js.Lib.global._test = JsNative;
    }
}

extern class Arguments implements ArrayAccess<Int> {
    var callee(default, never): Function;
    var caller(default, never): Function;
    var length(default, never): Int;
}
