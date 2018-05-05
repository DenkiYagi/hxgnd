package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
import hxgnd.Result;
using hxgnd.LangTools;
using buddy.Should;

class SyncPromiseTest extends BuddySuite {
    public function new() {
        describe("SyncPromise.new()", {
            timeoutMs = 1000;

            it("should call", function (done) {
                new SyncPromise(function (_, _) {
                    done();
                });
            });

            it("should be empty", {
                var promise = new SyncPromise(function (_, _) {});
                promise.result.isEmpty().should.be(true);
            });

            it("should rejected", {
                var promise = new SyncPromise(function (_, _) {
                    throw "error";
                });
                promise.result.same(Maybe.of(Failure("error"))).should.be(true);
            });
        });

        describe("Promise.resolve()", {
            timeoutMs = 1000;

            it("should be resolved", {
                var promise = SyncPromise.resolve(1);
                promise.result.same(Maybe.of(Success(1))).should.be(true);
            });
        });

        describe("Promise.reject()", {
            timeoutMs = 1000;

            it("should be rejected", {
                var promise = SyncPromise.reject("error");
                promise.result.same(Maybe.of(Failure("error"))).should.be(true);
            });
        });

        describe("SyncPromise.then()/catchError() : already resolved", {
            timeoutMs = 1000;

            it("should call", function (done) {
                SyncPromise.resolve(1).then(function (x: Int) {
                    x.should.be(1);
                    done();
                });
            });

            it("should not call", function (done) {
                SyncPromise.resolve(1).then(null, function (_) {
                    fail();
                    done();
                });
                SyncPromise.resolve(1).catchError(function (_) {
                    fail();
                    done();
                });
                wait(5, function () done());
            });
        });

        describe("SyncPromise.then()/catchError() : resolve async", {
            timeoutMs = 1000;

            it("should call", function (done) {
                new SyncPromise(function (resolve, reject) {
                    wait(5, function () {
                        resolve(1);
                    });
                }).then(function (x: Int) {
                    x.should.be(1);
                    done();
                });
            });

            it("should not call", function (done) {
                var promise = new SyncPromise(function (resolve, reject) {
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

        describe("SyncPromise.then()/catchError() : already rejected", {
            timeoutMs = 1000;

            it("should call - then", function (done) {
                SyncPromise.reject("error").then(null, function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should call - catchError", function (done) {
                SyncPromise.reject("error").catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should not call", function (done) {
                SyncPromise.reject("error").then( function (_) {
                    fail();
                    done();
                });
                wait(5, function () done());
            });
        });

        describe("SyncPromise.then()/catchError() : reject async", {
            timeoutMs = 1000;

            it("should call - then", function (done) {
                new SyncPromise(function (_, reject) {
                    wait(5, function () {
                        reject("error");
                    });
                }).then(null, function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should call - catchError", function (done) {
                new SyncPromise(function (_, reject) {
                    wait(5, function () {
                        reject("error");
                    });
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should not call", function (done) {
                new SyncPromise(function (_, reject) {
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

        describe("SyncPromise.then() : throw error", {
            timeoutMs = 1000;

            it("should be rejected", function (done) {
                SyncPromise.resolve(1).then(function (x) {
                    throw "error";
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
        });

        describe("SyncPromise.catchError() : throw error", {
            timeoutMs = 1000;

            it("should be rejected", function (done) {
                SyncPromise.reject("foo").catchError(function (x) {
                    throw "error";
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
        });

        describe("SyncPromise.catchError() : recover", {
            timeoutMs = 1000;

            it("should be rejected", function (done) {
                SyncPromise.reject("foo").catchError(function (x) {
                    return 100;
                }).then(function (x: Int) {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("SyncPromise.then() : chain", {
            timeoutMs = 1000;

            it("should chain value", function (done) {
                SyncPromise.resolve(1).then(function (x) {
                    return x + 1;
                }).then(function (x: Int) {
                    return x + 100;
                }).then(function (x: Int) {
                    x.should.be(102);
                    done();
                });
            });

            it("should chain resolved SyncPromise", function (done) {
                SyncPromise.resolve(1).then(function (x) {
                    return SyncPromise.resolve("hello");
                }).then(function (x: String) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected SyncPromise", function (done) {
                SyncPromise.resolve(1).then(function (x) {
                    return SyncPromise.reject("error");
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });

            #if js
            it("should chain resolved js.Promise", function (done) {
                SyncPromise.resolve(1).then(function (x) {
                    return js.Promise.resolve("hello");
                }).then(function (x: String) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected js.Promise", function (done) {
                SyncPromise.resolve(1).then(function (x) {
                    return js.Promise.reject("error");
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            #end
        });

        describe("SyncPromise.catchError() : chain", {
            timeoutMs = 1000;

            it("should chain value", function (done) {
                SyncPromise.reject("error").catchError(function (e) {
                    return 1;
                }).then(function (x: Int) {
                    return x + 100;
                }).then(function (x: Int) {
                    x.should.be(101);
                    done();
                });
            });

            it("should chain resolved SyncPromise", function (done) {
                SyncPromise.reject("error").catchError(function (e) {
                    return SyncPromise.resolve("hello");
                }).then(function (x: String) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected SyncPromise", function (done) {
                SyncPromise.reject("error").catchError(function (e) {
                    return SyncPromise.reject("error");
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });

            #if js
            it("should chain resolved js.Promise", function (done) {
                SyncPromise.reject("error").catchError(function (e) {
                    return js.Promise.resolve("hello");
                }).then(function (x: String) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected js.Promise", function (done) {
                SyncPromise.reject("error").catchError(function (e) {
                    return js.Promise.reject("error");
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            #end
        });

        #if js
        describe("SyncPromise.toPromise(native = false)", {
            timeoutMs = 1000;

            it("should be instanceof SyncPromise", {
                var promise = SyncPromise.resolve(1).toPromise(false);
                Std.is(promise, SyncPromise).should.be(true);
                Std.is(promise, js.Promise).should.be(true);
            });

            it("should call then()", function (done) {
                SyncPromise.resolve(1).toPromise(false).then(function (x: Int) {
                    x.should.be(1);
                    done();
                });
            });

            it("should call catchError()", function (done) {
                SyncPromise.reject("error").toPromise(false).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
        });

        describe("SyncPromise.toPromise(native = true)", {
            timeoutMs = 1000;

            it("should be instanceof Promise", {
                var promise = SyncPromise.resolve(1).toPromise(true);
                Std.is(promise, js.Promise).should.be(true);
                Std.is(promise, SyncPromise).should.be(false);
            });

            it("should call then()", function (done) {
                SyncPromise.resolve(1).toPromise(true).then(function (x: Int) {
                    x.should.be(1);
                    done();
                });
            });

            it("should call catchError()", function (done) {
                SyncPromise.reject("error").toPromise(true).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
        });
        #end
    }
}