package hxgnd;

class Dispatcher {
    public static function dispatch(fn: Void -> Void): Void {
        #if (macro || iterp)
        fn();
        #elseif js
        hxgnd.js.JsNative.setImmediate(fn);
        #else
        haxe.EntryPoint.runInMainThread(fn);
        #end
    }
}
