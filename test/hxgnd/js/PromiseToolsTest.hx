package hxgnd.js;

import utest.Assert;
import hxgnd.Error;
using hxgnd.js.PromiseTools;

class PromiseToolsTest {
    public function new() {}

    public function test_callAsPromise() {
        function fn(flag: Bool, callback: Error -> Int -> Void) {
            if (flag) {
                callback(null, 100);
            } else {
                callback(new Error("error"), null);
            }
        }

        {
            var done = Assert.createAsync();
            fn.callAsPromise([true]).then(function (x) {
                Assert.equals(100, x);
                done();
            }).catchError(function (e) {
                Assert.fail();
                done();
            });
        }

        {
            var done = Assert.createAsync();
            fn.callAsPromise([false]).then(function (x) {
                Assert.fail();
                done();
            }).catchError(function (e) {
                Assert.notNull(e);
                done();
            });
        }
    }
}