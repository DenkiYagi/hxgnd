package;

import buddy.*;

class TestMain implements Buddy<[
    hxgnd.LangToolsTest,
    hxgnd.ArrayToolsTest,
    hxgnd.OptionToolsTest,
    hxgnd.LazyTest,
    hxgnd.DelegateTest,
    hxgnd.TraverserTest,
    hxgnd.ComputationTest,
    hxgnd.PromiseTest,
    hxgnd.SyncPromiseTest,
    hxgnd.AbortablePromiseTest,
    hxgnd.CallbackFlowTest,
    hxgnd.NodebackFlowTest,
    hxgnd.ReactorTest,
    hxgnd.ReactivePropertyTest,
    hxgnd.ReactiveActorTest,
    // hxgnd.ReactiveStreamTest
]> {}

/*
import hxgnd.Enumerator;
import hxgnd.Traverser;
import hxgnd.internal.enumerator.Pipeline;

class TestMain {
    public static function main() {
        var array = [for (i in 0...10000000) i];
        var time: Void -> Int = js.Lib.require('perf_hooks').performance.now;

        function takeWhile(x) return true;
        function filter1(x) return x % 2 == 0;
        function filter2(x) return x % 3 == 0;
        function map1(x) return x * 10;
        function map2(x) return x + 1;
        function map3(x) return x - 1;
        function map4(x) return x * -2;

        trace("native");
        var s = time();
        var sum = 0;
        for (x in array) {
            var acc = x;
            // if (!filter1(acc)) continue;
            // if (!filter2(acc)) continue;
            var acc = map1(acc);
            var acc = map2(acc);
            var acc = map3(acc);
            var acc = map4(acc);
            sum += acc;
        }
        trace(time() - s);
        trace(sum);

        // trace("pipeline");
        // var s = time();
        // var sum = 0;
        // var pipeline = new Pipeline()
        // //pipeline.pipeTakeWhile(takeWhile);
        //     // .filter(filter1)
        //     // .filter(filter2)
        //     .map(map1)
        //     .map(map2)
        //     .map(map3)
        //     .map(map4);
        // // pipeline.pipeMap(map3);
        // // pipeline.pipeMap(map4);
        // pipeline.applyToArray(array, function (x) sum += x);
        // trace(time() - s);
        // trace(sum);

        // trace("pipeline - traverser");
        // var s = time();
        // var sum = 0;
        // var pipeline = new Pipeline()
        // //pipeline.pipeTakeWhile(takeWhile);
        //     // .filter(filter1)
        //     // .filter(filter2)
        //     .map(map1)
        //     .map(map2)
        //     .map(map3)
        //     .map(map4);
        // // pipeline.pipeMap(map3);
        // // pipeline.pipeMap(map4);
        // pipeline.applyToTraverser(Traverser.fromArray(array), function (x) sum += x);
        // trace(time() - s);
        // trace(sum);

        // trace("pipeline - traverser2");
        // var s = time();
        // var sum = 0;
        // var pipeline = new Pipeline()
        // //pipeline.pipeTakeWhile(takeWhile);
        //     // .filter(filter1)
        //     // .filter(filter2)
        //     .map(map1)
        //     .map(map2)
        //     .map(map3)
        //     .map(map4);
        // var traverser = pipeline.createTraverser(Traverser.fromArray(array));
        // while (traverser.next()) {
        //     traverser.current.forEach(function (x) sum += x);
        // }
        // trace(time() - s);
        // trace(sum);

        trace("Enumerator");
        var s = time();
        var sum = 0;
        Enumerator.from(array)
            .map(map1)
            .map(map2)
            .map(map3)
            .map(map4)
            .forEach(function (x) sum += x);
        trace(time() - s);
        trace(sum);    }
}
*/