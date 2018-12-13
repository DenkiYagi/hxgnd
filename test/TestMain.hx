package;

import buddy.*;

// class TestMain implements Buddy<[
//     // hxgnd.LangToolsTest,
//     // hxgnd.ArrayToolsTest,
//     // hxgnd.OptionToolsTest,
//     // hxgnd.LazyTest,
//     // hxgnd.DelegateTest,
//     // hxgnd.ComputationTest,
//     // hxgnd.PromiseTest,
//     // hxgnd.SyncPromiseTest,
//     // hxgnd.AbortablePromiseTest,
//     // hxgnd.CallbackFlowTest,
//     // hxgnd.NodebackFlowTest,
//     hxgnd.ReactorTest,
//     // hxgnd.ReactivePropertyTest,
//     // hxgnd.ReactiveActorTest,
//     // hxgnd.ReactiveStreamTest
// ]> {}

import hxgnd.Enumerator;

class TestMain {
    public static function main() {
        Enumerator.from([1, 2, 3])
            .map(function (x) return x * 10)
            .flatMap(function (x): EnumeratorSource<Int> return [x, x + 1, x + 2])
            .flatMap(function (x): EnumeratorSource<Int> return [x, -x])
            .forEach(function (x) trace(x));
    }
}