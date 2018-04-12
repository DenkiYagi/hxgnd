package;

class TestTools {
    public static function wait(msec: Int, fn: Void -> Void) {
        #if (neko && !macro)
        neko.vm.Thread.create(function () {
            Sys.sleep(msec / 1000);
            fn();
        });
        #else
        buddy.tools.AsyncTools.wait(msec).then(function (_) fn());
        #end
    }
}