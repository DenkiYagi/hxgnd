package;

import buddy.*;
import buddy.reporting.ConsoleColorReporter;

// please see https://github.com/ciscoheat/buddy/blob/master/src/buddy/internal/GenerateMain.hx
class TestMain {
    static var suites = [
        // new hxgnd.LangToolsTest(),
        // new hxgnd.ArrayToolsTest(),
        // new hxgnd.MaybeTest(),
        // new hxgnd.DelegateTest(),
        // new hxgnd.ComputationTest(),
        // new hxgnd.StreamTest(),
        // new hxgnd.PromiseTest(),
        // new hxgnd.SyncPromiseTest(),
        // new hxgnd.AbortablePromiseTest(),
        // new hxgnd.PromiseToolsTest(),
        // new hxgnd.ReactivePropertyTest(),
        // new hxgnd.ReactiveActorTest(),
        new hxgnd.ReactiveStreamTest(),
    ];

    public static function main() {
        var reporter = new ConsoleColorReporter();
        var runner = new buddy.SuitesRunner(suites, reporter);
        var oldTrace = haxe.Log.trace;

        function outputError() {
            haxe.Log.trace = oldTrace; // Restore original trace

            var pos = {
                fileName : "Buddy",
                lineNumber : 0,
                className : "",
                methodName : ""
            };

            haxe.Log.trace(runner.unrecoverableError, pos);

            var stack = runner.unrecoverableErrorStack;
            if (stack == null || stack.length == 0) return;

            for (s in stack) switch s {
                case FilePos(_, file, line) if (line > 0):
                    haxe.Log.trace(file + ":" + line, pos);
                case _:
            }
        }

        function startRun(done : Void -> Void) : Void {
            // lua fix, needs temp var
            var r = runner.run();
            r.then(function(_) {
                if (runner.unrecoverableError != null) outputError();
                done();
            });
        }

#if (js && nodejs)
        untyped __js__("process.on('uncaughtException', {0})", function (err) {
            runner.haveUnrecoverableError(err);
        });
        #if !showUnhandledRejection
        untyped __js__("process.on('unhandledRejection', {0})", function (err) {});
        #end
        startRun(function () {
            untyped __js__("process.exit({0})", runner.statusCode());
        });
#elseif (neko || cpp || python)
        haxe.EntryPoint.run();
        TestTools.run();
        promhx.base.EventLoop.nextLoop = haxe.EntryPoint.runInMainThread;

        var testsDone = false;
        runner.run().then(function(_) {
            if (runner.unrecoverableError != null) oldTrace(runner.unrecoverableError);
            testsDone = true;
        });

        haxe.EntryPoint.addThread(function () {
            while (!testsDone) Sys.sleep(0.1);
            TestTools.stop();
            haxe.EntryPoint.runInMainThread(function () {
                Sys.exit(runner.statusCode());
            });
        });
#else
        startRun(function () {});
#end
    }
}