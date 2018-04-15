package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
import hxgnd.Result;
import hxgnd.Abortable;
using hxgnd.LangTools;
using buddy.Should;

class FutureTest extends BuddySuite {
    public function new() {
        describe("Future is Abortable", {
            it("should can compile", {
                var future: Abortable = Future.successful(0);
            });
        });

        describe("Future.successful()", {
            it("should pass", {
                var future = Future.successful(1);
                future.isActive.should.be(false);
                future.result.nonEmpty().should.be(true);
                future.result.same(Maybe.of(Success(1))).should.be(true);
            });

            describe(".then()", {
                it("should call callback", function (done) {
                    var future = Future.successful(1);
                    future.then(function (x: Result<Int>) {
                        x.same(Success(1)).should.be(true);
                        x.same(future.result).should.be(true);
                        future.isActive.should.be(false);
                        done();
                    });
                });
            });

            describe(".abort()", {
                it("should pass", {
                    var future = Future.successful(1);
                    future.abort();
                });
            });
        });


        describe("Future.successfulUnit()", {
            it("should pass", {
                var future = Future.successfulUnit();
                future.isActive.should.be(false);
                future.result.nonEmpty().should.be(true);
                future.result.same(Maybe.of(Success(Unit._))).should.be(true);
            });

            describe(".then()", {
                it("should call callback", function (done) {
                var future = Future.successfulUnit();
                    future.then(function (x: Result<Unit>) {
                        x.same(Success(Unit._)).should.be(true);
                        x.same(future.result).should.be(true);
                        future.isActive.should.be(false);
                        done();
                    });
                });
            });

            describe(".abort()", {
                it("should pass", {
                    var future = Future.successfulUnit();
                    future.abort();
                });
            });
        });

        describe("Future.failed()", {
            it("should pass", {
                var future = Future.failed("error");
                future.isActive.should.be(false);
                future.result.nonEmpty().should.be(true);
                future.result.same(Maybe.of(Failure("error"))).should.be(true);
            });

            describe(".then()", {
                it("should call callback", function (done) {
                    var future = Future.failed("error");
                    future.then(function (x: Result<Int>) {
                        x.same(Failure("error")).should.be(true);
                        x.same(future.result).should.be(true);
                        future.isActive.should.be(false);
                        done();
                    });
                });
            });

            describe(".abort()", {
                it("should pass", {
                    var future = Future.failed("error");
                    future.abort();
                });
            });
        });

        describe("Future.processed()", {
            it("should pass when it has given Success", {
                var future = Future.processed(Success(1));
                future.isActive.should.be(false);
                future.result.nonEmpty().should.be(true);
                future.result.same(Maybe.of(Success(1))).should.be(true);
            });

            it("should pass when it has given Failure", {
                var future = Future.processed(Failure("error"));
                future.isActive.should.be(false);
                future.result.nonEmpty().should.be(true);
                future.result.same(Maybe.of(Failure("error"))).should.be(true);
            });

            describe(".then()", {
                it("should call callback when it has given Success", function (done) {
                    var future = Future.processed(Success(1));
                    future.then(function (x: Result<Int>) {
                        x.same(Success(1)).should.be(true);
                        x.same(future.result).should.be(true);
                        future.isActive.should.be(false);
                        done();
                    });
                });

                it("should call callback when it has given Failure", function (done) {
                    var future = Future.processed(Failure("error"));
                    future.then(function (x: Result<Int>) {
                        x.same(Failure("error")).should.be(true);
                        x.same(future.result).should.be(true);
                        future.isActive.should.be(false);
                        done();
                    });
                });
            });

            describe(".abort()", {
                it("should pass when it has given Success", {
                    var future = Future.processed(Success(1));
                    future.abort();
                });

                it("should pass when it has given Failure", {
                    var future = Future.processed(Failure("error"));
                    future.abort();
                });
            });
        });

        describe("Future.apply()", {
            it("should call", function (done) {
                Future.apply(function (ctx) {
                    done();
                });
            });

            it("should be active", function (done) {
                var future = Future.apply(function (ctx) {
                });
                wait(10, function () {
                    future.isActive.should.be(true);
                    future.result.isEmpty().should.be(true);
                    done();
                });
            });

            it("should be Success", function (done) {
                var future = Future.apply(function (ctx) {
                    ctx.successful(1);
                });
                wait(10, function () {
                    future.isActive.should.be(false);
                    future.result.same(Maybe.of(Success(1))).should.be(true);
                    done();
                });
            });

            it("should be Failure", function (done) {
                var future = Future.apply(function (ctx) {
                    ctx.failed("error");
                });
                wait(10, function () {
                    future.isActive.should.be(false);
                    future.result.same(Failure("error")).should.be(true);
                    done();
                });
            });

            it("should be Failure when it throw", function (done) {
                var future = Future.apply(function (ctx) {
                    #if neko
                    Sys.sleep(0.01);
                    #end
                    throw "error";
                });
                wait(20, function () {
                    future.isActive.should.be(false);
                    future.result.same(Failure("error")).should.be(true);
                    done();
                });
            });

            describe(".then()", {
                it("should call callback when it has given Success", function (done) {
                    var future = Future.apply(function (ctx) {
                        wait(5, function () ctx.successful(1));
                    });
                    future.then(function (x: Result<Int>) {
                        x.same(Success(1)).should.be(true);
                        x.same(future.result).should.be(true);
                        future.isActive.should.be(false);
                        done();
                    });
                });

                it("should call callback when it has given Failure", function (done) {
                    var future = Future.apply(function (ctx) {
                        wait(5, function () ctx.failed("error"));
                    });
                    future.then(function (x: Result<Int>) {
                        x.same(Failure("error")).should.be(true);
                        x.same(future.result).should.be(true);
                        future.isActive.should.be(false);
                        done();
                    });
                });

                it("should call 2 callbacks", function (done) {
                    var future = Future.apply(function (ctx) {
                        wait(5, function () ctx.successful(1));
                    });

                    var count = 0;
                    future.then(function (x: Result<Int>) {
                        count++;
                    });
                    future.then(function (x: Result<Int>) {
                        count++;
                        count.should.be(2);
                        done();
                    });
                });

                it("should call after processed", function (done) {
                    var future = Future.apply(function (ctx) {
                        wait(5, function () ctx.successful(1));
                    });

                    wait(10, function () {
                        future.then(function (x: Result<Int>) {
                            done();
                        });
                    });
                });

                it("should not call again", function (done) {
                    var future = Future.apply(function (ctx) {
                        wait(5, function () ctx.successful(1));
                    });
                    var count = 0;
                    future.then(function (x: Result<Int>) {
                        count++;
                    });

                    wait(10, function () {
                        future.then(function (x: Result<Int>) {
                            count.should.be(1);
                            done();
                        });
                    });
                });
            });

            describe(".abort()", {
                it("should abort", {
                    var future = Future.apply(function (ctx) {
                    });
                    future.abort();
                    future.isActive.should.be(false);
                    switch (future.result) {
                        case Failure(e): Std.is(e, AbortError).should.be(true);
                        case _: fail();
                    }
                });

                #if js
                it("should not call onAbort", {
                    var called = false;
                    var future = Future.apply(function (ctx) {
                        ctx.onAbort = function () {
                            called = true;
                        };
                    });

                    future.abort();
                    called.should.be(false);
                });
                #end

                it("should call onAbort", {
                    var called = false;
                    var future = Future.apply(function (ctx) {
                        ctx.onAbort = function () {
                            called = true;
                        };
                    });

                    wait(10, function () {
                        future.abort();
                        called.should.be(true);
                    });
                });

                it("should call then callback", function (done) {
                    var future = Future.apply(function (ctx) {
                    });

                    future.then(function (x) {
                        future.result.same(x).should.be(true);
                        future.isActive.should.be(false);
                        switch (x) {
                            case Failure(e):
                                Std.is(e, AbortError).should.be(true);
                            case _:
                                fail();
                        }
                        done();
                    });

                    future.abort();
                });
            });
        });

        describe("Future.applySync()", {
            it("should call", function (done) {
                Future.applySync(function (ctx) {
                    done();
                });
            });

            it("should be active", function (done) {
                var future = Future.applySync(function (ctx) {
                });
                wait(10, function () {
                    future.isActive.should.be(true);
                    future.result.isEmpty().should.be(true);
                    done();
                });
            });

            it("should be Success", function (done) {
                var future = Future.applySync(function (ctx) {
                    ctx.successful(1);
                });
                wait(10, function () {
                    future.isActive.should.be(false);
                    future.result.same(Maybe.of(Success(1))).should.be(true);
                    done();
                });
            });

            it("should be Failure", function (done) {
                var future = Future.applySync(function (ctx) {
                    ctx.failed("error");
                });
                wait(10, function () {
                    future.isActive.should.be(false);
                    future.result.same(Failure("error")).should.be(true);
                    done();
                });
            });

            it("should be Failure when it throw", function (done) {
                var future = Future.applySync(function (ctx) {
                    #if neko
                    Sys.sleep(0.01);
                    #end
                    throw "error";
                });
                wait(20, function () {
                    future.isActive.should.be(false);
                    future.result.same(Failure("error")).should.be(true);
                    done();
                });
            });

            describe(".then()", {
                it("should call callback when it has given Success", function (done) {
                    var future = Future.applySync(function (ctx) {
                        wait(5, function () ctx.successful(1));
                    });
                    future.then(function (x: Result<Int>) {
                        x.same(Success(1)).should.be(true);
                        x.same(future.result).should.be(true);
                        future.isActive.should.be(false);
                        done();
                    });
                });

                it("should call callback when it has given Failure", function (done) {
                    var future = Future.applySync(function (ctx) {
                        wait(5, function () ctx.failed("error"));
                    });
                    future.then(function (x: Result<Int>) {
                        x.same(Failure("error")).should.be(true);
                        x.same(future.result).should.be(true);
                        future.isActive.should.be(false);
                        done();
                    });
                });

                it("should call 2 callbacks", function (done) {
                    var future = Future.applySync(function (ctx) {
                        wait(5, function () ctx.successful(1));
                    });

                    var count = 0;
                    future.then(function (x: Result<Int>) {
                        count++;
                    });
                    future.then(function (x: Result<Int>) {
                        count++;
                        count.should.be(2);
                        done();
                    });
                });

                it("should call after processed", function (done) {
                    var future = Future.applySync(function (ctx) {
                        wait(5, function () ctx.successful(1));
                    });

                    wait(10, function () {
                        future.then(function (x: Result<Int>) {
                            done();
                        });
                    });
                });

                it("should not call again", function (done) {
                    var future = Future.applySync(function (ctx) {
                        wait(5, function () ctx.successful(1));
                    });
                    var count = 0;
                    future.then(function (x: Result<Int>) {
                        count++;
                    });

                    wait(10, function () {
                        future.then(function (x: Result<Int>) {
                            count.should.be(1);
                            done();
                        });
                    });
                });
            });

            describe(".abort()", {
                it("should abort", {
                    var future = Future.applySync(function (ctx) {
                    });
                    future.abort();
                    future.isActive.should.be(false);
                    switch (future.result) {
                        case Failure(e): Std.is(e, AbortError).should.be(true);
                        case _: fail();
                    }
                });

                it("should call onAbort", {
                    var called = false;
                    var future = Future.applySync(function (ctx) {
                        ctx.onAbort = function () {
                            called = true;
                        };
                    });

                    future.abort();
                    called.should.be(true);
                });

                it("should call then callback", function (done) {
                    var future = Future.applySync(function (ctx) {
                    });

                    future.then(function (x) {
                        future.result.same(x).should.be(true);
                        future.isActive.should.be(false);
                        switch (x) {
                            case Failure(e):
                                Std.is(e, AbortError).should.be(true);
                            case _:
                                fail();
                        }
                        done();
                    });

                    future.abort();
                });
            });
        });
    }
}