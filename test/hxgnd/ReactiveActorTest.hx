package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using buddy.Should;
import hxgnd.ReactiveActor;

class ReactiveActorTest extends BuddySuite {
    public function new() {
        describe("ReactiveActor#new()", {
            it("should not call middleware", function (done) {
                new ReactiveActor(10, function (_, _) {
                    fail();
                    return function () {};
                });
                wait(10, done);
            });
        });

        describe("ReactiveActor#getState()", {
            it("should pass", function (done) {
                var actor = new ReactiveActor(10, function (_, _) {
                    fail();
                    return function () {};
                });
                actor.getState().should.be(10);
                wait(10, done);
            });
        });

        describe("ReactiveActor#dispatch()", {
            timeoutMs = 500;

            describe("invoke middleware", {
                it("should call asynchronously", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        LangTools.same(message, Increment).should.be(true);
                        done();
                        return function () {};
                    });
                    actor.dispatch(Increment);
                });

                it("should call 2-times", function (done) {
                    var count = 0;
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        count++;
                        switch (count) {
                            case 1: LangTools.same(message, Increment).should.be(true);
                            case 2: LangTools.same(message, Decrement).should.be(true);
                            case _: fail();
                        }
                        return function () {};
                    });
                    actor.dispatch(Increment);
                    actor.dispatch(Decrement);
                    wait(10, function () {
                        count.should.be(2);
                        done();
                    });
                });

                it("should be rejected", function (done) {
                    var actor = new ReactiveActor(10, function (_, _) {
                        throw "error";
                    });
                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        done();
                    });
                });
            });
        });

        describe("ReactiveActor#subscribe()", {
            describe("single subscriber", {
                it("should not call subscriber", function (done) {
                    var actor = new ReactiveActor(10, function (_, _) {
                        return function () {};
                    });
                    actor.subscribe(function (x) {
                        fail();
                    });
                    wait(10, done);
                });

                it("should call subscriber", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1);
                        return function () {};
                    });
                    actor.subscribe(function (x) {
                        x.should.be(1);
                        done();
                    });
                    actor.dispatch(Increment);
                });
            });

            describe("multi subscribers", {
                it("should not call all subscribers", function (done) {
                    var actor = new ReactiveActor(10, function (_, _) {
                        return function () {};
                    });
                    actor.subscribe(function (x) {
                        fail();
                    });
                    actor.subscribe(function (x) {
                        fail();
                    });
                    wait(10, done);
                });

                it("should call all subscribers", function (done) {
                    var called1 = false;
                    var called2 = false;
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1);
                        return function () {};
                    });
                    actor.subscribe(function (x) {
                        x.should.be(1);
                        called1 = true;
                    });
                    actor.subscribe(function (x) {
                        x.should.be(1);
                        called2 = true;
                    });
                    actor.dispatch(Increment);
                    wait(10, function () {
                        called1.should.be(true);
                        called2.should.be(true);
                        done();
                    });
                });
            });

            describe("unsubscribe()", {
                it("should pass when it is called 2-times", {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        return function () {};
                    });
                    var unscribe = actor.subscribe(function (x) {});
                    unscribe();
                    unscribe();
                });
            });
        });

        describe("Context", {
            describe("getState()", {
                it("should get the current state", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.getState().should.be(10);
                        done();
                        return function () {};
                    });
                    actor.dispatch(Increment);
                });
            });

            describe("no emitting", {
                it("should be pending", function (done) {
                    var actor = new ReactiveActor(10, function (_, _) {
                        return function () {};
                    });
                    actor.subscribe(function (x) {
                        fail();
                    });

                    var promise = actor.dispatch(Increment);
                    promise.finally(function () {
                        fail();
                    });
                    wait(10, done);
                });

                it("should be pending all", function (done) {
                    var actor = new ReactiveActor(10, function (_, _) {
                        return function () {
                            done();
                        };
                    });
                    actor.subscribe(function (x) {
                        fail();
                    });

                    var promise1 = actor.dispatch(Increment);
                    var promise2 = actor.dispatch(Decrement);
                    promise1.finally(function () {
                        fail();
                    });
                    promise2.finally(function () {
                        fail();
                    });
                    wait(10, done);
                });

                it("should not call the middleware", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _) {
                        return function () {};
                    });
                    actor.subscribe(function (x) {
                        fail();
                    });

                    var promise = actor.dispatch(Increment);
                    promise.abort();
                    wait(10, done);
                });

                it("should call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (_, _) {
                        return function () {
                            done();
                        };
                    });
                    actor.subscribe(function (x) {
                        fail();
                    });

                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                });
            });

            describe("emit() & equaler", {
                describe("default equaler", {
                    it("should notify", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, message) {
                            ctx.emit(ctx.getState() + 1);
                            return function () {}
                        });
                        actor.subscribe(function (x) {
                            x.should.be(11);
                            done();
                        });
                        actor.dispatch(Increment);
                    });

                    it("should not notify", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, message) {
                            ctx.emit(10);
                            return function () {}
                        });
                        actor.subscribe(function (x) {
                            fail();
                        });
                        actor.dispatch(Increment);
                        wait(10, done);
                    });
                });

                describe("custom equaler", {
                    it("should call equaler", function (done) {
                        var called = false;

                        var actor = new ReactiveActor(10, function (ctx, message) {
                            ctx.emit(ctx.getState());
                            return function () {}
                        }, function (a, b) {
                            called = true;
                            return a == b;
                        });
                        actor.dispatch(Increment);

                        wait(10, function () {
                            called.should.be(true);
                            done();
                        });
                    });

                    it("should notify", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, message) {
                            ctx.emit(ctx.getState());
                            return function () {}
                        }, function (a, b) {
                            return false;
                        });
                        actor.subscribe(function (x) {
                            x.should.be(10);
                            done();
                        });
                        actor.dispatch(Increment);
                    });

                    it("should not notify", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, message) {
                            ctx.emit(ctx.getState() + 1);
                            return function () {}
                        }, function (a, b) {
                            return true;
                        });
                        actor.subscribe(function (x) {
                            fail();
                        });
                        actor.dispatch(Increment);
                        wait(10, done);
                    });
                });
            });

            describe("emit(hasNext=default)", {
                it("should be resolved", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(11);
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        done();
                    }, function (_) {
                        fail();
                    });
                });

                it("should take the emitted state", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.getState().should.be(10);
                        ctx.emit(ctx.getState() + 1);
                        ctx.getState().should.be(11);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(11);
                    });

                    var resolved = false;
                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        resolved = true;
                    });

                    wait(10, function () {
                        count.should.be(1);
                        resolved.should.be(true);
                        done();
                    });
                });

                it("should replace state asynchronously", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        switch (message) {
                            case Increment:
                                ctx.emit(ctx.getState() + 1);
                            case Decrement:
                                ctx.emit(ctx.getState() - 2);
                        }
                        return function () {};
                    });

                    var promise1 = actor.dispatch(Increment);
                    actor.getState().should.be(10);

                    promise1.then(function (_) {
                        actor.getState().should.be(11);

                        var promise2 = actor.dispatch(Decrement);
                        promise2.then(function (_) {
                            actor.getState().should.be(9);
                            done();
                        });
                    });
                });

                it("should not call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _) {
                        ctx.emit(1);
                        return function () {
                            fail();
                        };
                    });
                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                    wait(10, done);
                });

                it("should ignore 2nd-emit(hasNext=default)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1);
                        ctx.emit(2);
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(1);
                    });

                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=false)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1);
                        ctx.emit(2, false);
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(1);
                    });

                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=true)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1);
                        ctx.emit(2, true);
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(1);
                    });

                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-throwError()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1);
                        ctx.throwError("error");
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(1);
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-emitEnd()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1);
                        ctx.emitEnd();
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(1);
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });
            });

            describe("emit(hasNext=false)", {
                it("should be resolved", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(ctx.getState() + 1, false);
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        done();
                    }, function (_) {
                        fail();
                    });
                });

                it("should take the emitted state", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.getState().should.be(10);
                        ctx.emit(ctx.getState() + 1, false);
                        ctx.getState().should.be(11);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(11);
                    });

                    var called = false;
                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        called = true;
                    });

                    wait(10, function () {
                        count.should.be(1);
                        called.should.be(true);
                        done();
                    });
                });

                it("should replace state asynchronously", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        switch (message) {
                            case Increment:
                                ctx.emit(ctx.getState() + 1, false);
                            case Decrement:
                                ctx.emit(ctx.getState() - 2, false);
                        }
                        return function () {};
                    });

                    var promise1 = actor.dispatch(Increment);
                    actor.getState().should.be(10);

                    promise1.then(function (_) {
                        actor.getState().should.be(11);

                        var promise2 = actor.dispatch(Decrement);
                        promise2.then(function (_) {
                            actor.getState().should.be(9);
                            done();
                        });
                    });
                });

                it("should not call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _) {
                        ctx.emit(1, false);
                        return function () {
                            fail();
                        };
                    });
                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                    wait(10, done);
                });

                it("should ignore 2nd-emit(hasNext=default)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, false);
                        ctx.emit(2);
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(1);
                    });

                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=false)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, false);
                        ctx.emit(2, false);
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(1);
                    });

                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=true)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, false);
                        ctx.emit(2, true);
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(1);
                    });

                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-throwError()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, false);
                        ctx.throwError("error");
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(1);
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-emitEnd()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, false);
                        ctx.emitEnd();
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(1);
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });
            });

            describe("emit(hasNext=true)", {
                it("should be pending", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(ctx.getState() + 1, true);
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.finally(function () {
                        fail();
                    });

                    wait(10, done);
                });

                it("should take the emitted state", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.getState().should.be(10);
                        ctx.emit(ctx.getState() + 1, true);
                        ctx.getState().should.be(11);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(11);
                    });

                    var called = false;
                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        called = true;
                    });

                    wait(10, function () {
                        count.should.be(1);
                        called.should.be(false);
                        done();
                    });
                });

                it("should replace state asynchronously", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        switch (message) {
                            case Increment:
                                ctx.emit(ctx.getState() + 1, true);
                            case Decrement:
                                ctx.emit(ctx.getState() - 2, true);
                        }
                        return function () {};
                    });

                    var promise1 = actor.dispatch(Increment);
                    promise1.finally(function () {
                        fail();
                    });
                    actor.getState().should.be(10);

                    wait(5, function () {
                        actor.getState().should.be(11);

                        var promise2 = actor.dispatch(Decrement);
                        promise2.finally(function () {
                            fail();
                        });
                        wait(5, function () {
                            actor.getState().should.be(9);
                            done();
                        });
                    });
                });

                it("should call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _) {
                        ctx.emit(1, true);
                        return function () {
                            done();
                        };
                    });
                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                });

                it("should call 2nd-emit(hasNext=default)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, true);
                        ctx.getState().should.be(1);
                        ctx.emit(2);
                        ctx.getState().should.be(2);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(count);
                    });

                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(2);
                        count.should.be(2);
                        done();
                    });
                });

                it("should call 2nd-emitState(hasNext=false)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, true);
                        ctx.emit(2, false);
                        ctx.getState().should.be(2);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(count);
                    });

                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(2);
                        count.should.be(2);
                        done();
                    });
                });

                it("should call 2nd-emitState(hasNext=true)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, true);
                        ctx.emit(2, true);
                        ctx.getState().should.be(2);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(count);
                    });

                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(2);
                        count.should.be(2);
                        done();
                    });
                });

                it("should call 2nd-throwError()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, true);
                        ctx.throwError("error");
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(count);
                    });

                    var called = false;
                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        called = true;
                        actor.getState().should.be(1);
                        (e: String).should.be("error");
                    });
                    wait(5, function () {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        called.should.be(true);
                        done();
                    });
                });

                it("should call 2nd-emitEnd()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, true);
                        ctx.emitEnd();
                        ctx.getState().should.be(1);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(count);
                    });

                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        count.should.be(1);
                        done();
                    });
                });

                it("should notify 3-times", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1, true);
                        ctx.getState().should.be(1);
                        ctx.emit(2, true);
                        ctx.getState().should.be(2);
                        ctx.emit(3, true);
                        ctx.getState().should.be(3);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                        x.should.be(count);
                    });

                    actor.dispatch(Increment);
                    wait(10, function () {
                        actor.getState().should.be(3);
                        count.should.be(3);
                        done();
                    });
                });
            });

            describe("throwError()", {
                it("should be rejected", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.throwError("error");
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        fail();
                    }, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should not call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _) {
                        ctx.throwError("error");
                        return function () {
                            fail();
                        };
                    });
                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                    wait(10, done);
                });

                it("should ignore 2nd-emit(hasNext=default)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.throwError("error");
                        ctx.emit(2);
                        ctx.getState().should.be(10);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                    });

                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        count.should.be(0);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=false)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.throwError("error");
                        ctx.emit(2, false);
                        ctx.getState().should.be(10);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                    });

                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        count.should.be(0);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=true)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.throwError("error");
                        ctx.emit(2, true);
                        ctx.getState().should.be(10);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                    });

                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        count.should.be(0);
                        done();
                    });
                });

                it("should ignore 2nd-throwError()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.throwError("error");
                        ctx.throwError("error 2nd");
                        ctx.getState().should.be(10);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                    });

                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        count.should.be(0);
                        done();
                    });
                });

                it("should ignore 2nd-emitEnd()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.throwError("error");
                        ctx.emitEnd();
                        ctx.getState().should.be(10);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                    });

                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        count.should.be(0);
                        done();
                    });
                });
            });

            describe("emitEnd()", {
                it("should be resolved", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emitEnd();
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        done();
                    }, function (_) {
                        fail();
                    });
                });

                it("should not replace state", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emitEnd();
                        return function () {};
                    });

                    actor.dispatch(Increment);
                    wait(10, function () {
                        actor.getState().should.be(10);
                        done();
                    });
                });

                it("should not call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _) {
                        ctx.emitEnd();
                        return function () {
                            fail();
                        };
                    });
                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                    wait(10, done);
                });

                it("should ignore 2nd-emit(hasNext=default)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emitEnd();
                        ctx.emit(2);
                        ctx.getState().should.be(10);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (x) {
                        count.should.be(0);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=false)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emitEnd();
                        ctx.emit(2, false);
                        ctx.getState().should.be(10);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (x) {
                        count.should.be(0);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=true)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emitEnd();
                        ctx.emit(2, true);
                        ctx.getState().should.be(10);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (x) {
                        count.should.be(0);
                        done();
                    });
                });

                it("should ignore 2nd-throwError()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emitEnd();
                        ctx.throwError("error 2nd");
                        ctx.getState().should.be(10);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (x) {
                        count.should.be(0);
                        done();
                    });
                });

                it("should ignore 2nd-emitEnd()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emitEnd();
                        ctx.emitEnd();
                        ctx.getState().should.be(10);
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        count++;
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (x) {
                        count.should.be(0);
                        done();
                    });
                });
            });

            describe("become()", {
                it("should pass", function (done) {
                    var calledAlt = false;
                    var calledObserver = false;

                    function alt(c: ReactiveActorContext<Int, Operation>, m: Operation) {
                        calledAlt = true;
                        c.emit(c.getState() + 2);
                        c.getState().should.be(12);
                        return function () {};
                    }

                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.become(alt);
                        ctx.emitEnd();
                        return function () {};
                    });
                    actor.subscribe(function (x) {
                        calledObserver = true;
                        x.should.be(12);
                        actor.getState().should.be(12);
                    });

                    actor.dispatch(Increment);
                    actor.dispatch(Increment);

                    wait(10, function () {
                        calledAlt.should.be(true);
                        calledObserver.should.be(true);
                        done();
                    });
                });
            });

            describe("dispatch()", {
                it("should pass", function (done) {
                    var actor = new ReactiveActor(0, function (ctx, message) {
                        if (message > 0) {
                            ctx.emit(message, false);
                            var promise = ctx.dispatch(message - 1);
                            promise.then(function (_) {
                                ctx.emitEnd();
                            });
                        } else {
                            ctx.emitEnd();
                        }
                        return function () {};
                    });

                    var count = 0;
                    actor.subscribe(function (x) {
                        x.should.be(3 - count);
                        actor.getState().should.be(3 - count);
                        count++;
                    });
                    actor.dispatch(3);

                    wait(10, function () {
                        count.should.be(3);
                        done();
                    });
                });
            });
        });

        describe("ReactiveActor#abort()", {
            describe("no actions", {
                it("should pass", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        return function () {};
                    });
                    actor.abort();
                    wait(10, done);
                });

                it("should pass when it is called 2-times", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        return function () {};
                    });
                    actor.abort();
                    actor.abort();
                    wait(10, done);
                });
            });

            describe("one pending action", {
                it("should call catchError", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        Std.is(e, AbortedError).should.be(true);
                        done();
                    });
                    wait(5, actor.abort);
                });

                it("should call onabort", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        return function () {
                            done();
                        };
                    });
                    actor.dispatch(Increment);
                    wait(5, actor.abort);
                });

                it("should call onabort 1-time", function (done) {
                    var count = 0;
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        return function () {
                            count++;
                        };
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.abort();
                        actor.abort();
                        wait(5, function () {
                            count.should.be(1);
                            done();
                        });
                    });
                });
            });

            describe("one resolved action", {
                it("should pass", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1);
                        return function () {
                            fail();
                        };
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.abort();
                        wait(5, done);
                    });
                });

                it("should pass when it is called 2-times", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.emit(1);
                        return function () {
                            fail();
                        };
                    });
                    wait(5, function () {
                        actor.abort();
                        actor.abort();
                        wait(5, done);
                    });
                });
            });

            describe("one rejected action", {
                it("should pass", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.throwError("error");
                        return function () {
                            fail();
                        };
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.abort();
                        wait(5, done);
                    });
                });

                it("should pass when it is called 2-times", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        ctx.throwError("error");
                        return function () {
                            fail();
                        };
                    });
                    wait(5, function () {
                        actor.abort();
                        actor.abort();
                        wait(5, done);
                    });
               });
            });

            describe("two pending actions", {
                it("should call catchError", function (done) {
                    var count1 = 0;
                    var count2 = 0;
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        return function () {};
                    });
                    var promise1 = actor.dispatch(Increment);
                    var promise2 = actor.dispatch(Increment);
                    promise1.catchError(function (e) {
                        Std.is(e, AbortedError).should.be(true);
                        count1++;
                    });
                    promise2.catchError(function (e) {
                        Std.is(e, AbortedError).should.be(true);
                        count2++;
                    });
                    wait(5, function () {
                        actor.abort();
                        wait(5, function () {
                            count1.should.be(1);
                            count2.should.be(1);
                            done();
                        });
                    });
                });

                it("should call onabort", function (done) {
                    var count = 0;
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        return function () {
                            count++;
                        };
                    });
                    actor.dispatch(Increment);
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.abort();
                        wait(5, function () {
                            count.should.be(2);
                            done();
                       });
                    });
                });

                it("should call onabort 1-time", function (done) {
                    var count = 0;
                    var actor = new ReactiveActor(10, function (ctx, message) {
                        return function () {
                            count++;
                        };
                    });
                    actor.dispatch(Increment);
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.abort();
                        actor.abort();
                        actor.abort();
                        wait(5, function () {
                            count.should.be(2);
                            done();
                       });
                    });
                });
            });
        });
    }
}

enum Operation {
    Increment;
    Decrement;
}
