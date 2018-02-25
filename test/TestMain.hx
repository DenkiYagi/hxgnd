package;

import utest.Runner;
import utest.ui.Report;

class TestMain {
    public static function main(): Void {
        var runner = new Runner();
        Report.create(runner);
        runner.addCase(new hxgnd.LangToolsTest());
        runner.addCase(new hxgnd.ArrayToolsTest());
        runner.addCase(new hxgnd.MaybeTest());
        runner.addCase(new hxgnd.MacroToolsTest());
        #if js
        runner.addCase(new hxgnd.js.PromiseToolsTest());
        #end
        runner.run();
    }
}