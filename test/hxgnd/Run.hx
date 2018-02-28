package hxgnd;

using hxgnd.js.PromiseTools;

class Run {
    public static function main() {
        function fnOK(callback: Error -> Int -> String -> Void) {
            callback(null, 100, "hello");
        }
        function fnNG(callback: Error -> Int -> Void) {
            callback(new Error("error"), null);
        }

        fnOK.callAsPromise().then(function (ret) {
            trace(ret.value1);
            trace(ret.value2);
            //trace(x.value1);
        }).catchError(function (e) {
            trace(e);
        });
    }
}