package hxgnd.js;

import utest.Assert;
import hxgnd.Error;
using hxgnd.js.PromiseTools;

class PromiseToolsTest {
    public function new() {}

    public function test_callAsPromise() {
        {
            function fnOK(callback: Error -> Int -> Void) {
                callback(null, 100);
            }
            function fnNG(callback: Error -> Int -> Void) {
                callback(new Error("error"), null);
            }

            var done1 = Assert.createAsync();
            fnOK.callAsPromise().then(function (x) {
                Assert.equals(100, x);
                done1();
            }).catchError(function (e) {
                Assert.fail();
                done1();
            });

            var done2 = Assert.createAsync();
            fnNG.callAsPromise().then(function (x) {
                Assert.fail();
                done2();
            }).catchError(function (e) {
                Assert.notNull(e);
                done2();
            });
        }

        {
            function fn1(flag: Bool, callback: Error -> Int -> Void) {
                if (flag) {
                    callback(null, 100);
                } else {
                    callback(new Error("error"), null);
                }
            }

            var done1 = Assert.createAsync();
            fn1.callAsPromise(true).then(function (x) {
                Assert.equals(100, x);
                done1();
            }).catchError(function (e) {
                Assert.fail();
                done1();
            });

            var done2 = Assert.createAsync();
            fn1.callAsPromise(false).then(function (x) {
                Assert.fail();
                done2();
            }).catchError(function (e) {
                Assert.notNull(e);
                done2();
            });
        }

        {
            function fn2(flag: Bool, v1: Int, v2: String, callback: Error -> Int -> String -> Void) {
                if (flag) {
                    callback(null, v1, v2);
                } else {
                    callback(new Error("error"), null, null);
                }
            }

            var done1 = Assert.createAsync();
            fn2.callAsPromise(true, 500, "hello").then(function (x) {
                Assert.same({
                    value1: 500,
                    value2: "hello"
                }, x);
                done1();
            }).catchError(function (e) {
                Assert.fail();
                done1();
            });

            var done2 = Assert.createAsync();
            fn2.callAsPromise(false, 300, "hello").then(function (x) {
                Assert.fail();
                done2();
            }).catchError(function (e) {
                Assert.notNull(e);
                done2();
            });
        }

    }
}