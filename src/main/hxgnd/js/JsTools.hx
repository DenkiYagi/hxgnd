package hxgnd.js;

import js.Browser;

class JsTools {
    static function __init__() {
        JsTools.setImmediate = if (untyped setImmediate) {
            function (handler: Void -> Void) {
                var id = untyped __js__("window.setImmediate")(handler);
                return { cancel: function cancel() untyped __js__("window.clearImmediate")(id) }
            }
        } else if (untyped window.MessageChannel) {
            var tasks = [];
            function remove(i) untyped __js__("delete tasks")[i];

            var channel = untyped __js__("new MessageChannel()");
            channel.port1.onmessage = function (e) {
                var i = e.data;
                var f = tasks[i];
                if (untyped f) f();
                remove(i);
            }

            function (handler: Void -> Void) {
                var i = tasks.length;
                tasks[i] = handler;
                channel.port2.postMessage(i);
                return { cancel: function cancel() remove(i) }
            }
        } else if (Reflect.hasField(Browser.document.createScriptElement(), "onreadystatechange")) {
            function (handler) {
                var script = Browser.document.createScriptElement();
                untyped script.onreadystatechange = function () {
                    if (untyped handler) handler();
                    untyped script.onreadystatechange = null;
                    script.parentNode.removeChild(script);
                    script = null;
                }
                Browser.document.documentElement.appendChild(script);
                return { cancel: function cancel() handler = null }
            }
        } else {
            function (handler: Void -> Void) {
                var id = untyped __js__("window.setTimeout")(handler, 0);
                return { cancel: function cancel() untyped __js__("window.clearTimeout")(id) }
            }
        }
    }

    public inline static function orElse<T>(a: Null<T>, b: T): T {
        return (a != null) ? a : b;
    }

    public static inline function getArguments(): Dynamic {
        return untyped __js__("arguments");
    }

    public static inline function getArgument<T>(i: Int): Null<T> {
        return untyped __js__("arguments")[i];
    }

    public static var setImmediate(default, null): (Void -> Void) -> { function cancel(): Void; };

    public static inline function encodeURI(x: String): String {
        return untyped __js__("encodeURI")(x);
    }

    public static inline function confirm(msg: String, noitifyCancel = true): Promise<Unit> {
        return new Promise(function (resolve, reject) {
            if (Browser.window.confirm(msg)) {
                resolve(Unit._);
            } else {
                if (noitifyCancel) reject(new Error("Canceled"));
            }
            return function () { };
        });
    }
}