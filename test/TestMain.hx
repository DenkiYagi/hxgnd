package;

import buddy.*;

#if js
class TestMain implements Buddy<[
    // hxgnd.LangToolsTest,
    // hxgnd.ArrayToolsTest,
    // hxgnd.MaybeTest,
    // hxgnd.DelegateTest,
    // hxgnd.ComputationTest,
    // hxgnd.StreamTest,
    hxgnd.PromiseTest,
    hxgnd.SyncPromiseTest,
    // hxgnd.AbortablePromiseTest,
    // hxgnd.PromiseToolsTest,
    // hxgnd.ReactivePropertyTest,
    // hxgnd.ReactiveActorTest,
    hxgnd.ReactiveStreamTest,
]> {}
#else
import buddy.reporting.ConsoleColorReporter;

class TestMain {
    public static function main() {
        haxe.EntryPoint.run();
        TestTools.run();
        promhx.base.EventLoop.nextLoop = haxe.EntryPoint.runInMainThread;

        var testsDone = false;
        var origTrace = haxe.Log.trace;
        var reporter = new ConsoleColorReporter();
        var runner = new buddy.SuitesRunner([
            // new hxgnd.LangToolsTest(),
            // new hxgnd.ArrayToolsTest(),
            // new hxgnd.MaybeTest(),
            // new hxgnd.DelegateTest(),
            // new hxgnd.ComputationTest(),
            // // new hxgnd.StreamTest(),
            new hxgnd.PromiseTest(),
            new hxgnd.SyncPromiseTest(),
            // new hxgnd.AbortablePromiseTest(),
            // new hxgnd.PromiseToolsTest(),
            // new hxgnd.ReactivePropertyTest(),
            // new hxgnd.ReactiveActorTest(),
            new hxgnd.ReactiveStreamTest(),
        ], reporter);
        runner.run().then(function(_) {
            if (runner.unrecoverableError != null) origTrace(runner.unrecoverableError);
            testsDone = true;
        });

        haxe.EntryPoint.addThread(function () {
            while (!testsDone) Sys.sleep(0.1);
            TestTools.stop();
            haxe.EntryPoint.runInMainThread(function () {
                Sys.exit(runner.statusCode());
            });
        });
    }
}
#end