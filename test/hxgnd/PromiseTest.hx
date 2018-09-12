package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using hxgnd.LangTools;
using buddy.Should;

class PromiseTest extends BuddySuite {
    public function new() {
        describe("Promise.new()", {
            timeoutMs = 1000;

            it("should call", function (done) {
                new Promise(function (_, _) {
                    done();
                });
            });

            it("should be not completed", function (done) {
                new Promise(function (_, _) {}).then(
                    function (_) { fail(); done(); },
                    function (_) { fail(); done(); }
                );
                wait(5, function () done());
            });

            it("should be fulfilled when it call fulfill(_)", function (done) {
                new Promise(function (fulfill, _) {
                    fulfill();
                }).then(
                    function (_) {
                        done();
                    },
                    function (_) { fail(); done(); }
                );
                wait(5, function () done());
            });

            it("should be fulfilled when it call fulfill(x)", function (done) {
                new Promise(function (fulfill, _) {
                    fulfill(1);
                }).then(
                    function (x) {
                        x.should.be(1);
                        done();
                    },
                    function (_) { fail(); done(); }
                );
                wait(5, function () done());
            });

            it("should be rejected when it call reject(_)", function (done) {
                new Promise(function (_, reject) {
                    reject();
                }).then(
                    function (_) { fail(); done(); },
                    function (e) {
                        LangTools.isNull(e).should.be(true);
                        done();
                    }
                );
                wait(5, function () done());
            });

            it("should be rejected when it call reject(x)", function (done) {
                new Promise(function (_, reject) {
                    reject("error");
                }).then(
                    function (_) { fail(); done(); },
                    function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    }
                );
                wait(5, function () done());
            });

            it("should be rejected when it is thrown error", function (done) {
                new Promise(function (_, _) {
                    throw "error";
                }).then(
                    function (_) { fail(); done(); },
                    function (e) {
                        Std.is(e, Error).should.be(true);
                        (e: Error).message.should.be("error");
                        done();
                    }
                );
                wait(5, function () done());
            });

            #if js
            it("should be js.Promise", {
                var promise = new Promise(function (_, _) {});
                promise.should.beType(js.Promise);
            });
            #end
        });

        describe("Promise.resolve()", {
            timeoutMs = 1000;

            it("should be resolved when it call resolve(_)", function (done) {
                Promise.resolve().then(
                    function (_) {
                        done();
                    },
                    function (_) { fail(); done(); }
                );
                wait(5, function () done());
            });

            it("should be resolved when it call resolve(x)", function (done) {
                Promise.resolve(1).then(
                    function (x) {
                        x.should.be(1);
                        done();
                    },
                    function (_) { fail(); done(); }
                );
                wait(5, function () done());
            });
        });

        describe("Promise.then()/catchError() : already resolved", {
            timeoutMs = 1000;

            it("should call", function (done) {
                Promise.resolve(1).then(function (x) {
                    x.should.be(1);
                    done();
                });
            });

            it("should not call", function (done) {
                Promise.resolve(1).then(null, function (_) {
                    fail();
                    done();
                });
                Promise.resolve(1).catchError(function (_) {
                    fail();
                    done();
                });
                wait(5, function () done());
            });
        });

        describe("Promise.then()/catchError() : resolve async", {
            timeoutMs = 1000;

            it("should call", function (done) {
                new Promise(function (resolve, reject) {
                    wait(5, function () {
                        resolve(1);
                    });
                }).then(function (x) {
                    x.should.be(1);
                    done();
                });
            });

            it("should not call", function (done) {
                var promise = new Promise(function (resolve, reject) {
                    wait(5, function () {
                        resolve(1);
                    });
                });

                promise.then(null, function (_) {
                    fail();
                    done();
                });
                promise.catchError(function (_) {
                    fail();
                    done();
                });
                wait(10, function () done());
            });
        });

        describe("Promise.reject()", {
            timeoutMs = 1000;

            it("should be rejected when it call reject(x)", function (done) {
                Promise.reject("error").then(
                    function (_) { fail(); done(); },
                    function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    }
                );
                wait(5, function () done());
            });

            it("should be rejected when it call reject(_)", function (done) {
                Promise.reject().then(
                    function (_) { fail(); done(); },
                    function (e) {
                        LangTools.isNull(e).should.be(true);
                        done();
                    }
                );
                wait(5, function () done());
            });
        });

        describe("Promise.then()/catchError() : already rejected", {
            timeoutMs = 1000;

            it("should call - then", function (done) {
                Promise.reject("error").then(null, function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should call - catchError", function (done) {
                Promise.reject("error").catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should not call", function (done) {
                Promise.reject("error").then( function (_) {
                    fail();
                    done();
                });
                wait(5, function () done());
            });
        });

        describe("Promise.then()/catchError() : reject async", {
            timeoutMs = 1000;

            it("should call - then", function (done) {
                new Promise(function (_, reject) {
                    wait(5, function () {
                        reject("error");
                    });
                }).then(null, function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should call - catchError", function (done) {
                new Promise(function (_, reject) {
                    wait(5, function () {
                        reject("error");
                    });
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should not call", function (done) {
                new Promise(function (_, reject) {
                    wait(5, function () {
                        reject("error");
                    });
                }).then( function (_) {
                    fail();
                    done();
                });
                wait(10, function () done());
            });
        });

        describe("Promise.then() : throw error", {
            timeoutMs = 1000;

            it("should be rejected", function (done) {
                Promise.resolve(1).then(function (x) {
                    throw "error";
                }).catchError(function (e) {
                    Std.is(e, Error).should.be(true);
                    (e: Error).message.should.be("error");
                    done();
                });
            });
        });

        describe("Promise.catchError() : throw error", {
            timeoutMs = 1000;

            it("should be rejected", function (done) {
                Promise.reject("foo").catchError(function (x) {
                    throw "error";
                }).catchError(function (e) {
                    Std.is(e, Error).should.be(true);
                    (e: Error).message.should.be("error");
                    done();
                });
            });
        });

        describe("Promise.catchError() : recover", {
            timeoutMs = 1000;

            it("should be rejected", function (done) {
                Promise.reject("foo").catchError(function (x) {
                    return 100;
                }).then(function (x) {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("Promise.then() : chain callback", {
            timeoutMs = 1000;

            it("should chain value", function (done) {
                Promise.resolve(1).then(function (x) {
                    return x + 1;
                }).then(function (x) {
                    return x + 100;
                }).then(function (x) {
                    x.should.be(102);
                    done();
                });
            });

            it("should chain resolved Promise", function (done) {
                Promise.resolve(1).then(function (x) {
                    return Promise.resolve("hello");
                }).then(function (x) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected Promise", function (done) {
                Promise.resolve(1).then(function (x) {
                    return Promise.reject("error");
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });

            #if js
            it("should chain resolved js.Promise", function (done) {
                Promise.resolve(1).then(function (x) {
                    return js.Promise.resolve("hello");
                }).then(function (x) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected js.Promise", function (done) {
                Promise.resolve(1).then(function (x) {
                    return js.Promise.reject("error");
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            #end
        });

        describe("Promise.catchError() : chain callback", {
            timeoutMs = 1000;

            it("should chain value", function (done) {
                Promise.reject("error").catchError(function (e) {
                    return 1;
                }).then(function (x) {
                    return x + 100;
                }).then(function (x) {
                    x.should.be(101);
                    done();
                });
            });

            it("should chain resolved Promise", function (done) {
                Promise.reject("error").catchError(function (e) {
                    return Promise.resolve("hello");
                }).then(function (x) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected Promise", function (done) {
                Promise.reject("error").catchError(function (e) {
                    return Promise.reject("error chained");
                }).catchError(function (e) {
                    LangTools.same(e, "error chained").should.be(true);
                    done();
                });
            });

            it("should chain rejected Promise : throw error", function (done) {
                Promise.reject("error").catchError(function (e) {
                    throw "error chained";
                }).catchError(function (e) {
                    Std.is(e, Error).should.be(true);
                    (e: Error).message.should.be("error chained");
                    done();
                });
            });

            #if js
            it("should chain resolved js.Promise", function (done) {
                Promise.reject("error").catchError(function (e) {
                    return js.Promise.resolve("hello");
                }).then(function (x) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected js.Promise", function (done) {
                Promise.reject("error").catchError(function (e) {
                    return js.Promise.reject("error chained");
                }).catchError(function (e) {
                    LangTools.same(e, "error chained").should.be(true);
                    done();
                });
            });
            #end
        });

        #if js
        describe("Promise cast", {
            it("should cast from js.Promise", function (done) {
                var jsPromise = js.Promise.resolve(1);
                var promise: Promise<Int> = jsPromise;
                promise.then(function (v) {
                    v.should.be(1);
                    done();
                });
            });

            it("should cast to js.Promise", function (done) {
                var promise = Promise.resolve(1);
                var jsPromise: js.Promise<Int> = promise;
                jsPromise.then(function (v) {
                    LangTools.same(v, 1).should.be(true);
                    done();
                });
            });
        });
        #end

        describe("Promise.all()", {
            timeoutMs = 1000;

            it("should resolve empty array", function (done) {
                Promise.all([]).then(function (values) {
                    LangTools.same(values, []).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });

            it("should resolve", function (done) {
                Promise.all([
                    Promise.resolve(1)
                ]).then(function (values) {
                    LangTools.same(values, [1]).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });

            it("should reject", function (done) {
                Promise.all([
                    Promise.reject("error")
                ]).then(function (values) {
                    fail();
                    done();
                }, function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });

            it("should resolve ordered values", function (done) {
                Promise.all([
                    new Promise(function (f, _) {
                        wait(5, f.bind(1));
                    }),
                    Promise.resolve(2),
                    Promise.resolve(3)
                ]).then(function (values) {
                    LangTools.same(values, [1, 2, 3]).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });

            it("should reject by 2nd promise", function (done) {
                Promise.all([
                    new Promise(function (_, r) {
                        wait(5, r.bind("error1"));
                    }),
                    Promise.reject("error2"),
                    new Promise(function (_, r) {
                        wait(10, r.bind("error3"));
                    })
                ]).then(function (values) {
                    fail();
                    done();
                }, function (e) {
                    LangTools.same(e, "error2").should.be(true);
                    done();
                });
            });

            it("should reject by 3rd promise", function (done) {
                Promise.all([
                    Promise.resolve(1),
                    Promise.resolve(2),
                    Promise.reject("error3")
                ]).then(function (values) {
                    fail();
                    done();
                }, function (e) {
                    LangTools.same(e, "error3").should.be(true);
                    done();
                });
            });

            it("should process when it is mixed by Promise and SyncPromise", function(done) {
                Promise.all([
                    Promise.resolve(1),
                    SyncPromise.resolve(2)
                ]).then(function (values) {
                    LangTools.same(values, [1, 2]).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });
        });

        describe("Promise.race()", {
            timeoutMs = 1000;

            it("should be pending", function (done) {
                Promise.race([]).then(function (value) {
                    fail();
                    done();
                }, function (_) {
                    fail();
                    done();
                });
                wait(50, done);
            });

            it("should resolve", function (done) {
                Promise.race([
                    Promise.resolve(1)
                ]).then(function (value) {
                    LangTools.same(value, 1).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });

            it("should reject", function (done) {
                Promise.race([
                    Promise.reject("error")
                ]).then(function (value) {
                    fail();
                    done();
                }, function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });

            it("should resolve by 2nd promise", function (done) {
                Promise.race([
                    new Promise(function (f, _) {
                        wait(5, f.bind(1));
                    }),
                    Promise.resolve(2),
                    Promise.resolve(3)
                ]).then(function (value) {
                    LangTools.same(value, 2).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });

            it("should reject by 2nd promise", function (done) {
                Promise.race([
                    new Promise(function (_, r) {
                        wait(5, r.bind("error1"));
                    }),
                    Promise.reject("error2"),
                    new Promise(function (_, r) {
                        wait(10, r.bind("error3"));
                    })
                ]).then(function (value) {
                    fail();
                    done();
                }, function (e) {
                    LangTools.same(e, "error2").should.be(true);
                    done();
                });
            });

            it("should resolve by 1st promise", function (done) {
                Promise.race([
                    Promise.resolve(1),
                    Promise.resolve(2),
                    Promise.reject("error3")
                ]).then(function (value) {
                    LangTools.same(value, 1).should.be(true);
                    done();
                }, function (e) {
                    fail();
                    done();
                });
            });

            it("should process when it is mixed by Promise and SyncPromise", function(done) {
                Promise.race([
                    Promise.resolve(1),
                    SyncPromise.resolve(2)
                ]).then(function (values) {
                    LangTools.same(values, 1).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });
        });
    }
}