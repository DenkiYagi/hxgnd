package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using buddy.Should;
import hxgnd.ReactiveStream;

class ReactiveStreamTest extends BuddySuite {
    public function new() {
        var testInitStream: (ReactableStreamMiddleware<Int> -> Promise<ReactiveStream<Int>>) -> Bool -> Void;

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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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
                        new Promise(function (f, _) {
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

        function testEndedStream(create: Void -> Promise<ReactiveStream<Int>>, tail = false) {
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
                if (tail) {
                    it("should not change state", function (done) {
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
                if (tail) {
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

                    describe("close the parent stream", {
                        it("should pass", function (done) {
                            create().then(function (parent) {
                                var endCalled = 0;
                                var child = parent.catchError(function (e) { fail(); throw e; });
                                child.state.should.equal(Ended);

                                child.subscribeEnd(function () endCalled++);
                                endCalled.should.be(1);
                                parent.close();
                                parent.close();

                                child.state.should.equal(Ended);
                                endCalled.should.be(1);
                                done();
                            });
                        });
                    });
                }
            });
        }

        function testNeverStream(create: Void -> Promise<ReactiveStream<Int>>, tail = false) {
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
                if (tail) {
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

                    describe("close the parent stream", {
                        it("should pass", function (done) {
                            create().then(function (parent) {
                                var endCalled = 0;
                                var child = parent.catchError(function (e) throw e);
                                child.state.should.equal(Never);

                                child.subscribeEnd(function () endCalled++);
                                parent.close();
                                parent.close();

                                child.state.should.equal(Ended);
                                endCalled.should.be(1);
                                done();
                            });
                        });
                    });
                }
            });
        }

        function testFailedStream(create: Dynamic -> Promise<ReactiveStream<Int>>, tail = false) {
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
                if (tail) {
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
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Failed("error"));
                            next.state.should.equal(Init);
                            done();
                        });
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
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Failed("error"));
                            next.state.should.not.equal(Init);
                            done();
                        });
                    });
                });

                describe("to the alt stream", {
                    testInitStream(function (middleware) {
                        return create("error").then(function (stream) {
                            return new Promise(function (f, _) {
                                var next = stream.catchError(function (e) return ReactiveStream.create(middleware));
                                next.state.should.equal(Init);
                                f(next);
                            });
                        });
                    }, true);
                });

                describe("to the never stream", {
                    testNeverStream(function () {
                        return create("error").then(function (stream) {
                            var next = stream.catchError(function (e) return ReactiveStream.never());
                            next.state.should.equal(Init);
                            next.finally(function () {});
                            next.state.should.equal(Never);
                            return next;
                        });
                    }, true);

                    describe("close the parent stream", {
                        it("should pass", function (done) {
                            create("error").then(function (parent) {
                                var child = parent.catchError(function (e) return ReactiveStream.never());
                                child.state.should.equal(Init);
                                child.subscribeEnd(function () fail());
                                parent.close();
                                parent.close();

                                child.state.should.equal(Never);
                                done();
                            });
                        });
                    });
                });

                describe("to the ended stream", {
                    testEndedStream(function () {
                        return create("error").then(function (stream) {
                            var next = stream.catchError(function (e) return ReactiveStream.empty());
                            next.finally(function () {});
                            return next;
                        });
                    }, true);

                    describe("close the parent stream", {
                        it("should pass", function (done) {
                            create("xxx").then(function (parent) {
                                var child = parent.catchError(function (e) return ReactiveStream.empty());
                                child.state.should.equal(Init);

                                var count = 0;
                                child.subscribeEnd(function () count++);
                                child.state.should.equal(Ended);
                                count.should.be(1);

                                parent.close();
                                parent.close();
                                child.state.should.equal(Ended);
                                count.should.be(1);
                                done();
                            });
                        });
                    });
                });

                describe("to the failed stream", {
                    if (tail) {
                        it("should pass", function (done) {
                            create("xxx").then(function (stream) {
                                var next = stream.catchError(function (e) return ReactiveStream.fail("error"));
                                next.state.should.equal(Init);
                                next.finally(function () {});
                                next.state.should.equal(Failed("error"));
                                done();
                            });
                        });
                    } else {
                        testFailedStream(function (error) {
                            return create("xxx").then(function (stream) {
                                var next = stream.catchError(function (e) return ReactiveStream.fail(error));
                                next.state.should.equal(Init);
                                next.finally(function () {});
                                next.state.should.equal(Failed(error));
                                return next;
                            });
                        }, true);

                        describe("close the parent stream", {
                            it("should pass", function (done) {
                                create("xxx").then(function (parent) {
                                    var child = parent.catchError(function (e) return ReactiveStream.fail("error"));
                                    child.subscribeEnd(function () fail());
                                    parent.close();
                                    parent.close();

                                    child.state.should.equal(Failed("error"));
                                    done();
                                });
                            });
                        });
                    }
                });

                describe("throw error", {
                    if (tail) {
                        it("should pass", function (done) {
                            create("xxx").then(function (stream) {
                                var next = stream.catchError(function (e) throw "error");
                                next.state.should.equal(Init);
                                next.finally(function () {});
                                next.state.should.equal(Failed("error"));
                                done();
                            });
                        });

                    } else {
                        testFailedStream(function (error) {
                            return create("xxx").then(function (stream) {
                                var next = stream.catchError(function (e) throw error);
                                next.state.should.equal(Init);
                                next.finally(function () {});
                                next.state.should.equal(Failed(error));
                                return next;
                            });
                        }, true);

                        describe("close the parent stream", {
                            it("should pass", function (done) {
                                create("xxx").then(function (parent) {
                                    var child = parent.catchError(function (e) throw "error");
                                    child.subscribeEnd(function () fail());
                                    parent.close();
                                    parent.close();

                                    child.state.should.equal(Failed("error"));
                                    done();
                                });
                            });
                        });
                    }
                });
            });
        }

        testInitStream = function testInitStream(create: ReactableStreamMiddleware<Int> -> Promise<ReactiveStream<Int>>, tail = false) {
            describe("init", {
                it("should not call middleware", function (done) {
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

            describe("subscribe()", {
                it("should pass", function (done) {
                    var called = true;
                    create(function (ctx) {
                        called = true;
                        return { attach: function () {}, detach: function () {}, close: function () {} }
                    }).then(function (stream) {
                        var unsubscribe = stream.subscribe(function (_) fail());
                        stream.state.should.equal(Running);
                        called.should.be(true);

                        unsubscribe();
                        stream.state.should.equal(Suspended);
                        done();
                    });
                });
            });

            describe("subscribeEnd()", {
                it("should pass", function (done) {
                    var called = true;
                    create(function (ctx) {
                        called = true;
                        return { attach: function () {}, detach: function () {}, close: function () {} }
                    }).then(function (stream) {
                        var unsubscribe = stream.subscribeEnd(function () fail());
                        stream.state.should.equal(Running);
                        called.should.be(true);

                        unsubscribe();
                        stream.state.should.equal(Suspended);
                        done();
                    });
                });
            });

            describe("subscribeEnd()", {
                it("should pass", function (done) {
                    var called = true;
                    create(function (ctx) {
                        called = true;
                        return { attach: function () {}, detach: function () {}, close: function () {} }
                    }).then(function (stream) {
                        var unsubscribe = stream.subscribeError(function (_) fail());
                        stream.state.should.equal(Running);
                        called.should.be(true);

                        unsubscribe();
                        stream.state.should.equal(Suspended);
                        done();
                    });
                });
            });

            describe("finally()", {
                it("should pass", function (done) {
                    var called = true;
                    create(function (ctx) {
                        called = true;
                        return { attach: function () {}, detach: function () {}, close: function () {} }
                    }).then(function (stream) {
                        var unsubscribe = stream.finally(function () fail());
                        stream.state.should.equal(Running);
                        called.should.be(true);

                        unsubscribe();
                        stream.state.should.equal(Suspended);
                        done();
                    });
                });
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
                describe("chain", {
                    it("should", function (done) {
                        var values = [];
                        var countEnd = 0;
                        var errors = [];
                        var countFinally = 0;
                        var caughtErrors = [];
                        create(function (ctx) {
                            trace("middleware");
                            trace(ctx.stream.state);
                            ctx.emit(10);
                            ctx.emit(20);
                            return { attach: function () {}, detach: function () {}, close: function () {} }
                        }).then(function (stream) {
                            var next = stream.catchError(function (e) throw e);
                            next.subscribe(function (x) {
                                values.push(x);
                            });
                            next.subscribeEnd(function () {
                                countEnd++;
                            });
                            next.subscribeError(function (e) {
                                errors.push(e);
                            });
                            next.finally(function () {
                                countFinally++;
                            });
                            next.catchError(function (e) {
                                caughtErrors.push(e);
                                throw e;
                            });

                            values.should.containExactly([10, 20]);
                            countEnd.should.be(0);
                            errors.should.containExactly([]);
                            countFinally.should.be(0);
                            caughtErrors.should.containExactly([]);
                            done();
                        });
                    });
                });
            });
        }

        function testActiveStream(create: ReactableStreamMiddleware<Int> -> Promise<ReactiveStream<Int>>, tail = false) {
            // TODO
            // describe("state", {
            //     it("should pass", function (done) {
            //         create(function (ctx) {
            //             return {
            //                 attach: function () {},
            //                 detach: function () {},
            //                 close: function () {}
            //             }
            //         }).then(function (stream) {
            //             stream.state.should.equal(Running);
            //             done();
            //         });
            //     });
            // });

            testObservable(create);

            // if (!tail) {
            //     describe("catchError()", {
            //         // TODO

            //         describe("to an active stream", {
            //         });

            //         describe("to the never stream", {
            //             testNeverStream(function () {
            //                 return create(function (ctx) throw "xxx").then(function (stream) {
            //                     return new Promise(function (f, _) {
            //                         var next = stream.catchError(function (e) return ReactiveStream.never());
            //                         next.finally(function () {});
            //                         wait(5, f.bind(next));
            //                     });
            //                 });
            //             }, true);
            //         });

            //         describe("to the ended stream", {
            //             testEndedStream(function () {
            //                 return create(function (ctx) throw "xxx").then(function (stream) {
            //                     return new Promise(function (f, _) {
            //                         var next = stream.catchError(function (e) return ReactiveStream.empty());
            //                         next.finally(function () {});
            //                         wait(5, f.bind(next));
            //                     });
            //                 });
            //             }, true);
            //         });

            //         describe("to the failed stream", {
            //             testFailedStream(function (error) {
            //                 return create(function (ctx) throw "xxx").then(function (stream) {
            //                     return new Promise(function (f, _) {
            //                         var next = stream.catchError(function (e) return ReactiveStream.fail(error));
            //                         next.finally(function () {});
            //                         wait(5, f.bind(next));
            //                     });
            //                 });
            //             }, true);
            //         });

            //         describe("throw error", {
            //             testFailedStream(function (error) {
            //                 return create(function (ctx) throw "xxx").then(function (stream) {
            //                     return new Promise(function (f, _) {
            //                         var next = stream.catchError(function (e) throw error);
            //                         next.finally(function () {});
            //                         wait(5, f.bind(next));
            //                     });
            //                 });
            //             }, true);
            //         });
            //     });
            // }

            describe("close()", {
                testEndedStream(function () {
                    return create(function (ctx) {
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.close();
                        return stream;
                    });
                });
            });
        }


        // --------------------------------------------------------------------
        // test main
        // --------------------------------------------------------------------
        describe("ReactiveStream.create()", {

        //     describe("subscribeEnd()", {
        //         describe("running", {
        //             it("should call middleware", function (done) {
        //                 var called = false;
        //                 var stream = ReactiveStream.create(function (ctx) {
        //                     called = true;
        //                     return {
        //                         attach: function () {},
        //                         detach: function () {},
        //                         close: function () {}
        //                     }
        //                 });
        //                 stream.subscribeEnd(function () fail());
        //                 wait(10, function () {
        //                     called.should.be(true);
        //                     stream.state.should.equal(Running);
        //                     done();
        //                 });
        //             });

        //             testActiveStream(function (middleware) {
        //                 var stream = ReactiveStream.create(middleware);
        //                 stream.subscribeEnd(function () {});
        //                 return Promise.resolve(stream);
        //             });
        //         });

        //         describe("suspended", {
        //             testSuspendedStream(function (middleware) {
        //                 return new Promise(function (f, _) {
        //                     var stream = ReactiveStream.create(middleware);
        //                     var unsubscribe = stream.subscribeEnd(function () {});
        //                     unsubscribe();
        //                     wait(5, f.bind(stream));
        //                 });
        //             });
        //         });

        //         testEndedStream(function () {
        //             var stream = ReactiveStream.create(function (ctx) {
        //                 return {
        //                     attach: function () {},
        //                     detach: function () {},
        //                     close: function () {}
        //                 }
        //             });
        //             stream.subscribeEnd(function () {});
        //             stream.close();
        //             return SyncPromise.resolve(stream);
        //         });
        //     });

        //     describe("subscribeError()", {
        //         describe("running", {
        //             it("should call middleware", function (done) {
        //                 var called = false;
        //                 var stream = ReactiveStream.create(function (ctx) {
        //                     called = true;
        //                     return {
        //                         attach: function () {},
        //                         detach: function () {},
        //                         close: function () {}
        //                     }
        //                 });
        //                 stream.subscribeError(function (_) fail());
        //                 wait(10, function () {
        //                     called.should.be(true);
        //                     stream.state.should.equal(Running);
        //                     done();
        //                 });
        //             });

        //             testActiveStream(function (middleware) {
        //                 var stream = ReactiveStream.create(middleware);
        //                 stream.subscribeError(function (_) {});
        //                 return Promise.resolve(stream);
        //             });
        //         });

        //         describe("suspended", {
        //             testSuspendedStream(function (middleware) {
        //                 return new Promise(function (f, _) {
        //                     var stream = ReactiveStream.create(middleware);
        //                     var unsubscribe = stream.subscribeError(function (e) {});
        //                     unsubscribe();
        //                     wait(5, f.bind(stream));
        //                 });
        //             });
        //         });

        //         testEndedStream(function () {
        //             var stream = ReactiveStream.create(function (ctx) {
        //                 return {
        //                     attach: function () {},
        //                     detach: function () {},
        //                     close: function () {}
        //                 }
        //             });
        //             stream.subscribeError(function (_) fail());
        //             stream.close();
        //             return SyncPromise.resolve(stream);
        //         });
        //     });

        //     describe("finally()", {
        //         describe("running", {
        //             it("should call middleware", function (done) {
        //                 var called = false;
        //                 var stream = ReactiveStream.create(function (ctx) {
        //                     called = true;
        //                     return {
        //                         attach: function () {},
        //                         detach: function () {},
        //                         close: function () {}
        //                     }
        //                 });
        //                 stream.finally(function () fail());
        //                 wait(10, function () {
        //                     called.should.be(true);
        //                     stream.state.should.equal(Running);
        //                     done();
        //                 });
        //             });

        //             testActiveStream(function (middleware) {
        //                 var stream = ReactiveStream.create(middleware);
        //                 stream.finally(function () {});
        //                 return Promise.resolve(stream);
        //             });
        //         });

        //         describe("suspended", {
        //             testSuspendedStream(function (middleware) {
        //                 return new Promise(function (f, _) {
        //                     var stream = ReactiveStream.create(middleware);
        //                     var unsubscribe = stream.finally(function () {});
        //                     unsubscribe();
        //                     wait(5, f.bind(stream));
        //                 });
        //             });
        //         });

        //         testEndedStream(function () {
        //             var stream = ReactiveStream.create(function (ctx) {
        //                 return {
        //                     attach: function () {},
        //                     detach: function () {},
        //                     close: function () {}
        //                 }
        //             });
        //             stream.finally(function () {});
        //             stream.close();
        //             return SyncPromise.resolve(stream);
        //         });
        //     });
        });

        describe("ReactiveStream.never()", {
            testNeverStream(function () return Promise.resolve(ReactiveStream.never()));
        });

        describe("ReactiveStream.empty()", {
            testEndedStream(function () {
                return SyncPromise.resolve(ReactiveStream.empty());
            });
        });

        describe("ReactiveStream.fail()", {
            testFailedStream(function (error) {
                return SyncPromise.resolve(ReactiveStream.fail(error));
            });
        });
    }
}