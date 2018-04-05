package;

import buddy.*;

class TestMain implements Buddy<[
    hxgnd.LangToolsTest,
    hxgnd.ArrayToolsTest,
    hxgnd.MaybeTest,
    hxgnd.StreamTest,
    #if js
    hxgnd.js.PromiseToolsTest,
    hxgnd.js.PromiseLikeTest,
    #end
]> {}
