package;

import buddy.*;

class TestMain implements Buddy<[
    hxgnd.LangToolsTest,
    hxgnd.ArrayToolsTest,
    hxgnd.MaybeTest,
    hxgnd.StreamTest,
    hxgnd.SyncPromiseTest,
    hxgnd.FutureTest,
    #if js
    hxgnd.js.PromiseToolsTest,
    #end
]> {}
