package hxgnd.js;

import buddy.BuddySuite;
import hxgnd.Error;
using buddy.Should;
using hxgnd.js.PromiseTools;

class PromiseToolsTest extends BuddySuite {
    public function new() {
        describe("PromiseTools.callAsPromise()", {
            it("sholud be resolved - 2 args callback", function (done) {
                function fnOK(callback: Error -> Int -> Void) {
                    callback(null, 100);
                }
                fnOK.callAsPromise().then(function (x: Int) {
                    x.should.be(100);
                    done();
                }).catchError(function (e) {
                    fail();
                    done();
                });
            });

            it("sholud be rejected - 2 args callback", function (done) {
                function fnNG(callback: Error -> Int -> Void) {
                    callback(new Error("error"), null);
                }
                fnNG.callAsPromise().then(function (x) {
                    fail();
                    done();
                }).catchError(function (e) {
                    Std.is(e, js.Error).should.be(true);
                    done();
                });
            });

            it("sholud be resolved - 3 args callback and other args", function (done) {
                function fn(flag: Bool, v1: Int, v2: String, callback: Error -> Int -> String -> Void) {
                    if (flag) {
                        callback(null, v1, v2);
                    } else {
                        callback(new Error("error"), null, null);
                    }
                }
                
                fn.callAsPromise(true, 500, "hello").then(function (x) {
                    LangTools.same(x, {
                        value1: 500,
                        value2: "hello"
                    }).should.be(true);
                    done();
                }).catchError(function (e) {
                    fail();
                    done();
                });
            });

            it("sholud be rejected - 3 args callback and other args", function (done) {
                function fn(flag: Bool, v1: Int, v2: String, callback: Error -> Int -> String -> Void) {
                    if (flag) {
                        callback(null, v1, v2);
                    } else {
                        callback(new Error("error"), null, null);
                    }
                }
                
                fn.callAsPromise(false, 500, "hello").then(function (x) {
                    fail();
                    done();
                }).catchError(function (e) {
                    Std.is(e, js.Error).should.be(true);
                    done();
                });
            });

            it("sholud be resolved - 2 args with type-parameter", function (done) {
                function (callback: Callback2<Int>) {
                    callback(null, 1);
                }.callAsPromise().then(function (x) {
                    LangTools.same(x, 1).should.be(true);
                    done();
                }).catchError(function (e) {
                    fail();
                    done();
                });
            });

            it("sholud be rejected - 2 args with type-parameter", function (done) {
                function (callback: Callback2<Int>) {
                    callback(new js.Error(""), null);
                }.callAsPromise().then(function (x) {
                    fail();
                    done();
                }).catchError(function (e) {
                    Std.is(e, js.Error).should.be(true);
                    done();
                });
            });

            it("sholud be resolved - 3 args with type-alias", function (done) {
                function (callback: CB3<Int, String>) {
                    callback(null, 3, "bar");
                }.callAsPromise().then(function (x) {
                    LangTools.same(x, {
                        value1: 3,
                        value2: "bar"
                    }).should.be(true);
                    done();
                }).catchError(function (e) {
                    fail();
                    done();
                });
            });

            it("sholud be rejected - 3 args with type-alias", function (done) {
                function (callback: CB3<Int, String>) {
                    callback(new js.Error(""), null, null);
                }.callAsPromise().then(function (x) {
                    fail();
                    done();
                }).catchError(function (e) {
                    Std.is(e, js.Error).should.be(true);
                    done();
                });
            });
        });

        describe("PromiseTools.callAsPromiseUnsafe()", {
            it("sholud be resolved - 2 args callback", function (done) {
                function fnOK(callback: Error -> Int -> Void) {
                    callback(null, 100);
                }
                fnOK.callAsPromiseUnsafe().then(function (x: Int) {
                    x.should.be(100);
                    done();
                }).catchError(function (e) {
                    fail();
                    done();
                });
            });

            it("sholud be rejected - 2 args callback", function (done) {
                function fnNG(callback: Error -> Int -> Void) {
                    callback(new Error("error"), null);
                }
                fnNG.callAsPromiseUnsafe().then(function (x) {
                    fail();
                    done();
                }).catchError(function (e) {
                    Std.is(e, js.Error).should.be(true);
                    done();
                });
            });

            it("sholud be resolved - 3 args callback and other args", function (done) {
                function fn(flag: Bool, v1: Int, v2: String, callback: Error -> Int -> String -> Void) {
                    if (flag) {
                        callback(null, v1, v2);
                    } else {
                        callback(new Error("error"), null, null);
                    }
                }
                
                fn.callAsPromiseUnsafe(true, 500, "hello").then(function (x) {
                    LangTools.same(x, [500, "hello"]).should.be(true);
                    done();
                }).catchError(function (e) {
                    fail();
                    done();
                });
            });

            it("sholud be rejected - 3 args callback and other args", function (done) {
                function fn(flag: Bool, v1: Int, v2: String, callback: Error -> Int -> String -> Void) {
                    if (flag) {
                        callback(null, v1, v2);
                    } else {
                        callback(new Error("error"), null, null);
                    }
                }
                
                fn.callAsPromiseUnsafe(false, 500, "hello").then(function (x) {
                    fail();
                    done();
                }).catchError(function (e) {
                    Std.is(e, js.Error).should.be(true);
                    done();
                });
            });
        });

        describe("PromiseTools.async()", {
            it("should convert Void -> Void", function (done) {
                function fn() {}.async();
                fn().then(function (_) {
                    done();
                });
            });
            it("should convert Void -> Void : anonymous", function (done) {
                function () {}.async()().then(function (_) {
                    done();
                });
            });

            it("should convert Void -> Int", function (done) {
                function fn() { return 1; }.async();
                fn().then(function (x) {
                    LangTools.same(x, 1).should.be(true);
                    done();
                });
            });
            it("should convert Void -> Int : anonymous", function (done) {
                function () { return 1; }.async()().then(function (x) {
                    LangTools.same(x, 1).should.be(true);
                    done();
                });
            });

            it("should convert String -> String", function (done) {
                function fn(x: String) { return x; }.async();
                fn("hello").then(function (x) {
                    LangTools.same(x, "hello").should.be(true);
                    done();
                });
            });
            it("should convert String -> String : anonymous", function (done) {
                function (x: String) { return x; }.async()("hello").then(function (x) {
                    LangTools.same(x, "hello").should.be(true);
                    done();
                });
            });

            it("should convert Int -> Int -> Int", function (done) {
                function fn(a: Int, b: Int) { return a * b; }.async();
                fn(2, 3).then(function (x) {
                    LangTools.same(x, 6).should.be(true);
                    done();
                });
            });
            it("should convert Int -> Int -> Int : anonymous", function (done) {
                function (a: Int, b: Int) { return a * b; }.async()(2, 3).then(function (x) {
                    LangTools.same(x, 6).should.be(true);
                    done();
                });
            });
        });

        describe("PromiseTools.asyncCall()", {
            it("should convert Void -> Void", function (done) {
                function () {}.asyncCall().then(function (_) {
                    done();
                });
            });

            it("should convert Void -> Int", function (done) {
                function () { return 1; }.asyncCall().then(function (x) {
                    LangTools.same(x, 1).should.be(true);
                    done();
                });
            });

            it("should convert String -> String", function (done) {
                function (x: String) { return x; }.asyncCall("hello").then(function (x) {
                    LangTools.same(x, "hello").should.be(true);
                    done();
                });
            });

            it("should convert Int -> Int -> Int", function (done) {
                function (a: Int, b: Int) { return a * b; }.asyncCall(2, 3).then(function (x) {
                    LangTools.same(x, 6).should.be(true);
                    done();
                });
            });
        });

        describe("PromiseTools.await()", {
            it("sholud be resolved", function (done) {
                function fn(callback: Error -> Int -> Void) {
                    callback(null, 100);
                }

                function assert(result) {
                    LangTools.same(result, 100).should.be(true);
                    done();
                }

                function () {
                    var result = fn.callAsPromise().await();
                    assert(result);
                }.asyncCall();
            });

            it("sholud be rejected", function (done) {
                function fn(callback: Error -> Int -> Void) {
                    callback(new js.Error(""), null);
                }

                function assert(error) {
                    Std.is(error, js.Error).should.be(true);
                    done();
                }

                function () {
                    try {
                        fn.callAsPromise().await();
                        fail();
                        done();
                    } catch (e: Dynamic) {
                        assert(e);
                    }
                }.asyncCall();
            });
        });
    }
}

typedef Callback2<T> = Error -> T -> Void;
typedef Callback3<T1, T2> = Error -> T1 -> T2 -> Void;
typedef CB3<T1, T2> = Callback3<T1, T2>;