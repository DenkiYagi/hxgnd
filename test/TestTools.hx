package;

class TestTools {
    public static function wait(msec: Int, fn: Void -> Void) {
        #if js
        haxe.Timer.delay(fn, msec);
        // #elseif (sys && !macro && !iterp)
        // haxe.Timer.delay(fn, msec);
        //tasks.add({ fn: fn, delay: msec });
        #else
        buddy.tools.AsyncTools.wait(msec).then(function (_) fn());
        #end
    }

    #if (sys && !macro && !iterp)
    static var tasks = new neko.vm.Deque<{delay: Int, fn: Void -> Void}>();
    static var running = false;

    public static function run(): Void {
        running = true;
        // haxe.EntryPoint.addThread(function () {
        //     while (running) {
        //         trace("## wait ");
        //         var t = tasks.pop(false);
        //         if (t != null) {
        //             Sys.sleep(t.delay / 1000);
        //             haxe.EntryPoint.runInMainThread(t.fn);
        //         } else {
        //             Sys.sleep(0.001);
        //         }
        //     }
        // });
    }

    public static function stop(): Void {
        running = false;
    }
    #end
}
