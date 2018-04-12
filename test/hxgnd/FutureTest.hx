package hxgnd;

import buddy.BuddySuite;
import buddy.tools.AsyncTools.wait;
import hxgnd.Result;
using hxgnd.LangTools;
using buddy.Should;

class FutureTest extends BuddySuite {
    public function new() {
        describe("Future.new()", {
            timeoutMs = 1000;

            it("should call", function (done) {
                new Future(function (_, _) {
                    done();
                    return function () {};
                }, false);
            });

            it("should be empty", {
                var future = new Future(function (_, _) {
                    return function () {};
                }, false);
                future.isActive.should.be(true);
                future.result.isEmpty().should.be(true);
            });

            it("should rejected", {
                var future = new Future(function (_, _) {
                    throw "error";
                }, false);
                future.isActive.should.be(false);
                future.result.same(Maybe.of(Failed("error"))).should.be(true);
            });
        });
        describe("Future(async).new()", {
            timeoutMs = 1000;

            it("should call", function (done) {
                new Future(function (_, _) {
                    done();
                    return function () {};
                }, false);
            });

            it("should be empty", {
                var future = new Future(function (_, _) {
                    return function () {};
                }, true);
                future.isActive.should.be(true);
                future.result.isEmpty().should.be(true);
            });

            it("should rejected", function (done) {
                var future = new Future(function (_, _) {
                    #if neko
                    Sys.sleep(0.01);
                    #end
                    throw "error";
                }, true);
                future.isActive.should.be(true);
                future.result.isEmpty().should.be(true);

                future.then(function (result: Result<Dynamic>) {
                    result.same(Failed("error")).should.be(true);
                    result.same(future.result).should.be(true);
                    future.isActive.should.be(false);
                    done();
                });
            });
        });

        describe("Future.then() : already complated", {
            timeoutMs = 1000;

            it("should completed", function (done) {
                var future = new Future(function (complate, _) {
                    complate(1);
                    return function () {};
                }, false);
                future.then(function (x: Result<Int>) {
                    x.same(Success(1)).should.be(true);
                    x.same(future.result).should.be(true);
                    future.isActive.should.be(false);
                    done();
                });
            });

            it("should aborted", function (done) {
                var future = new Future(function (_, abort) {
                    abort("error");
                    return function () {};
                }, false);
                future.then(function (x: Result<Int>) {
                    x.same(Failed("error")).should.be(true);
                    x.same(future.result).should.be(true);
                    future.isActive.should.be(false);
                    done();
                });
            });
        });

        describe("Future.then() : async", {
            timeoutMs = 1000;

            it("should completed", function (done) {
                var future = new Future(function (complate, _) {
                    wait(5).then(function (_) complate(1));
                    return function () {};
                }, false);
                future.result.isEmpty().should.be(true);
                future.isActive.should.be(true);
                future.then(function (x: Result<Int>) {
                    x.same(Success(1)).should.be(true);
                    x.same(future.result).should.be(true);
                    future.isActive.should.be(false);
                    done();
                });
            });

            it("should aborted", function (done) {
                var future = new Future(function (_, abort) {
                    wait(5).then(function (_)  abort("error"));
                    return function () {};
                }, false);
                future.result.isEmpty().should.be(true);
                future.isActive.should.be(true);
                future.then(function (x: Result<Int>) {
                    x.same(Failed("error")).should.be(true);
                    x.same(future.result).should.be(true);
                    future.isActive.should.be(false);
                    done();
                });
            });
        });
        describe("Future(async).then() : async", {
            timeoutMs = 1000;

            it("should completed", function (done) {
                var future = new Future(function (complate, _) {
                    wait(5).then(function (_) complate(1));
                    return function () {};
                }, true);
                future.result.isEmpty().should.be(true);
                future.isActive.should.be(true);
                future.then(function (x: Result<Int>) {
                    x.same(Success(1)).should.be(true);
                    x.same(future.result).should.be(true);
                    future.isActive.should.be(false);
                    done();
                });
            });

            it("should aborted", function (done) {
                var future = new Future(function (_, abort) {
                    wait(5).then(function (_)  abort("error"));
                    return function () {};
                }, true);
                future.result.isEmpty().should.be(true);
                future.isActive.should.be(true);
                future.then(function (x: Result<Int>) {
                    x.same(Failed("error")).should.be(true);
                    x.same(future.result).should.be(true);
                    future.isActive.should.be(false);
                    done();
                });
            });
        });

        describe("Future.abort()", {
            timeoutMs = 1000;

            it("should call cancel callback", {
                var called = false;
                var future = new Future(function (_, _) {
                    return function () {
                        called = true;
                    };
                }, false);

                future.abort();
                future.isActive.should.be(false);
                switch (future.result) {
                    case Failed(e): Std.is(e, Future.AbortError).should.be(true);
                    case _: fail();
                }
                called.should.be(true);
            });

            it("should call then() as aborted", function (done) {
                var future = new Future(function (_, _) {
                    return function () {};
                }, false);

                future.then(function (x) {
                    future.result.same(x).should.be(true);
                    future.isActive.should.be(false);
                    switch (x) {
                        case Failed(e):
                            Std.is(e, Future.AbortError).should.be(true);
                        case _:
                            fail();
                    }
                    done();
                });

                future.abort();
            });
        });
        describe("Future(async).abort()", {
            timeoutMs = 1000;

            it("should not call executor", {
                var future = new Future(function (_, _) {
                    #if neko
                    wait(100).then(function (_) fail());
                    #else
                    fail();
                    #end
                    return function () {
                        fail();
                    };
                }, true);

                future.abort();
                future.isActive.should.be(false);
                switch (future.result) {
                    case Failed(e): Std.is(e, Future.AbortError).should.be(true);
                    case _: fail();
                }
            });

            it("should call then() as aborted", function (done) {
                var future = new Future(function (_, _) {
                    #if neko
                    wait(100).then(function (_) fail());
                    #else
                    fail();
                    #end
                    return function () {};
                }, true);

                future.then(function (x) {
                    future.result.same(x).should.be(true);
                    future.isActive.should.be(false);
                    switch (x) {
                        case Failed(e):
                            Std.is(e, Future.AbortError).should.be(true);
                        case _:
                            fail();
                    }
                    done();
                });

                future.abort();
            });
        });
    }
}