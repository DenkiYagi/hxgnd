package hxgnd;

class Dispatcher {
    public static function dispatch(fn: Void -> Void): Void {
        #if js
        hxgnd.js.JsNative.setImmediate(fn);
        #elseif neko
        neko.vm.Thread.create(fn);
        #else
        haxe.Timer.delay(fn, 0);
        #end
    }
}