package hxgnd;

class Dispatcher {
    #if (neko && !macro)
    static var thread = neko.vm.Thread.create(function () {
        while (true) {
            var fn: Void -> Void = neko.vm.Thread.readMessage(true);
            try {
                fn();
            } catch (e: Dynamic) {
                trace(e);
            }
        }
    });
    #end

    public static function dispatch(fn: Void -> Void): Void {
        #if js
        hxgnd.js.JsNative.setImmediate(fn);
        #elseif (neko && !macro)
        thread.sendMessage(fn);
        #else
        haxe.Timer.delay(fn, 0);
        #end
    }
}