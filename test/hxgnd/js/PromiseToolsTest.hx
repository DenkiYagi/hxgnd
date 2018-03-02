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

    public function test_callAsPromiseUnsafe() {
        {
            function fnOK(callback: Error -> Int -> Void) {
                callback(null, 100);
            }
            function fnNG(callback: Error -> Int -> Void) {
                callback(new Error("error"), null);
            }

            var done1 = Assert.createAsync();
            fnOK.callAsPromiseUnsafe().then(function (x) {
                Assert.equals(100, x);
                done1();
            }).catchError(function (e) {
                Assert.fail();
                done1();
            });

            var done2 = Assert.createAsync();
            fnNG.callAsPromiseUnsafe().then(function (x) {
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
            fn1.callAsPromiseUnsafe(true).then(function (x) {
                Assert.equals(100, x);
                done1();
            }).catchError(function (e) {
                Assert.fail();
                done1();
            });

            var done2 = Assert.createAsync();
            fn1.callAsPromiseUnsafe(false).then(function (x) {
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
            fn2.callAsPromiseUnsafe(true, 500, "hello").then(function (x) {
                Assert.same([500, "hello"], x);
                done1();
            }).catchError(function (e) {
                Assert.fail();
                done1();
            });

            var done2 = Assert.createAsync();
            fn2.callAsPromiseUnsafe(false, 300, "hello").then(function (x) {
                Assert.fail();
                done2();
            }).catchError(function (e) {
                Assert.notNull(e);
                done2();
            });
        }
    }

    public function test_await() {
        function fnOK(callback: Error -> Int -> Void) {
            callback(null, 100);
        }
        function fnNG(callback: Error -> Int -> Void) {
            callback(new Error("error"), null);
        }

        var done = Assert.createAsync();
        function () {
            Assert.equals(100, fnOK.callAsPromise().await());

            try {
                fnNG.callAsPromise().await();
                Assert.fail();
            } catch (e: Dynamic) {
                Assert.is(e, js.Error);
            }
            done();
        }.asyncCall();
    }

    public function test_async_with_function_name() {
        function fn1() {}.async();
        var done1 = Assert.createAsync();
        fn1().then(function (_) {
            Assert.pass();
            done1();
        });
        
        function fn2() { return 1; }.async();
        var done2 = Assert.createAsync();
        fn2().then(function (x) {
            Assert.equals(1, x);
            done2();
        });

        function fn3(x: String) { return x; }.async();
        var done3 = Assert.createAsync();
        fn3("hello").then(function (x) {
            Assert.equals("hello", x);
            done3();
        });

        function fn4(a: Int, b: Int) { return a * b; }.async();
        var done4 = Assert.createAsync();
        fn4(2, 3).then(function (x) {
            Assert.equals(6, x);
            done4();
        });

        function fn5(a: Int) { 
            function f(n) {
                return n + n;
            }
            var x = a * 100;
            var y = a + 50;
            var z = f(a);
            return x + y + z;
        }.async();
        var done5 = Assert.createAsync();
        fn5(2).then(function (x) {
            Assert.equals(256, x);
            done5();
        });
    }

    public function test_async_without_function_name() {
        var done1 = Assert.createAsync();
        function () {}.async()().then(function (_) {
            Assert.pass();
            done1();
        });
        
        var done2 = Assert.createAsync();
        function () { return 1; }.async()().then(function (x) {
            Assert.equals(1, x);
            done2();
        });

        var done3 = Assert.createAsync();
        function (x: String) { return x; }.async()("hello").then(function (x) {
            Assert.equals("hello", x);
            done3();
        });

        var done4 = Assert.createAsync();
        function (a: Int, b: Int) { return a * b; }.async()(2, 3).then(function (x) {
            Assert.equals(6, x);
            done4();
        });

        var done5 = Assert.createAsync();
        function (a: Int) { 
            function f(n) {
                return n + n;
            }
            var x = a * 100;
            var y = a + 50;
            var z = f(a);
            return x + y + z;
        }.async()(2).then(function (x) {
            Assert.equals(256, x);
            done5();
        });
    }

    public function test_asyncCall() {
        var done1 = Assert.createAsync();
        function () {}.asyncCall().then(function (_) {
            Assert.pass();
            done1();
        });
        
        var done2 = Assert.createAsync();
        function () { return 1; }.asyncCall().then(function (x) {
            Assert.equals(1, x);
            done2();
        });

        var done3 = Assert.createAsync();
        function (x: String) { return x; }.asyncCall("hello").then(function (x) {
            Assert.equals("hello", x);
            done3();
        });

        var done4 = Assert.createAsync();
        function (a: Int, b: Int) { return a * b; }.asyncCall(2, 3).then(function (x) {
            Assert.equals(6, x);
            done4();
        });

        var done5 = Assert.createAsync();
        function (a: Int) { 
            function f(n) {
                return n + n;
            }
            var x = a * 100;
            var y = a + 50;
            var z = f(a);
            return x + y + z;
        }.asyncCall(2).then(function (x) {
            Assert.equals(256, x);
            done5();
        });

        var done6 = Assert.createAsync();
        function test() {}.asyncCall().then(function (_) {
            Assert.pass();
            done6();
        });
    }
}
