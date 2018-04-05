package hxgnd;

import buddy.BuddySuite;
import buddy.tools.AsyncTools.wait;
import hxgnd.Result;
using hxgnd.LangTools;
using buddy.Should;

class PromiseLikeTest extends BuddySuite {
    public function new() {
        describe("PromiseLike.new()", {
            it("should call", function (done) {
                new PromiseLike(function (_, _) {
                    done();
                });
            });
            
            it("should be empty", {
                var promise = new PromiseLike(function (_, _) {});
                promise.result.isEmpty().should.be(true);
            });

            it("should rejected", {
                var promise = new PromiseLike(function (_, _) {
                    throw "error";
                });
                promise.result.same(Maybe.of(Failed("error"))).should.be(true);
            });
        });

        describe("Promise.resolve()", {
            it("should be resolved", {
                var promise = PromiseLike.resolve(1);
                promise.result.same(Maybe.of(Success(1))).should.be(true);
            });
        });

        describe("Promise.reject()", {
            it("should be rejected", {
                var promise = PromiseLike.reject("error");
                promise.result.same(Maybe.of(Failed("error"))).should.be(true);
            });
        });

        describe("PromiseLike.then()/catchError() : already resolved", {
            it("should call", function (done) {
                PromiseLike.resolve(1).then(function (x: Int) {
                    x.should.be(1);
                    done();
                });
            });

            it("should not call", function (done) {
                PromiseLike.resolve(1).then(null, function (_) {
                    fail();
                    done();
                });
                PromiseLike.resolve(1).catchError(function (_) {
                    fail();
                    done();
                });
                wait(10).then(function (_) done());
            });
        });

        describe("PromiseLike.then()/catchError() : resolve async", {
            it("should call", function (done) {
                new PromiseLike(function (resolve, reject) {
                    wait(5).then(function (_) {
                        resolve(1);
                    });
                }).then(function (x: Int) {
                    x.should.be(1);
                    done();
                });
            });
            
            it("should not call", function (done) {
                var promise = new PromiseLike(function (resolve, reject) {
                    wait(5).then(function (_) {
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
                wait(10).then(function (_) done());
            });
        });

        describe("PromiseLike.then()/catchError() : already rejected", {
            it("should call - then", function (done) {
                PromiseLike.reject("error").then(null, function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should call - catchError", function (done) {
                PromiseLike.reject("error").catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should not call", function (done) {
                PromiseLike.reject("error").then( function (_) {
                    fail();
                    done();
                });
                wait(10).then(function (_) done());
            });
        });

        describe("PromiseLike.then()/catchError() : reject async", {
            it("should call - then", function (done) {
                new PromiseLike(function (_, reject) {
                    wait(5).then(function (_) {
                        reject("error");
                    });
                }).then(null, function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should call - catchError", function (done) {
                new PromiseLike(function (_, reject) {
                    wait(5).then(function (_) {
                        reject("error");
                    });
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            it("should not call", function (done) {
                new PromiseLike(function (_, reject) {
                    wait(5).then(function (_) {
                        reject("error");
                    });
                }).then( function (_) {
                    fail();
                    done();
                });
                wait(10).then(function (_) done());
            });
        });

        describe("PromiseLike.then() : throw error", {
            it("should be rejected", function (done) {
                PromiseLike.resolve(1).then(function (x) {
                    throw "error";
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
        });

        describe("PromiseLike.catchError() : throw error", {
            it("should be rejected", function (done) {
                PromiseLike.reject("foo").catchError(function (x) {
                    throw "error";
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
        });

        describe("PromiseLike.catchError() : recover", {
            it("should be rejected", function (done) {
                PromiseLike.reject("foo").catchError(function (x) {
                    return 100;
                }).then(function (x: Int) {
                    x.should.be(100);
                    done();
                });
            });
        });

        describe("PromiseLike.then() : chain", {
            it("should chain value", function (done) {
                PromiseLike.resolve(1).then(function (x) {
                    return x + 1;
                }).then(function (x: Int) {
                    return x + 100;
                }).then(function (x: Int) {
                    x.should.be(102);
                    done();
                });
            });
            
            it("should chain resolved PromiseLike", function (done) {
                PromiseLike.resolve(1).then(function (x) {
                    return PromiseLike.resolve("hello");
                }).then(function (x: String) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected PromiseLike", function (done) {
                PromiseLike.resolve(1).then(function (x) {
                    return PromiseLike.reject("error");
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });

            #if js
            it("should chain resolved js.Promise", function (done) {
                PromiseLike.resolve(1).then(function (x) {
                    return js.Promise.resolve("hello");
                }).then(function (x: String) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected js.Promise", function (done) {
                PromiseLike.resolve(1).then(function (x) {
                    return js.Promise.reject("error");
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            #end
        });

        describe("PromiseLike.catchError() : chain", {
            it("should chain value", function (done) {
                PromiseLike.reject("error").catchError(function (e) {
                    return 1;
                }).then(function (x: Int) {
                    return x + 100;
                }).then(function (x: Int) {
                    x.should.be(101);
                    done();
                });
            });
            
            it("should chain resolved PromiseLike", function (done) {
                PromiseLike.reject("error").catchError(function (e) {
                    return PromiseLike.resolve("hello");
                }).then(function (x: String) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected PromiseLike", function (done) {
                PromiseLike.reject("error").catchError(function (e) {
                    return PromiseLike.reject("error");
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });

            #if js
            it("should chain resolved js.Promise", function (done) {
                PromiseLike.reject("error").catchError(function (e) {
                    return js.Promise.resolve("hello");
                }).then(function (x: String) {
                    x.should.be("hello");
                    done();
                });
            });

            it("should chain rejected js.Promise", function (done) {
                PromiseLike.reject("error").catchError(function (e) {
                    return js.Promise.reject("error");
                }).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
            #end
        });

        #if js
        describe("PromiseLike.toPromise(native = false)", {
            it("should be instanceof PromiseLike", {
                var promise = PromiseLike.resolve(1).toPromise(false);
                Std.is(promise, PromiseLike).should.be(true);
                Std.is(promise, js.Promise).should.be(false);
            });

            it("should call then()", function (done) {
                PromiseLike.resolve(1).toPromise(false).then(function (x: Int) {
                    x.should.be(1);
                    done();
                });
            });

            it("should call catchError()", function (done) {
                PromiseLike.reject("error").toPromise(false).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
        });

        describe("PromiseLike.toPromise(native = true)", {
            it("should be instanceof Promise", {
                var promise = PromiseLike.resolve(1).toPromise(true);
                Std.is(promise, js.Promise).should.be(true);
                Std.is(promise, PromiseLike).should.be(false);
            });

            it("should call then()", function (done) {
                PromiseLike.resolve(1).toPromise(true).then(function (x: Int) {
                    x.should.be(1);
                    done();
                });
            });

            it("should call catchError()", function (done) {
                PromiseLike.reject("error").toPromise(true).catchError(function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });
        });
        #end
    }
}