package hxgnd;

class Dispatcher {
    public static function dispatch(fn: Void -> Void): Void {
        #if (macro || iterp)
        throw "not implemented";
        #elseif js
        hxgnd.js.JsNative.setImmediate(fn);
        #else
        fn();
        #end
    }
}
