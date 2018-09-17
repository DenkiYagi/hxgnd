package hxgnd;

import buddy.BuddySuite;
import hxgnd.Error;
using buddy.Should;
using hxgnd.PromiseTools;

class PromiseToolsTest extends BuddySuite {
    public function new() {
        describe("PromiseTools.callAsPromise()", {
            // TODO single arg

            describe("2 args callback", {
                it("sholud be resolved", function (done) {
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

                it("sholud be rejected", function (done) {
                    function fnNG(callback: Error -> Int -> Void) {
                        callback(new Error("error"), null);
                    }
                    fnNG.callAsPromise().then(function (x) {
                        trace(x);
                        fail();
                        done();
                    }).catchError(function (e) {
                        Std.is(e, Error).should.be(true);
                        done();
                    });
                });
            });

            describe("3 args callback and other args", {
                it("sholud be resolved", function (done) {
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

                it("sholud be rejected", function (done) {
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
                        Std.is(e, Error).should.be(true);
                        done();
                    });
                });
            });

            describe("2 args with type-parameter", {
                it("sholud be resolved", function (done) {
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

                it("sholud be rejected", function (done) {
                    function (callback: Callback2<Int>) {
                        callback(new Error(""), null);
                    }.callAsPromise().then(function (x) {
                        fail();
                        done();
                    }).catchError(function (e) {
                        Std.is(e, Error).should.be(true);
                        done();
                    });
                });
            });

            describe("3 args with type-alias", {
                it("sholud be resolved", function (done) {
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

                it("sholud be rejected", function (done) {
                    function (callback: CB3<Int, String>) {
                        callback(new Error(""), null, null);
                    }.callAsPromise().then(function (x) {
                        fail();
                        done();
                    }).catchError(function (e) {
                        Std.is(e, Error).should.be(true);
                        done();
                    });
                });
            });
        });

        describe("PromiseTools.callAsPromiseUnsafe()", {
            // TODO single arg

            describe("2 args callback", {
                it("sholud be resolved", function (done) {
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

                it("sholud be rejected", function (done) {
                    function fnNG(callback: Error -> Int -> Void) {
                        callback(new Error("error"), null);
                    }
                    fnNG.callAsPromiseUnsafe().then(function (x) {
                        fail();
                        done();
                    }).catchError(function (e) {
                        Std.is(e, Error).should.be(true);
                        done();
                    });
                });
            });

            describe("3 args callback and other args", {
                it("sholud be resolved", function (done) {
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

                it("sholud be rejected", function (done) {
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
                        Std.is(e, Error).should.be(true);
                        done();
                    });
                });
            });
        });
    }
}

typedef Callback2<T> = Error -> T -> Void;
typedef Callback3<T1, T2> = Error -> T1 -> T2 -> Void;
typedef CB3<T1, T2> = Callback3<T1, T2>;