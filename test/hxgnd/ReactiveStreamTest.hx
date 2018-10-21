package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using buddy.Should;
import hxgnd.ReactiveStream;

class ReactiveStreamTest extends BuddySuite {
    public function new() {
        var testInitStream: (ReactableStreamMiddleware<Int> -> Promise<ReactiveStream<Int>>) -> ?Bool -> Void;

        function testObservable(create: ReactableStreamMiddleware<Int> -> Promise<ReactiveStream<Int>>) {
            describe("observable", {
                it("should pass when it throw error", function (done) {
                    create(function (ctx) {
                        throw "error";
                    }).then(function (stream) {
                        var values = [];
                        var countEnd = 0;
                        var errors = [];
                        var countFinally = 0;
                        var caughtErrors = [];
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });

                        wait(5, function () {
                            values.should.containExactly([]);
                            countEnd.should.be(0);
                            errors.should.containExactly(["error"]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                    });
                });

                it("should pass when it call [ emit ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emit(10);
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([10]);
                            countEnd.should.be(0);
                            errors.should.containExactly([]);
                            countFinally.should.be(0);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ emitEnd ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emitEnd();
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([]);
                            countEnd.should.be(1);
                            errors.should.containExactly([]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ throwError ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.throwError("error1");
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([]);
                            countEnd.should.be(0);
                            errors.should.containExactly(["error1"]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ emit, emit ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emit(10);
                                ctx.emit(20);
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([10, 20]);
                            countEnd.should.be(0);
                            errors.should.containExactly([]);
                            countFinally.should.be(0);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ emit, emitEnd ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emit(10);
                                ctx.emitEnd();
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([10]);
                            countEnd.should.be(1);
                            errors.should.containExactly([]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;

                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ emit, throwError ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emit(10);
                                ctx.throwError("error2");
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([10]);
                            countEnd.should.be(0);
                            errors.should.containExactly(["error2"]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ emitEnd, emit ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emitEnd();
                                ctx.emit(20);
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([]);
                            countEnd.should.be(1);
                            errors.should.containExactly([]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ emitEnd, emitEnd ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emitEnd();
                                ctx.emitEnd();
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([]);
                            countEnd.should.be(1);
                            errors.should.containExactly([]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ emitEnd, throwError ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emitEnd();
                                ctx.throwError("error2");
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([]);
                            countEnd.should.be(1);
                            errors.should.containExactly([]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ throwError, emit ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.throwError("error1");
                                ctx.emit(20);
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([]);
                            countEnd.should.be(0);
                            errors.should.containExactly(["error1"]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ throwError, emitEnd ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.throwError("error1");
                                ctx.emitEnd();
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([]);
                            countEnd.should.be(0);
                            errors.should.containExactly(["error1"]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should pass when it call [ throwError, throwError ]", function (done) {
                    var values = [];
                    var countEnd = 0;
                    var errors = [];
                    var countFinally = 0;
                    var caughtErrors = [];
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.throwError("error1");
                                ctx.throwError("error2");
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            values.should.containExactly([]);
                            countEnd.should.be(0);
                            errors.should.containExactly(["error1"]);
                            countFinally.should.be(1);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            values.push(x);
                        });
                        stream.subscribeEnd(function () {
                            countEnd++;
                        });
                        stream.subscribeError(function (e) {
                            errors.push(e);
                        });
                        stream.finally(function () {
                            countFinally++;
                        });
                        stream.catchError(function (e) {
                            caughtErrors.push(e);
                            throw e;
                        });
                    });
                });

                it("should call all callbacks that is set subscribe()", function (done) {
                    var called1 = 0;
                    var called2 = 0;
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emit(10);
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            called1.should.be(1);
                            called2.should.be(1);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribe(function (x) {
                            called1++;
                        });
                        stream.subscribe(function (x) {
                            called2++;
                        });
                    });
                });

                it("should call all callbacks that is set subscribeEnd()", function (done) {
                    var called1 = 0;
                    var called2 = 0;
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emitEnd();
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            called1.should.be(1);
                            called2.should.be(1);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribeEnd(function () {
                            called1++;
                        });
                        stream.subscribeEnd(function () {
                            called2++;
                        });
                    });
                });

                it("should call all callbacks that is set subscribeError()", function (done) {
                    var called1 = 0;
                    var called2 = 0;
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.throwError("error");
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            called1.should.be(1);
                            called2.should.be(1);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.subscribeError(function (e) {
                            called1++;
                        });
                        stream.subscribeError(function (e) {
                            called2++;
                        });
                    });
                });

                it("should call all callbacks that is set finally()", function (done) {
                    var called1 = 0;
                    var called2 = 0;
                    create(function (ctx) {
                        new SyncPromise(function (f, _) {
                            wait(5, function () {
                                ctx.emitEnd();
                                wait(5, function () f());
                            });
                        }).then(function (_) {
                            called1.should.be(1);
                            called2.should.be(1);
                            done();
                        });
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.finally(function () {
                            called1++;
                        });
                        stream.finally(function () {
                            called2++;
                        });

                        wait(10, function () {
                            called1.should.be(1);
                            called2.should.be(1);
                            done();
                        });
                    });
                });
            });
        }

        function testEndedStream(create: Void -> Promise<ReactiveStream<Int>>, isRecovered = false) {
            describe("state", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        stream.state.should.equal(Ended);
                        done();
                    });
                });
            });

            describe("subscribe()", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribe(function (_) fail());
                        stream.state.should.equal(Ended);

                        unsubscribe();
                        stream.state.should.equal(Ended);
                        done();
                    });
                });
            });

            describe("subscribeEnd()", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        var called = 0;
                        var unsubscribe = stream.subscribeEnd(function () called++);
                        stream.state.should.equal(Ended);
                        called.should.be(1);

                        unsubscribe();
                        stream.state.should.equal(Ended);
                        called.should.be(1);
                        done();
                    });
                });
            });

            describe("subscribeError()", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribeError(function (_) fail());
                        stream.state.should.equal(Ended);

                        unsubscribe();
                        stream.state.should.equal(Ended);
                        done();
                    });
                });
            });

            describe("finally()", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        var called = 0;
                        var unsubscribe = stream.finally(function () called++);
                        stream.state.should.equal(Ended);
                        called.should.be(1);

                        unsubscribe();
                        stream.state.should.equal(Ended);
                        called.should.be(1);
                        done();
                    });
                });
            });

            describe("close()", {
                if (isRecovered) {
                    it("should not change the state", function (done) {
                        create().then(function (stream) {
                            stream.close();
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                } else {
                    describe("observable", {
                        it("should pass", function (done) {
                            create().then(function (stream) {
                                var endCalled = 0;
                                var finallyCalled = 0;
                                stream.subscribe(function (_) fail());
                                stream.subscribeEnd(function () endCalled++);
                                stream.subscribeError(function (_) fail());
                                stream.finally(function () finallyCalled++);
                                stream.close();
                                stream.close();

                                stream.state.should.equal(Ended);
                                endCalled.should.be(1);
                                finallyCalled.should.be(1);
                                done();
                            });
                        });
                    });

                    testEndedStream(function () {
                        return create().then(function (stream) {
                            stream.close();
                            return stream;
                        });
                    }, true);
                }
            });

            describe("catchError()", {
                if (isRecovered) {
                    it("should pass", function (done) {
                        create().then(function (stream) {
                            var next = stream.catchError(function (e) { fail(); throw e; });
                            next.state.should.equal(Ended);
                            done();
                        });
                    });
                } else {
                    testEndedStream(function () {
                        return create().then(function (stream) {
                            return stream.catchError(function (e) { fail(); throw e; });
                        });
                    }, true);

                    describe("closing the parent stream", {
                        it("should ignore close() and it should not change from Ended", function (done) {
                            create().then(function (parent) {
                                var child = parent.catchError(function (e) { fail(); throw e; });
                                parent.close(); // It can not close the ended stream.
                                child.state.should.equal(Ended);

                                child.finally(function () {});
                                wait(5, function () {
                                    child.state.should.equal(Ended);
                                    done();
                                });
                            });
                        });

                        it("should pass when it is called close() 2-times", function (done) {
                            create().then(function (parent) {
                                var child = parent.catchError(function (e) { fail(); throw e; });
                                parent.close(); // It can not close the ended stream.
                                parent.close();
                                child.state.should.equal(Ended);

                                child.finally(function () {});
                                wait(5, function () {
                                    child.state.should.equal(Ended);
                                    done();
                                });
                            });
                        });
                    });
                }
            });
        }

        function testNeverStream(create: Void -> Promise<ReactiveStream<Int>>, isRecovered = false) {
            describe("state", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        stream.state.should.equal(Never);
                        done();
                    });
                });
            });

            describe("subscribe()", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribe(function (_) fail());
                        stream.state.should.equal(Never);

                        unsubscribe();
                        stream.state.should.equal(Never);
                        done();
                    });
                });
            });

            describe("subscribeEnd()", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribeEnd(function () fail());
                        stream.state.should.equal(Never);

                        unsubscribe();
                        stream.state.should.equal(Never);
                        done();
                    });
                });
            });

            describe("subscribeError()", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribeError(function (_) fail());
                        stream.state.should.equal(Never);

                        unsubscribe();
                        stream.state.should.equal(Never);
                        done();
                    });
                });
            });

            describe("finally()", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        var unsubscribe = stream.finally(function () fail());
                        stream.state.should.equal(Never);

                        unsubscribe();
                        stream.state.should.equal(Never);
                        done();
                    });
                });
            });

            describe("close()", {
                describe("observable", {
                    it("should pass", function (done) {
                        create().then(function (stream) {
                            var endCalled = 0;
                            var finallyCalled = 0;
                            stream.subscribe(function (_) fail());
                            stream.subscribeEnd(function () endCalled++);
                            stream.subscribeError(function (_) fail());
                            stream.finally(function () finallyCalled++);
                            stream.close();
                            stream.close();

                            stream.state.should.equal(Ended);
                            endCalled.should.be(1);
                            finallyCalled.should.be(1);
                            done();
                        });
                    });
                });

                testEndedStream(function () {
                    return create().then(function (stream) {
                        stream.close();
                        return stream;
                    });
                }, true);
            });

            describe("catchError()", {
                if (isRecovered) {
                    it("should pass", function (done) {
                        create().then(function (stream) {
                            var next = stream.catchError(function (e) throw e);
                            next.state.should.equal(Never);
                            done();
                        });
                    });
                } else {
                    testNeverStream(function () {
                        return create().then(function (stream) {
                            return stream.catchError(function (e) throw e);
                        });
                    }, true);

                    describe("closing the parent stream", {
                        it("should close and it should recover", function (done) {
                            create().then(function (parent) {
                                var child = parent.catchError(function (e) throw e);
                                child.finally(function () {
                                    done();
                                });
                                parent.close();
                                child.state.should.equal(Ended);
                            });
                        });

                        it("should pass when it is called close() 2-times", function (done) {
                            create().then(function (parent) {
                                var called = 0;
                                var child = parent.catchError(function (e) throw e);
                                child.finally(function () {
                                    called++;
                                });

                                parent.close();
                                parent.close();
                                child.state.should.equal(Ended);

                                wait(5, function () {
                                    called.should.be(1);
                                    done();
                                });
                            });
                        });
                    });
                }
            });
        }

        function testFailedStream(create: Dynamic -> Promise<ReactiveStream<Int>>, isRecovered = false) {
            describe("state", {
                it("should pass", function (done) {
                    create("error").then(function (stream) {
                        stream.state.should.equal(Failed("error"));
                        done();
                    });
                });
            });

            describe("subscribe()", {
                it("should pass", function (done) {
                    create("error").then(function (stream) {
                        var unsubscribe = stream.subscribe(function (_) fail());
                        stream.state.should.equal(Failed("error"));

                        unsubscribe();
                        stream.state.should.equal(Failed("error"));
                        done();
                    });
                });
            });

            describe("subscribeEnd()", {
                it("should pass", function (done) {
                    create("error").then(function (stream) {
                        var unsubscribe = stream.subscribeEnd(function () fail());
                        stream.state.should.equal(Failed("error"));

                        unsubscribe();
                        stream.state.should.equal(Failed("error"));
                        done();
                    });
                });
            });

            describe("subscribeError()", {
                it("should pass", function (done) {
                    create("error").then(function (stream) {
                        var called = 0;
                        var unsubscribe = stream.subscribeError(function (_) called++);
                        stream.state.should.equal(Failed("error"));
                        called.should.be(1);

                        unsubscribe();
                        stream.state.should.equal(Failed("error"));
                        called.should.be(1);
                        done();
                    });
                });
            });

            describe("finally()", {
                it("should pass", function (done) {
                    create("error").then(function (stream) {
                        var called = 0;
                        var unsubscribe = stream.finally(function () called++);
                        stream.state.should.equal(Failed("error"));
                        called.should.be(1);

                        unsubscribe();
                        stream.state.should.equal(Failed("error"));
                        called.should.be(1);
                        done();
                    });
                });
            });

            describe("close()", {
                if (isRecovered) {
                    it("should not change state", function (done) {
                        create("error").then(function (stream) {
                            stream.state.should.equal(Failed("error"));
                            done();
                        });
                    });
                } else {
                    describe("observable", {
                        it("should pass", function (done) {
                            create("error").then(function (stream) {
                                var errors = [];
                                var finallyCalled = 0;
                                stream.subscribe(function (_) fail());
                                stream.subscribeEnd(function () fail());
                                stream.subscribeError(function (e) errors.push(e));
                                stream.finally(function () finallyCalled++);
                                stream.close();
                                stream.close();

                                stream.state.should.equal(Failed("error"));
                                errors.should.containExactly(["error"]);
                                finallyCalled.should.be(1);
                                done();
                            });
                        });
                    });

                    testFailedStream(function (error) {
                        return create(error).then(function (stream) {
                            stream.close();
                            return stream;
                        });
                    }, true);
                }
            });

            describe("catchError()", {
                it("should be a failed stream", function (done) {
                    create("error").then(function (stream) {
                        stream.catchError(function (e) {
                            return ReactiveStream.empty();
                        });
                        stream.state.should.equal(Failed("error"));
                        done();
                    });
                });

                it("should not call a handler when it is not subscribed", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        var next = stream.catchError(function (e) {
                            called = true;
                            throw e;
                        });
                        called.should.be(false);
                        stream.state.should.equal(Failed("error"));
                        next.state.should.equal(Init);
                        done();
                    });
                });

                it("should call a handler when it is subscribed", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        var next = stream.catchError(function (e) {
                            called = true;
                            throw e;
                        });
                        next.finally(function () {});
                        Dispatcher.dispatch(function () {
                            called.should.be(true);
                            stream.state.should.equal(Failed("error"));
                            next.state.should.not.equal(Init);
                            done();
                        });
                    });
                });

                function testParentClosing(recover: Dynamic -> ReactiveStream<Int>, state: ReactiveStreamState) {
                    describe("closing the parent stream", {
                        it("should ignore close() and it should recover lazy", function (done) {
                            create("xxx").then(function (parent) {
                                var child = parent.catchError(recover);
                                parent.close(); // It can not close the failed stream
                                child.state.should.equal(Init);

                                child.finally(function () {});
                                wait(5, function () {
                                    child.state.should.equal(state);
                                    done();
                                });
                            });
                        });

                        it("should pass when it is called close() 2-times", function (done) {
                            create("xxx").then(function (parent) {
                                var child = parent.catchError(recover);
                                parent.close(); // It can not close the failed stream
                                parent.close();
                                child.state.should.equal(Init);

                                child.finally(function () {});
                                wait(5, function () {
                                    child.state.should.equal(state);
                                    done();
                                });
                            });
                        });
                    });
                }

                describe("recovery by the alt stream", {
                    testInitStream(function (middleware) {
                        return create("error").then(function (stream) {
                            return new SyncPromise(function (f, _) {
                                var next = stream.catchError(function (e) return ReactiveStream.create(middleware));
                                next.state.should.equal(Init);
                                f(next);
                            });
                        });
                    }, true);
                });

                describe("recovery by the never stream", {
                    testNeverStream(function () {
                        return create("error").then(function (stream) {
                            var next = stream.catchError(function (e) return ReactiveStream.never());
                            next.state.should.equal(Init);
                            next.finally(function () {});
                            return new SyncPromise(function (f, _) wait(5, f.bind(next)));
                        });
                    }, true);

                    testParentClosing(function (e) return ReactiveStream.never(), Never);
                });

                describe("recovery by the ended stream", {
                    testEndedStream(function () {
                        return create("error").then(function (stream) {
                            var child = stream.catchError(function (e) return ReactiveStream.empty());
                            child.state.should.equal(Init);
                            child.finally(function () {});
                            return new SyncPromise(function (f, _) wait(5, f.bind(child)));
                        });
                    }, true);

                    testParentClosing(function (e) return ReactiveStream.empty(), Ended);
                });

                describe("recovery by the failed stream", {
                    if (isRecovered) {
                        it("should pass", function (done) {
                            create("xxx").then(function (stream) {
                                var child = stream.catchError(function (e) return ReactiveStream.fail("error"));
                                child.state.should.equal(Init);
                                child.finally(function () {});
                                wait(5, function () {
                                    child.state.should.equal(Failed("error"));
                                    done();
                                });
                            });
                        });
                    } else {
                        testFailedStream(function (error) {
                            return create("xxx").then(function (stream) {
                                var child = stream.catchError(function (e) return ReactiveStream.fail(error));
                                child.state.should.equal(Init);
                                child.finally(function () {});
                                return new SyncPromise(function (f, _) wait(5, f.bind(child)));
                            });
                        }, true);

                        testParentClosing(function (e) return ReactiveStream.fail("error"), Failed("error"));
                    }
                });

                describe("throw error", {
                    if (isRecovered) {
                        it("should pass", function (done) {
                            create("xxx").then(function (stream) {
                                var child = stream.catchError(function (e) throw "error");
                                child.state.should.equal(Init);
                                child.finally(function () {});
                                wait(5, function () {
                                    child.state.should.equal(Failed("error"));
                                    done();
                                });
                            });
                        });
                    } else {
                        testFailedStream(function (error) {
                            return create("xxx").then(function (stream) {
                                var child = stream.catchError(function (e) throw error);
                                child.state.should.equal(Init);
                                child.finally(function () {});
                                return new SyncPromise(function (f, _) wait(5, f.bind(child)));
                            });
                        }, true);

                        testParentClosing(function (e) throw "error", Failed("error"));
                    }
                });
            });
        }

        testInitStream = function (create: ReactableStreamMiddleware<Int> -> Promise<ReactiveStream<Int>>, isRecovered = false) {
            describe("init", {
                it("should not evaluate the middleware", function (done) {
                    create(function (ctx) {
                        fail();
                        return { attach: function () {}, detach: function () {}, close: function () {} }
                    }).then(function (stream) {
                        done();
                    });
                });

                it("should be Init", function (done) {
                    create(function (ctx) {
                        return { attach: function () {}, detach: function () {}, close: function () {} }
                    }).then(function (stream) {
                        stream.state.should.equal(Init);
                        done();
                    });
                });
            });

            function testMiddlewareEvaluation(trigger: ReactiveStream<Int> -> (Void -> Void)) {
                describe("middleware evaluation", {
                    it("should evaluate the middleware lazy", function (done) {
                        var called = 0;
                        create(function (ctx) {
                            called++;
                            return { attach: function () {}, detach: function () {}, close: function () {} }
                        }).then(function (stream) {
                            trigger(stream);
                            stream.state.should.equal(Running);
                            called.should.be(0);

                            wait(5, function () {
                                stream.state.should.equal(Running);
                                called.should.be(1);
                                done();
                            });
                        });
                    });

                    it("should not evaluate the middleware when it is closed before the prepareing", function (done) {
                        create(function (ctx) {
                            fail();
                            return { attach: function () {}, detach: function () {}, close: function () fail() }
                        }).then(function (stream) {
                            stream.close();
                            trigger(stream);
                            stream.state.should.equal(Ended);
                            wait(5, function () {
                                stream.state.should.equal(Ended);
                                done();
                            });
                        });
                    });

                    it("should not evaluate the middleware when it is closed before the completion of the preparing", function (done) {
                        create(function (ctx) {
                            fail();
                            return { attach: function () {}, detach: function () {}, close: function () fail() }
                        }).then(function (stream) {
                            trigger(stream);
                            stream.close();
                            stream.state.should.equal(Ended);
                            wait(5, function () {
                                stream.state.should.equal(Ended);
                                done();
                            });
                        });
                    });

                    if (isRecovered) {
                        it("should not evaluate the middleware when it is detached before the completion of the preparing", function (done) {
                            create(function (ctx) {
                                fail();
                                return { attach: function () {}, detach: function () {}, close: function () fail() }
                            }).then(function (stream) {
                                var un = trigger(stream);
                                un();
                                stream.state.should.equal(Running);

                                wait(5, function () {
                                    stream.state.should.equal(Suspended);
                                    done();
                                });
                            });
                        });
                    } else {
                        it("should evaluate the middleware when it is detached before the completion of the preparing", function (done) {
                            var called = 0;
                            create(function (ctx) {
                                called++;
                                return { attach: function () {}, detach: function () {}, close: function () fail() }
                            }).then(function (stream) {
                                var un = trigger(stream);
                                un();
                                stream.state.should.equal(Running);
                                called.should.be(0);

                                wait(5, function () {
                                    stream.state.should.equal(Suspended);
                                    called.should.be(1);
                                    done();
                                });
                            });
                        });
                    }

                    it("should evaluate the middleware once when it is re-attached", function (done) {
                        var called = 0;
                        create(function (ctx) {
                            called++;
                            return { attach: function () {}, detach: function () {}, close: function () {} }
                        }).then(function (stream) {
                            var un = trigger(stream);
                            stream.state.should.equal(Running);
                            called.should.be(0);

                            wait(5, function () {
                                stream.state.should.equal(Running);
                                called.should.be(1);

                                un();
                                stream.state.should.equal(Suspended);

                                trigger(stream);
                                stream.state.should.equal(Running);

                                stream.subscribe(function (_) fail());
                                wait(5, function () {
                                    called.should.be(1);
                                    done();
                                });
                            });
                        });
                    });
                });

                describe("middleware controller", {
                    it("should call attach() and detach()", function (done) {
                        var attachCalled = 0;
                        var detachCalled = 0;
                        var closeCalled = 0;
                        create(function (ctx) {
                            return {
                                attach: function () attachCalled++,
                                detach: function () detachCalled++,
                                close: function () closeCalled++
                            }
                        }).then(function (stream) {
                            var un = trigger(stream);

                            stream.state.should.equal(Running);
                            attachCalled.should.be(0);
                            detachCalled.should.be(0);
                            closeCalled.should.be(0);

                            wait(5, function () {
                                stream.state.should.equal(Running);
                                attachCalled.should.be(1);
                                detachCalled.should.be(0);
                                closeCalled.should.be(0);

                                un();
                                stream.state.should.equal(Suspended);
                                attachCalled.should.be(1);
                                detachCalled.should.be(0);
                                closeCalled.should.be(0);

                                wait(5, function () {
                                    stream.state.should.equal(Suspended);
                                    attachCalled.should.be(1);
                                    detachCalled.should.be(1);
                                    closeCalled.should.be(0);
                                    done();
                                });
                            });
                        });
                    });

                    it("should call close()", function (done) {
                        var called = 0;
                        create(function (ctx) {
                            return { attach: function () {}, detach: function () {}, close: function () called++ }
                        }).then(function (stream) {
                            trigger(stream);
                            wait(5, function () {
                                stream.close();
                                stream.state.should.equal(Ended);
                                called.should.be(1);
                                done();
                            });
                        });
                    });

                    it("should not call close() when it do not evaluate the middleware", function (done) {
                        create(function (ctx) {
                            fail();
                            return { attach: function () {}, detach: function () {}, close: function () fail() }
                        }).then(function (stream) {
                            stream.close();
                            stream.state.should.equal(Ended);
                            wait(5, function () {
                                stream.state.should.equal(Ended);
                                done();
                            });
                        });
                    });

                    it("should not call close() when it is detached before the completion of the preparing", function (done) {
                        create(function (ctx) {
                            return { attach: function () {}, detach: function () {}, close: function () fail() }
                        }).then(function (stream) {
                            trigger(stream);
                            stream.close();
                            stream.state.should.equal(Ended);
                            wait(5, function () {
                                stream.state.should.equal(Ended);
                                done();
                            });
                        });
                    });
                });
            }

            describe("subscribe()", {
                testMiddlewareEvaluation(function (stream) return stream.subscribe(function (_) {}));
            });

            describe("subscribeEnd()", {
                testMiddlewareEvaluation(function (stream) return stream.subscribeEnd(function () {}));
            });

            describe("subscribeError()", {
                testMiddlewareEvaluation(function (stream) return stream.subscribeError(function (_) {}));
            });

            describe("finally()", {
                testMiddlewareEvaluation(function (stream) return stream.finally(function () {}));
            });

            describe("close()", {
                testEndedStream(function () {
                    return create(function (ctx) {
                        return { attach: function () {}, detach: function () {}, close: function () {} }
                    }).then(function (stream) {
                        stream.close();
                        return stream;
                    });
                });
            });

            testObservable(create);

            describe("catchError()", {
                function testParentClosing(recover: Dynamic -> ReactiveStream<Int>) {
                    describe("closing the parent stream", {
                        function test(state: ReactiveStreamState, create: Void -> Promise<ReactiveStream<Int>>) {
                            it('should close and it should not recover when it is the ${state.getName()}', function (done) {
                                var recoverd = false;
                                create().then(function (parent) {
                                    parent.state.should.equal(state);

                                    var child = parent.catchError(function (error) {
                                        recoverd = true;
                                        return recover(error);
                                    });
                                    parent.close();
                                    child.state.should.equal(Ended);

                                    child.finally(function () {
                                        child.state.should.equal(Ended);
                                        recoverd.should.be(false);
                                        done();
                                    });
                                });
                            });

                            it("should pass when it is called close() 2-times", function (done) {
                                create().then(function (parent) {
                                    var child = parent.catchError(recover);
                                    parent.close();
                                    parent.close();
                                    child.state.should.equal(Ended);

                                    child.finally(function () {});
                                    wait(5, function () {
                                        child.state.should.equal(Ended);
                                        done();
                                    });
                                });
                            });
                        }

                        test(Init, function () {
                            return create(function (ctx) {
                                return { attach: function () {}, detach: function () {}, close: function () {} }
                            });
                        });

                        test(Running, function () {
                            return create(function (ctx) {
                                return { attach: function () {}, detach: function () {}, close: function () {} }
                            }).then(function (parent) {
                                return new SyncPromise(function (f, _) {
                                    parent.finally(function () {});
                                    wait(5, f.bind(parent));
                                });
                            });
                        });

                        test(Suspended, function () {
                            return create(function (ctx) {
                                return { attach: function () {}, detach: function () {}, close: function () {} }
                            }).then(function (parent) {
                                return new SyncPromise(function (f, _) {
                                    var un = parent.finally(function () {});
                                    un();
                                    wait(5, f.bind(parent));
                                });
                            });
                        });
                    });
                }

                describe("base stream event notification", {
                    it("should notify the value from the base stream", function (done) {
                        var values = [];
                        var countEnd = 0;
                        var errors = [];
                        var countFinally = 0;
                        var caughtErrors = [];
                        create(function (ctx) {
                            ctx.emit(10);
                            ctx.emit(20);
                            return { attach: function () {}, detach: function () {}, close: function () {} }
                        }).then(function (stream) {
                            var child = stream.catchError(function (e) throw e);
                            child.subscribe(function (x) {
                                values.push(x);
                            });
                            child.subscribeEnd(function () {
                                countEnd++;
                            });
                            child.subscribeError(function (e) {
                                errors.push(e);
                            });
                            child.finally(function () {
                                countFinally++;
                            });
                            child.catchError(function (e) {
                                caughtErrors.push(e);
                                throw e;
                            });

                            wait(5, function () {
                                values.should.containExactly([10, 20]);
                                countEnd.should.be(0);
                                errors.should.containExactly([]);
                                countFinally.should.be(0);
                                caughtErrors.should.containExactly([]);
                                done();
                            });
                        });
                    });

                    it("should notify the end from the base stream", function (done) {
                        var values = [];
                        var countEnd = 0;
                        var errors = [];
                        var countFinally = 0;
                        var caughtErrors = [];
                        create(function (ctx) {
                            ctx.emit(10);
                            ctx.emitEnd();
                            return { attach: function () {}, detach: function () {}, close: function () {} }
                        }).then(function (stream) {
                            var child = stream.catchError(function (e) throw e);
                            child.subscribe(function (x) {
                                values.push(x);
                            });
                            child.subscribeEnd(function () {
                                countEnd++;
                            });
                            child.subscribeError(function (e) {
                                errors.push(e);
                            });
                            child.finally(function () {
                                countFinally++;
                            });
                            child.catchError(function (e) {
                                caughtErrors.push(e);
                                throw e;
                            });

                            wait(5, function () {
                                values.should.containExactly([10]);
                                countEnd.should.be(1);
                                errors.should.containExactly([]);
                                countFinally.should.be(1);
                                caughtErrors.should.containExactly([]);
                                done();
                            });
                        });
                    });
                });

                describe("recovery by the never stream", {
                    it("should change the state lazy", function (done) {
                        return create(function (ctx) {
                            ctx.throwError("error");
                            return { attach: function () {}, detach: function () {}, close: function () {} }
                        }).then(function (stream) {
                            var child = stream.catchError(function (e) return ReactiveStream.never());
                            child.state.should.equal(Init);

                            child.finally(function () {});
                            child.state.should.equal(Running);
                            wait(5, function () {
                                child.state.should.equal(Never);
                                done();
                            });
                        });
                    });

                    testNeverStream(function () {
                        return create(function (ctx) {
                            ctx.throwError("error");
                            return { attach: function () {}, detach: function () {}, close: function () {} }
                        }).then(function (stream) {
                            var child = stream.catchError(function (e) return ReactiveStream.never());
                            child.finally(function () {});
                            return new SyncPromise(function (f, _) wait(5, f.bind(child)));
                        });
                    }, true);

                    testParentClosing(function (e) return ReactiveStream.never());
                });

                describe("recovery by the ended stream", {
                    it("should change the state lazy", function (done) {
                        return create(function (ctx) {
                            ctx.throwError("error");
                            return { attach: function () {}, detach: function () {}, close: function () {} }
                        }).then(function (stream) {
                            var child = stream.catchError(function (e) return ReactiveStream.empty());
                            child.state.should.equal(Init);

                            child.finally(function () {});
                            child.state.should.equal(Running);
                            wait(5, function () {
                                child.state.should.equal(Ended);
                                done();
                            });
                        });
                    });

                    testEndedStream(function () {
                        return create(function (ctx) {
                            ctx.throwError("error");
                            return { attach: function () {}, detach: function () {}, close: function () {} }
                        }).then(function (stream) {
                            var child = stream.catchError(function (e) return ReactiveStream.empty());
                            child.finally(function () {});
                            return new SyncPromise(function (f, _) wait(5, f.bind(child)));
                        });
                    }, true);

                    testParentClosing(function (e) return ReactiveStream.empty());
                });

                function testRecoveringByFailed(recover: Dynamic -> ReactiveStream<Int>): Void {
                    if (isRecovered) {
                        it("should pass", function (done) {
                            return create(function (ctx) {
                                ctx.throwError("xxx");
                                return { attach: function () {}, detach: function () {}, close: function () {} }
                            }).then(function (stream) {
                                var next = stream.catchError(function (_) return recover("error"));
                                next.state.should.equal(Init);
                                next.finally(function () {});
                                wait(5, function () {
                                    next.state.should.equal(Failed("error"));
                                    done();
                                });
                            });
                        });
                    } else {
                        testFailedStream(function (error) {
                            return create(function (ctx) {
                                ctx.throwError("xxx");
                                return { attach: function () {}, detach: function () {}, close: function () {} }
                            }).then(function (stream) {
                                var child = stream.catchError(function (_) return recover(error));
                                child.finally(function () {});
                                return new SyncPromise(function (f, _) wait(5, f.bind(child)));
                            });
                        }, true);

                        testParentClosing(recover);
                    }
                }

                describe("recovery by the failed stream", {
                    testRecoveringByFailed(function (e) return ReactiveStream.fail("error"));
                });

                describe("recovery by throw", {
                    testRecoveringByFailed(function (e) throw "error");
                });
            });
        }

        // --------------------------------------------------------------------
        // test main
        // --------------------------------------------------------------------
        describe("ReactiveStream.create()", {
            testInitStream(function (middleware) return SyncPromise.resolve(ReactiveStream.create(middleware)));
        });

        describe("ReactiveStream.never()", {
            testNeverStream(function () return SyncPromise.resolve(ReactiveStream.never()));
        });

        describe("ReactiveStream.empty()", {
            testEndedStream(function () return SyncPromise.resolve(ReactiveStream.empty()));
        });

        describe("ReactiveStream.fail()", {
            testFailedStream(function (error) return SyncPromise.resolve(ReactiveStream.fail(error)));
        });
    }
}