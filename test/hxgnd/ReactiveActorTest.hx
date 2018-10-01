package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using buddy.Should;

class ReactiveActorTest extends BuddySuite {
    public function new() {
        describe("ReactiveActor#new()", {
            it("should not call middleware", function (done) {
                new ReactiveActor(10, function (_, _, _) {
                    fail();
                    done();
                    return function () {};
                });
                wait(10, done);
            });
        });

        describe("ReactiveActor#getState()", {
            it("should pass", function (done) {
                var actor = new ReactiveActor(10, function (_, _, _) {
                    fail();
                    done();
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
                    var called = false;

                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        called = true;
                        state.should.be(10);
                        LangTools.same(message, Increment).should.be(true);
                        done();
                        return function () {};
                    });

                    actor.dispatch(Increment);
                    #if js
                    called.should.be(false);
                    #end
                });

                it("should call 2-times", function (done) {
                    var count = 0;
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        state.should.be(10);
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
            });

            describe("no emitting", {
                it("should be pending", function (done) {
                    var actor = new ReactiveActor(10, function (_, _, _) {
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.finally(function () {
                        fail();
                        done();
                    });
                    wait(10, done);
                });

                it("should be pending all", function (done) {
                    var actor = new ReactiveActor(10, function (_, _, _) {
                        return function () {
                            done();
                        };
                    });
                    var promise1 = actor.dispatch(Increment);
                    var promise2 = actor.dispatch(Decrement);
                    promise1.finally(function () {
                        fail();
                        done();
                    });
                    promise2.finally(function () {
                        fail();
                        done();
                    });
                    wait(10, done);
                });

                #if js
                it("should not call the middleware", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _, _) {
                        fail();
                        done();
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.abort();
                    wait(10, done);
                });
                #end

                it("should call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (_, _, _) {
                        return function () {
                            done();
                        };
                    });
                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                });
            });

            describe("emit(hasNext=default)", {
                it("should be resolved", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (x) return x + 1);
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        done();
                    }, function (_) {
                        fail();
                        done();
                    });

                    wait(10, done);
                });

                it("should be rejected when it throw error", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (x) throw "error");
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should replace state asynchronously", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        switch (message) {
                            case Increment:
                                ctx.emit(function (x) return x + 1);
                            case Decrement:
                                ctx.emit(function (x) return x - 1);
                        }
                        return function () {};
                    });

                    var promise1 = actor.dispatch(Increment);
                    actor.getState().should.be(10);

                    promise1.then(function (_) {
                        actor.getState().should.be(11);

                        var promise2 = actor.dispatch(Decrement);
                        promise2.then(function (_) {
                            actor.getState().should.be(10);
                            done();
                        });
                    });
                });

                it("should not call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _, _) {
                        ctx.emit(function (x) return 1);
                        return function () {
                            fail();
                            done();
                        };
                    });
                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                    wait(10, done);
                });

                it("should ignore 2nd-emit(hasNext=default)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1);
                        ctx.emit(function (_) return 2);
                        return function () {};
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=false)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1);
                        ctx.emit(function (_) return 2, false);
                        return function () {};
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=true)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1);
                        ctx.emit(function (_) return 2, true);
                        return function () {};
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-throwError()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1);
                        ctx.throwError("error");
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        actor.getState().should.be(1);
                        done();
                    });
                });
            });

            describe("emit(hasNext=false)", {
                it("should be resolved", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (x) return x + 1, false);
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        done();
                    }, function (_) {
                        fail();
                        done();
                    });

                    wait(10, done);
                });

                it("should be rejected when it throw error", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (x) throw "error", false);
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should replace state asynchronously", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        switch (message) {
                            case Increment:
                                ctx.emit(function (x) return x + 1, false);
                            case Decrement:
                                ctx.emit(function (x) return x - 1, false);
                        }
                        return function () {};
                    });

                    var promise1 = actor.dispatch(Increment);
                    actor.getState().should.be(10);

                    promise1.then(function (_) {
                        actor.getState().should.be(11);

                        var promise2 = actor.dispatch(Decrement);
                        promise2.then(function (_) {
                            actor.getState().should.be(10);
                            done();
                        });
                    });
                });

                it("should not call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _, _) {
                        ctx.emit(function (x) return 1, false);
                        return function () {
                            fail();
                            done();
                        };
                    });
                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                    wait(10, done);
                });

                it("should ignore 2nd-emit(hasNext=default)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1, false);
                        ctx.emit(function (_) return 2);
                        return function () {};
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=false)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1, false);
                        ctx.emit(function (_) return 2, false);
                        return function () {};
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-emitState(hasNext=true)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1, false);
                        ctx.emit(function (_) return 2, true);
                        return function () {};
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(1);
                        done();
                    });
                });

                it("should ignore 2nd-throwError()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1, false);
                        ctx.throwError("error");
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.then(function (_) {
                        actor.getState().should.be(1);
                        done();
                    });
                });
            });

            describe("emit(hasNext=true)", {
                it("should be pending", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (x) return x + 1, true);
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.finally(function () {
                        fail();
                        done();
                    });

                    wait(10, done);
                });

                it("should be rejected when it throw error", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (x) throw "error", true);
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should notify 3-times", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (x) return x + 1, true);
                        ctx.emit(function (x) return x + 1, true);
                        ctx.emit(function (x) return x + 1, true);
                        return function () {};
                    });

                    actor.dispatch(Increment);
                    wait(10, function () {
                        actor.getState().should.be(13);
                        done();
                    });
                });

                it("should replace state asynchronously", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        switch (message) {
                            case Increment:
                                ctx.emit(function (x) return x + 1, true);
                            case Decrement:
                                ctx.emit(function (x) return x - 1, true);
                        }
                        return function () {};
                    });

                    var promise1 = actor.dispatch(Increment);
                    promise1.finally(function () {
                        fail();
                        done();
                    });
                    actor.getState().should.be(10);

                    wait(5, function () {
                        actor.getState().should.be(11);

                        var promise2 = actor.dispatch(Decrement);
                        promise2.finally(function () {
                            fail();
                            done();
                        });
                        wait(5, function () {
                            actor.getState().should.be(10);
                            done();
                        });
                    });
                });

                it("should call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _, _) {
                        ctx.emit(function (x) return 1, true);
                        return function () {
                            done();
                        };
                    });
                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                });

                it("should call 2nd-emit(hasNext=default)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1, true);
                        ctx.emit(function (_) return 2);
                        return function () {};
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(2);
                        done();
                    });
                });

                it("should call 2nd-emitState(hasNext=false)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1, true);
                        ctx.emit(function (_) return 2, false);
                        return function () {};
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(2);
                        done();
                    });
                });

                it("should call 2nd-emitState(hasNext=true)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1, true);
                        ctx.emit(function (_) return 2, true);
                        return function () {};
                    });
                    actor.dispatch(Increment);
                    wait(5, function () {
                        actor.getState().should.be(2);
                        done();
                    });
                });

                it("should call 2nd-throwError()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) return 1, true);
                        ctx.throwError("error");
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(1);
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("throwError()", {
                it("should be rejected", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.throwError("error");
                        return function () {};
                    });

                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });

                    wait(10, done);
                });

                it("should not call the onabort", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, _, _) {
                        ctx.throwError("error");
                        return function () {
                            fail();
                            done();
                        };
                    });
                    var promise = actor.dispatch(Increment);
                    wait(5, promise.abort);
                    wait(10, done);
                });

                it("should be rejected when it is called in emit()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.emit(function (_) {
                            ctx.throwError("error");
                            return 1;
                        });
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should call 2nd-emit(hasNext=default)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.throwError("error");
                        ctx.emit(function (_) return 2);
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should call 2nd-emitState(hasNext=false)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.throwError("error");
                        ctx.emit(function (_) return 2, false);
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should call 2nd-emitState(hasNext=true)", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.throwError("error");
                        ctx.emit(function (_) return 2, true);
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should call 2nd-throwError()", function (done) {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        ctx.throwError("error");
                        ctx.throwError("error 2nd");
                        return function () {};
                    });
                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        actor.getState().should.be(10);
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("throw", {
                it("should be rejected", function (done) {
                    var actor = new ReactiveActor(10, function (_, _, _) {
                        throw "error";
                    });
                    var promise = actor.dispatch(Increment);
                    promise.catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });
        });

        describe("ReactiveActor#subscribe()", {
            describe("single subscriber", {
                describe("no emitting", {
                    it("should not call subscriber", function (done) {
                        var actor = new ReactiveActor(10, function (_, _, _) {
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        wait(10, done);
                    });
                });

                describe("emit(hasNext=default)", {
                    it("should call subscriber", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            done();
                        });
                        actor.dispatch(Increment);
                    });

                    it("should ignore 2nd-emit(hasNext=default)", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1);
                            ctx.emit(function (_) return 2);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            count++;
                        });
                        actor.dispatch(Increment);

                        wait(10, function () {
                            count.should.be(1);
                            done();
                        });
                    });

                    it("should ignore 2nd-emit(hasNext=false)", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1);
                            ctx.emit(function (_) return 2, false);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            count++;
                        });
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count.should.be(1);
                            done();
                        });
                    });

                    it("should ignore 2nd-emit(hasNext=true)", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1);
                            ctx.emit(function (_) return 2, true);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            count++;
                        });
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count.should.be(1);
                            done();
                        });
                    });

                    it("should not call subscriber when it is unsubscribed", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1);
                            return function () {};
                        });
                        var unsubscribe = actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        unsubscribe();
                        actor.dispatch(Increment);
                        wait(10, done);
                    });

                    it("should call subscriber 2-times when it dispache 2-times", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return x + 1);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            count++;
                            x.should.be(10 + count);
                        });
                        actor.dispatch(Increment);
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count.should.be(2);
                            done();
                        });
                    });
                });

                describe("emit(hasNext=false)", {
                    it("should call subscriber", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, false);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            done();
                        });
                        actor.dispatch(Increment);
                    });

                    it("should ignore 2nd-emit(hasNext=default)", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, false);
                            ctx.emit(function (_) return 2);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            count++;
                        });
                        actor.dispatch(Increment);

                        wait(10, function () {
                            count.should.be(1);
                            done();
                        });
                    });

                    it("should ignore 2nd-emit(hasNext=false)", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, false);
                            ctx.emit(function (_) return 2, false);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            count++;
                        });
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count.should.be(1);
                            done();
                        });
                    });

                    it("should ignore 2nd-emit(hasNext=true)", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, false);
                            ctx.emit(function (_) return 2, true);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            count++;
                        });
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count.should.be(1);
                            done();
                        });
                    });

                    it("should not call subscriber when it is unsubscribed", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, false);
                            return function () {};
                        });
                        var unsubscribe = actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        unsubscribe();
                        actor.dispatch(Increment);
                        wait(10, done);
                    });

                    it("should call subscriber 2-times when it dispache 2-times", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return x + 1, false);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            count++;
                            x.should.be(10 + count);
                        });
                        actor.dispatch(Increment);
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count.should.be(2);
                            done();
                        });
                    });
                });

                describe("emit(hasNext=true)", {
                    it("should call subscriber", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, true);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            done();
                        });
                        actor.dispatch(Increment);
                    });

                    it("should notify 2nd-emit(hasNext=default)", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, true);
                            ctx.emit(function (_) return 2);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            count++;
                            x.should.be(count);
                        });
                        actor.dispatch(Increment);

                        wait(10, function () {
                            count.should.be(2);
                            done();
                        });
                    });

                    it("should notify 2nd-emit(hasNext=false)", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, true);
                            ctx.emit(function (_) return 2, false);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            count++;
                            x.should.be(count);
                        });
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count.should.be(2);
                            done();
                        });
                    });

                    it("should notify 2nd-emit(hasNext=true)", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, true);
                            ctx.emit(function (_) return 2, true);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            count++;
                            x.should.be(count);
                        });
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count.should.be(2);
                            done();
                        });
                    });

                    it("should not call subscriber when it is unsubscribed", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, true);
                            return function () {};
                        });
                        var unsubscribe = actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        unsubscribe();
                        actor.dispatch(Increment);
                        wait(10, done);
                    });

                    it("should call subscriber 2-times when it dispache 2-times", function (done) {
                        var count = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return x + 1, true);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            count++;
                            x.should.be(10 + count);
                        });
                        actor.dispatch(Increment);
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count.should.be(2);
                            done();
                        });
                    });
                });

                describe("throwError()", {
                    it("should not call subscriber", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.throwError("error");
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.dispatch(Increment);
                        wait(10, done);
                    });
                });

                describe("throw", {
                    it("should not call subscriber", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            throw "error";
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.dispatch(Increment);
                        wait(10, done);
                    });
                });
            });

            describe("multi subscribers", {
                describe("no emitting", {
                    it("should not call all subscribers", function (done) {
                        var actor = new ReactiveActor(10, function (_, _, _) {
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        wait(10, done);
                    });
                });

                describe("emit(hasNext=default)", {
                    it("should call all subscribers", function (done) {
                        var called1 = false;
                        var called2 = false;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1);
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

                    it("should call a subscriber that is not unsubscribed", function (done) {
                        var called2 = false;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1);
                            return function () {};
                        });
                        var unsubscribe = actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            called2 = true;
                        });
                        unsubscribe();
                        actor.dispatch(Increment);
                        wait(10, function () {
                            called2.should.be(true);
                            done();
                        });
                    });

                    it("should call all subscribers 2-times", function (done) {
                        var count1 = 0;
                        var count2 = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return x + 1);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            count1++;
                            x.should.be(10 + count1);
                        });
                        actor.subscribe(function (x) {
                            count2++;
                            x.should.be(10 + count2);
                        });
                        actor.dispatch(Increment);
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count1.should.be(2);
                            count1.should.be(2);
                            done();
                        });
                    });
                });

                describe("emit(hasNext=false)", {
                    it("should call all subscribers", function (done) {
                        var called1 = false;
                        var called2 = false;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, false);
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

                    it("should call a subscriber that is not unsubscribed", function (done) {
                        var called2 = false;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, false);
                            return function () {};
                        });
                        var unsubscribe = actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.subscribe(function (x) {
                            x.should.be(1);
                            called2 = true;
                        });
                        unsubscribe();
                        actor.dispatch(Increment);
                        wait(10, function () {
                            called2.should.be(true);
                            done();
                        });
                    });

                    it("should call all subscribers 2-times", function (done) {
                        var count1 = 0;
                        var count2 = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return x + 1, false);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            count1++;
                            x.should.be(10 + count1);
                        });
                        actor.subscribe(function (x) {
                            count2++;
                            x.should.be(10 + count2);
                        });
                        actor.dispatch(Increment);
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count1.should.be(2);
                            count1.should.be(2);
                            done();
                        });
                    });
                });

                describe("emit(hasNext=true)", {
                    it("should call all subscribers 2-times", function (done) {
                        var count1 = 0;
                        var count2 = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, true);
                            ctx.emit(function (_) return 2);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            count1++;
                            x.should.be(count1);
                        });
                        actor.subscribe(function (x) {
                            count2++;
                            x.should.be(count2);
                        });
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count1.should.be(2);
                            count2.should.be(2);
                            done();
                        });
                    });

                    it("should call a subscriber that is not unsubscribed, 2-times", function (done) {
                        var count2 = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (_) return 1, true);
                            ctx.emit(function (_) return 2);
                            return function () {};
                        });
                        var unsubscribe = actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.subscribe(function (x) {
                            count2++;
                            x.should.be(count2);
                        });
                        unsubscribe();
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count2.should.be(2);
                            done();
                        });
                    });

                    it("should call all subscribers (2x2)-times", function (done) {
                        var count1 = 0;
                        var count2 = 0;
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return x + 1, true);
                            ctx.emit(function (x) return x + 1);
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            count1++;
                            x.should.be(10 + count1);
                        });
                        actor.subscribe(function (x) {
                            count2++;
                            x.should.be(10 + count2);
                        });
                        actor.dispatch(Increment);
                        actor.dispatch(Increment);
                        wait(10, function () {
                            count1.should.be(4);
                            count1.should.be(4);
                            done();
                        });
                    });
                });

                describe("throwError()", {
                    it("should not call all subscribers", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.throwError("error");
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.dispatch(Increment);
                        wait(10, done);
                    });
                });

                describe("throw", {
                    it("should not call all subscribers", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            throw "error";
                            return function () {};
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.dispatch(Increment);
                        wait(10, done);
                    });
                });
            });

            describe("equaler", {
                describe("default equaler", {
                    it("should notify", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return x + 1);
                            return function () {}
                        });
                        actor.subscribe(function (x) {
                            x.should.be(11);
                            done();
                        });
                        actor.dispatch(Increment);
                    });

                    it("should not notify", function (done) {
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return 10);
                            return function () {}
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.dispatch(Increment);
                        wait(10, done);
                    });
                });

                describe("custom equaler", {
                    it("should call equaler", function (done) {
                        var called = false;

                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return x);
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
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return x);
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
                        var actor = new ReactiveActor(10, function (ctx, state, message) {
                            ctx.emit(function (x) return 11);
                            return function () {}
                        }, function (a, b) {
                            return true;
                        });
                        actor.subscribe(function (x) {
                            fail();
                            done();
                        });
                        actor.dispatch(Increment);
                        wait(10, done);
                    });
                });
            });

            describe("unsubscribe()", {
                it("can call 2-times", {
                    var actor = new ReactiveActor(10, function (ctx, state, message) {
                        return function () {};
                    });
                    var unscribe = actor.subscribe(function (x) {});
                    unscribe();
                    unscribe();
                });
            });
        });

        describe("ReactiveActor#abort()", {
        // TODO
        });
    }
}

enum Operation {
    Increment;
    Decrement;
}