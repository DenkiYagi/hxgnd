package;

import buddy.*;

class TestMain implements Buddy<[
    hxgnd.LangToolsTest,
    hxgnd.ArrayToolsTest,
    hxgnd.MaybeTest,
    hxgnd.StreamTest,
    hxgnd.PromiseLikeTest,
    #if js
    hxgnd.js.PromiseToolsTest,
    #end
]> {}
