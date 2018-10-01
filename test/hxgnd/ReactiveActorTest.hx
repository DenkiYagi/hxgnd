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
                    called.should.be(false);
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

                it("should ignore 2nd-emitError()", function (done) {
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
            });







                describe("emitState(hasNext=false)", {
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
                        actor.dispatch(Increment);
                        actor.getState().should.be(10);
                        wait(5, function () {
                            actor.getState().should.be(11);

                            actor.dispatch(Decrement);
                            wait(5, function () {
                                actor.getState().should.be(10);
                                done();
                            });
                        });
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

                    it("should ignore 2nd-emitError()", function (done) {
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

                describe("emitState(hasNext=true)", {
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
                        actor.dispatch(Increment);
                        actor.getState().should.be(10);
                        wait(5, function () {
                            actor.getState().should.be(11);

                            actor.dispatch(Decrement);
                            wait(5, function () {
                                actor.getState().should.be(10);
                                done();
                            });
                        });
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

                    it("should ignore 2nd-emitError()", function (done) {
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
            });




        //     describe("emitState(completed=true)", {
        //         describe("state updating", {
        //             it("should replace state asynchronously", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     switch (message) {
        //                         case Increment:
        //                             ctx.emitState(state + 1, true);
        //                         case Decrement:
        //                             ctx.emitState(state - 1, true);
        //                     }
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 actor.getState().should.be(10);
        //                 wait(5, function () {
        //                     actor.getState().should.be(11);

        //                     actor.dispatch(Decrement);
        //                     wait(5, function () {
        //                         actor.getState().should.be(10);
        //                         done();
        //                     });
        //                 });
        //             });

        //             it("should ignore 2nd-emitState(completed=default)", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, true);
        //                     ctx.emitState(2);
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 wait(5, function () {
        //                     actor.getState().should.be(1);
        //                     done();
        //                 });
        //             });

        //             it("should ignore 2nd-emitState(completed=true)", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, true);
        //                     ctx.emitState(2, true);
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 wait(5, function () {
        //                     actor.getState().should.be(1);
        //                     done();
        //                 });
        //             });

        //             it("should ignore 2nd-emitState(completed=false)", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, true);
        //                     ctx.emitState(2, false);
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 wait(5, function () {
        //                     actor.getState().should.be(1);
        //                     done();
        //                 });
        //             });

        //             it("should ignore 2nd-emitError()", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, true);
        //                     ctx.emitError("error");
        //                     return function () {};
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 promise.then(function (_) {
        //                     actor.getState().should.be(1);
        //                     done();
        //                 });
        //             });
        //         });

        //         describe("Promise", {
        //             it("should call onfulfill", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, _, _) {
        //                     ctx.emitState(1, true);
        //                     return function () {};
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 promise.then(function (_) {
        //                     actor.getState().should.be(1);
        //                     done();
        //                 });
        //             });

        //             it("should not call the onabort", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, _, _) {
        //                     ctx.emitState(1, true);
        //                     return function () {
        //                         fail();
        //                         done();
        //                     };
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 wait(5, promise.abort);
        //                 wait(10, done);
        //             });
        //         });
        //     });

        //     describe("emitState(completed=false)", {
        //         describe("state updating", {
        //             it("should replace state asynchronously", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     switch (message) {
        //                         case Increment:
        //                             ctx.emitState(state + 1, false);
        //                         case Decrement:
        //                             ctx.emitState(state - 1, false);
        //                     }
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 actor.getState().should.be(10);
        //                 wait(5, function () {
        //                     actor.getState().should.be(11);

        //                     actor.dispatch(Decrement);
        //                     wait(5, function () {
        //                         actor.getState().should.be(10);
        //                         done();
        //                     });
        //                 });
        //             });

        //             it("should call 2nd-emitState(completed=default)", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, false);
        //                     ctx.emitState(2);
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 wait(5, function () {
        //                     actor.getState().should.be(2);
        //                     done();
        //                 });
        //             });

        //             it("should call 2nd-emitState(completed=true)", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, false);
        //                     ctx.emitState(2, true);
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 wait(5, function () {
        //                     actor.getState().should.be(2);
        //                     done();
        //                 });
        //             });

        //             it("should call 2nd-emitError()", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, false);
        //                     ctx.emitError("error");
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 wait(5, function () {
        //                     actor.getState().should.be(1);
        //                     done();
        //                 });
        //             });
        //         });

        //         describe("Promise", {
        //             it("should not call finally", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, _, _) {
        //                     ctx.emitState(1, false);
        //                     return function () {};
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 promise.finally(function () {
        //                     fail();
        //                     done();
        //                 });
        //                 wait(10, done);
        //             });

        //             it("should call the onabort", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, _, _) {
        //                     ctx.emitState(1, false);
        //                     return function () {
        //                         done();
        //                     };
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 wait(5, promise.abort);
        //             });

        //             it("should call onfulfill when it call emitState(completed=default) 2ndary", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, false);
        //                     ctx.emitState(2);
        //                     return function () {};
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 promise.then(function (_) {
        //                     actor.getState().should.be(2);
        //                     done();
        //                 });
        //             });

        //             it("should call onfulfill when it call emitState(completed=true) 2ndary", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, false);
        //                     ctx.emitState(2, true);
        //                     return function () {};
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 promise.then(function (_) {
        //                     actor.getState().should.be(2);
        //                     done();
        //                 });
        //             });

        //             it("should call onfulfill when it call emitState(completed=false) 2ndary", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, false);
        //                     ctx.emitState(2, false);
        //                     return function () {};
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 promise.then(function (_) {
        //                     fail();
        //                     done();
        //                 });
        //                 wait(10, function () {
        //                     actor.getState().should.be(2);
        //                     done();
        //                 });
        //             });

        //             it("should call onerror when it call emitError()", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitState(1, false);
        //                     ctx.emitError("error");
        //                     return function () {};
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 promise.catchError(function (e) {
        //                     (e: String).should.be("error");
        //                     done();
        //                 });
        //             });
        //         });
        //     });

        //     describe("emitError()", {
        //         describe("state updating", {
        //             it("should not replace state", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitError("error:" + message);
        //                     return function () {};
        //                 });
        //                 actor.dispatch("1");
        //                 actor.getState().should.be(10);
        //                 wait(5, function () {
        //                     actor.getState().should.be(10);

        //                     actor.dispatch("2");
        //                     wait(5, function () {
        //                         actor.getState().should.be(10);
        //                         done();
        //                     });
        //                 });
        //             });

        //             it("should ignore 2nd-emitState(completed=default)", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitError("error");
        //                     ctx.emitState(2);
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 wait(5, function () {
        //                     actor.getState().should.be(10);
        //                     done();
        //                 });
        //             });

        //             it("should ignore 2nd-emitState(completed=true)", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitError("error");
        //                     ctx.emitState(2, true);
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 wait(5, function () {
        //                     actor.getState().should.be(10);
        //                     done();
        //                 });
        //             });

        //             it("should ignore 2nd-emitState(completed=false)", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitError("error");
        //                     ctx.emitState(2, false);
        //                     return function () {};
        //                 });
        //                 actor.dispatch(Increment);
        //                 wait(5, function () {
        //                     actor.getState().should.be(10);
        //                     done();
        //                 });
        //             });

        //             it("should ignore 2nd-emitError()", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     ctx.emitError("error");
        //                     ctx.emitError("error 2nd");
        //                     return function () {};
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 promise.catchError(function (e) {
        //                     actor.getState().should.be(10);
        //                     (e: String).should.be("error");
        //                     done();
        //                 });
        //             });
        //         });

        //         describe("Promise", {
        //             it("should call onreject", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, _, _) {
        //                     ctx.emitError("error");
        //                     return function () {};
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 promise.catchError(function (e) {
        //                     actor.getState().should.be(10);
        //                     (e: String).should.be("error");
        //                     done();
        //                 });
        //             });

        //             it("should not call the onabort", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, _, _) {
        //                     ctx.emitError("error");
        //                     return function () {
        //                         fail();
        //                         done();
        //                     };
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 wait(5, promise.abort);
        //                 wait(10, done);
        //             });
        //         });
        //     });

        //     describe("throw error", {
        //         describe("state updating", {
        //             it("should not replace state", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, message) {
        //                     throw "error:" + message;
        //                     return function () {};
        //                 });
        //                 actor.dispatch("1");
        //                 actor.getState().should.be(10);
        //                 wait(5, function () {
        //                     actor.getState().should.be(10);

        //                     actor.dispatch("2");
        //                     wait(5, function () {
        //                         actor.getState().should.be(10);
        //                         done();
        //                     });
        //                 });
        //             });
        //         });

        //         describe("Promise", {
        //             it("should call onreject", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, _, _) {
        //                     throw "error";
        //                     return function () {};
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 promise.catchError(function (e) {
        //                     actor.getState().should.be(10);
        //                     (e: String).should.be("error");
        //                     done();
        //                 });
        //             });

        //             it("should not call the onabort", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, _, _) {
        //                     throw "error";
        //                     return function () {
        //                         fail();
        //                         done();
        //                     };
        //                 });
        //                 var promise = actor.dispatch(Increment);
        //                 wait(5, promise.abort);
        //                 wait(10, done);
        //             });
        //         });
        //     });
        // });

        // describe("ReactiveActor#subscribe()", {
        //     describe("one subscriber", {
        //         describe("no dispatch", {
        //             it("should not call subscriber", function (done) {
        //                 var actor = new ReactiveActor(10, function (_, _, _) {
        //                     return function () {};
        //                 });
        //                 actor.subscribe(function (x) {
        //                     fail();
        //                     done();
        //                 });
        //                 wait(10, done);
        //             });
        //         });

        //         describe("dispatch", {
        //             it("should call subscriber 1-time", function (done) {
        //                 var count = 0;

        //                 var actor = new ReactiveActor(10, function (ctx, state, _) {
        //                     ctx.emitState(state + 1);
        //                     return function () {};
        //                 });

        //                 actor.subscribe(function (x) {
        //                     count++;
        //                     x.should.be(11);
        //                     count.should.be(1);
        //                     done();
        //                 });
        //                 actor.dispatch(Increment);
        //             });

        //             it("should call subscriber 2-times", function (done) {
        //                 var count = 0;

        //                 var actor = new ReactiveActor(10, function (ctx, state, _) {
        //                     ctx.emitState(state + 1);
        //                     return function () {};
        //                 });

        //                 actor.subscribe(function (x) {
        //                     trace("call");
        //                     count++;
        //                     x.should.be(11);
        //                     count.should.be(1);
        //                 });
        //                 actor.dispatch(Increment);
        //                 actor.dispatch(Increment);

        //                 wait(20, function () {
        //                     count.should.be(2);
        //                     actor.getState().should.be(12);
        //                     done();
        //                 });
        //             });
        //         });

        //         describe("remove", {
        //             it("should remove subscriber", function (done) {
        //                 var actor = new ReactiveActor(10, function (ctx, state, _) {
        //                     ctx.emitState(state + 1);
        //                     return function () {};
        //                 });
        //                 var unsubscribe = actor.subscribe(function (x) {
        //                     fail();
        //                     done();
        //                 });
        //                 unsubscribe();
        //                 actor.dispatch(Increment);
        //                 wait(10, done);
        //             });
        //         });
            // });

            // describe("two subscribers", {
            //     it("should not call all subscribers", function (done) {
            //         var reactiveVar = new ReactiveVar(10);
            //         reactiveVar.subscribe(function (x) {
            //             fail();
            //             done();
            //         });
            //         reactiveVar.subscribe(function (x) {
            //             fail();
            //             done();
            //         });
            //         reactiveVar.get();
            //         wait(10, done);
            //     });

            //     it("should call all subscribers 1-time", function (done) {
            //         var count1 = 0;
            //         var count2 = 0;

            //         var reactiveVar = new ReactiveVar(10);
            //         reactiveVar.subscribe(function (x) {
            //             x.should.be(-5);
            //             count1++;
            //         });
            //         reactiveVar.subscribe(function (x) {
            //             x.should.be(-5);
            //             count2++;
            //         });
            //         reactiveVar.set(-5);

            //         wait(10, function () {
            //             count1.should.be(1);
            //             count2.should.be(1);
            //             done();
            //         });
            //     });

            //     it("should call subscriber 2-times", function (done) {
            //         var count1 = 0;
            //         var count2 = 0;

            //         var reactiveVar = new ReactiveVar(10);
            //         reactiveVar.subscribe(function (x) {
            //             switch (++count1) {
            //                 case 1:
            //                     x.should.be(-5);
            //                 case 2:
            //                     x.should.be(-10);
            //                 case _:
            //                     fail();
            //                     done();
            //             }
            //         });
            //         reactiveVar.subscribe(function (x) {
            //             switch (++count2) {
            //                 case 1:
            //                     x.should.be(-5);
            //                 case 2:
            //                     x.should.be(-10);
            //                 case _:
            //                     fail();
            //                     done();
            //             }
            //         });

            //         reactiveVar.set(-5);
            //         reactiveVar.set(-10);

            //         wait(10, function () {
            //             count1.should.be(2);
            //             count2.should.be(2);
            //             done();
            //         });
            //     });

            //     it("should remove 1st-subscriber", function (done) {
            //         var count2 = 0;

            //         var reactiveVar = new ReactiveVar(10);
            //         var unscribe1 = reactiveVar.subscribe(function (x) {
            //             fail();
            //             done();
            //         });
            //         reactiveVar.subscribe(function (x) {
            //             count2++;
            //             x.should.be(-5);
            //         });

            //         unscribe1();
            //         reactiveVar.set(-5);

            //         wait(10, function () {
            //             count2.should.be(1);
            //             done();
            //         });
            //     });

            //     it("should remove all subscribers", function (done) {
            //         var reactiveVar = new ReactiveVar(10);
            //         var unscribe1 = reactiveVar.subscribe(function (x) {
            //             fail();
            //             done();
            //         });
            //         var unscribe2 = reactiveVar.subscribe(function (x) {
            //             fail();
            //             done();
            //         });

            //         unscribe1();
            //         unscribe2();
            //         reactiveVar.set(-5);

            //         wait(10, done);
            //     });
            // });
        // });


        describe("ReactiveActor#abort()", {
        });
    }
}

enum Operation {
    Increment;
    Decrement;
}