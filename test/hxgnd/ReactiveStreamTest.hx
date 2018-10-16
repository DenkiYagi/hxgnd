package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using buddy.Should;
import hxgnd.ReactiveStream;

class ReactiveStreamTest extends BuddySuite {
    public function new() {
        function testMiddleware(create: ReactableStreamMiddleware<Int> -> Promise<ReactiveStream<Int>>) {
            describe("middleware", {
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
                            LangTools.same(values, []).should.be(true);
                            countEnd.should.be(0);
                            LangTools.same(errors, ["error"]).should.be(true);
                            countFinally.should.be(1);
                            LangTools.same(caughtErrors, []).should.be(true);
                            done();
                        });
                    });
                });

                it("should pass when it call [ emit ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emit(10);
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, [10]).should.be(true);
                                countEnd.should.be(0);
                                LangTools.same(errors, []).should.be(true);
                                countFinally.should.be(0);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ emitEnd ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emitEnd();
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, []).should.be(true);
                                countEnd.should.be(1);
                                LangTools.same(errors, []).should.be(true);
                                countFinally.should.be(1);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ throwError ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.throwError("error1");
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, []).should.be(true);
                                countEnd.should.be(0);
                                LangTools.same(errors, ["error1"]).should.be(true);
                                countFinally.should.be(1);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ emit, emit ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emit(10);
                        context.emit(20);
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, [10, 20]).should.be(true);
                                countEnd.should.be(0);
                                LangTools.same(errors, []).should.be(true);
                                countFinally.should.be(0);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ emit, emitEnd ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emit(10);
                        context.emitEnd();
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, [10]).should.be(true);
                                countEnd.should.be(1);
                                LangTools.same(errors, []).should.be(true);
                                countFinally.should.be(1);
                            LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ emit, throwError ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emit(10);
                        context.throwError("error2");
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, [10]).should.be(true);
                                countEnd.should.be(0);
                                LangTools.same(errors, ["error2"]).should.be(true);
                                countFinally.should.be(1);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ emitEnd, emit ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emitEnd();
                        context.emit(20);
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, []).should.be(true);
                                countEnd.should.be(1);
                                LangTools.same(errors, []).should.be(true);
                                countFinally.should.be(1);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ emitEnd, emitEnd ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emitEnd();
                        context.emitEnd();
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, []).should.be(true);
                                countEnd.should.be(1);
                                LangTools.same(errors, []).should.be(true);
                                countFinally.should.be(1);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ emitEnd, throwError ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emitEnd();
                        context.throwError("error2");
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, []).should.be(true);
                                countEnd.should.be(1);
                                LangTools.same(errors, []).should.be(true);
                                countFinally.should.be(1);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ throwError, emit ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.throwError("error1");
                        context.emit(20);
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, []).should.be(true);
                                countEnd.should.be(0);
                                LangTools.same(errors, ["error1"]).should.be(true);
                                countFinally.should.be(1);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ throwError, emitEnd ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.throwError("error1");
                        context.emitEnd();
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, []).should.be(true);
                                countEnd.should.be(0);
                                LangTools.same(errors, ["error1"]).should.be(true);
                                countFinally.should.be(1);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should pass when it call [ throwError, throwError ]", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.throwError("error1");
                        context.throwError("error2");
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
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
                            emit();
                            wait(5, function () {
                                LangTools.same(values, []).should.be(true);
                                countEnd.should.be(0);
                                LangTools.same(errors, ["error1"]).should.be(true);
                                countFinally.should.be(1);
                                LangTools.same(caughtErrors, []).should.be(true);
                                done();
                            });
                        });
                    });
                });

                it("should call all callbacks that is set subscribe()", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emit(10);
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        var called1 = 0;
                        var called2 = 0;
                        stream.subscribe(function (x) {
                            called1++;
                        });
                        stream.subscribe(function (x) {
                            called2++;
                        });

                        wait(5, function () {
                            emit();
                            wait(5, function () {
                                called1.should.be(1);
                                called2.should.be(1);
                                done();
                            });
                        });
                    });
                });

                it("should call all callbacks that is set subscribeEnd()", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emitEnd();
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        var called1 = 0;
                        var called2 = 0;
                        stream.subscribeEnd(function () {
                            called1++;
                        });
                        stream.subscribeEnd(function () {
                            called2++;
                        });

                        wait(5, function () {
                            emit();
                            wait(5, function () {
                                called1.should.be(1);
                                called2.should.be(1);
                                done();
                            });
                        });
                    });
                });

                it("should call all callbacks that is set subscribeError()", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.throwError("error");
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        var called1 = 0;
                        var called2 = 0;
                        stream.subscribeError(function (e) {
                            called1++;
                        });
                        stream.subscribeError(function (e) {
                            called2++;
                        });

                        wait(5, function () {
                            emit();
                            wait(5, function () {
                                called1.should.be(1);
                                called2.should.be(1);
                                done();
                            });
                        });
                    });
                });

                it("should call all callbacks that is set finally()", function (done) {
                    var context: ReactableStreamContext<Int>;
                    function emit() {
                        context.emitEnd();
                    }

                    create(function (ctx) {
                        context = ctx;
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        var called1 = 0;
                        var called2 = 0;
                        stream.finally(function () {
                            called1++;
                        });
                        stream.finally(function () {
                            called2++;
                        });

                        wait(5, function () {
                            emit();
                            wait(5, function () {
                                called1.should.be(1);
                                called2.should.be(1);
                                done();
                            });
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
                it("should not call a handler", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        stream.subscribe(function (_) {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });

                it("should unsubscribe", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribe(function (_) {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });
            });

            describe("subscribeEnd()", {
                it("should call a handler", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        stream.subscribeEnd(function () {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });

                it("should call all handlers", function (done) {
                    var called1 = false;
                    var called2 = false;
                    create().then(function (stream) {
                        stream.subscribeEnd(function () {
                            called1 = true;
                        });
                        stream.subscribeEnd(function () {
                            called2 = true;
                        });
                        wait(10, function () {
                            called1.should.be(true);
                            called2.should.be(true);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });

                it("should unsubscribe but it should call a handler", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribeEnd(function () {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });
            });

            describe("subscribeError()", {
                it("should not call a handler", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        stream.subscribeError(function (_) {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });

                it("should unsubscribe", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribeError(function (_) {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });
            });

            describe("catchError()", {
                it("should not call a handler when it is not subscribed", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        stream.catchError(function (e) {
                            called = true;
                            throw e;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });

                it("should not call a handler when it is subscribed", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        var next = stream.catchError(function (e) {
                            called = true;
                            throw e;
                        });
                        next.finally(function () {});
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });

                describe("returned stream", {
                    if (tail) {
                        it("should be a ended stream", function (done) {
                            create().then(function (stream) {
                                var returned = stream.catchError(function (e) throw e);
                                returned.state.should.equal(Ended);
                                done();
                            });
                        });
                    } else {
                        testEndedStream(function () {
                            return create().then(function (s) return s.catchError(function (e) throw e));
                        }, true);
                    }
                });
            });

            describe("finally()", {
                it("should call a handler", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        stream.finally(function () {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });

                it("should call all handlers", function (done) {
                    var called1 = false;
                    var called2 = false;
                    create().then(function (stream) {
                        stream.finally(function () {
                            called1 = true;
                        });
                        stream.finally(function () {
                            called2 = true;
                        });
                        wait(10, function () {
                            called1.should.be(true);
                            called2.should.be(true);
                            stream.state.should.equal(Ended);
                            done();
                        });
                    });
                });

                it("should unsubscribe but it should call a handler", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        var unsubscribe = stream.finally(function () {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Ended);
                            done();
                        });
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
                    testEndedStream(function () {
                        return create().then(function (stream) {
                            stream.close();
                            return stream;
                        });
                    }, true);

                    describe("subscribing before close()", {
                        it("should pass", function (done) {
                            var called = false;
                            create().then(function (stream) {
                                stream.subscribeEnd(function () {
                                    called = true;
                                });
                                stream.close();
                                wait(10, function () {
                                    called.should.be(true);
                                    stream.state.should.equal(Ended);
                                    done();
                                });
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
                it("should not call a handler", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        stream.subscribe(function (_) {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Never);
                            done();
                        });
                    });
                });

                it("should unsubscribe", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribe(function (_) {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Never);
                            done();
                        });
                    });
                });
            });

            describe("subscribeEnd()", {
                it("should not call a handler", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        stream.subscribeEnd(function () {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Never);
                            done();
                        });
                    });
                });

                it("should unsubscribe", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribeEnd(function () {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Never);
                            done();
                        });
                    });
                });
            });

            describe("subscribeError()", {
                it("should not call a handler", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        stream.subscribeError(function (_) {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Never);
                            done();
                        });
                    });
                });

                it("should unsubscribe", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        var unsubscribe = stream.subscribeError(function (_) {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Never);
                            done();
                        });
                    });
                });
            });

            describe("catchError()", {
                it("should not call a handler when it is not subscribed", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        stream.catchError(function (e) {
                            called = true;
                            throw e;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Never);
                            done();
                        });
                    });
                });

                it("should not call a handler when it is subscribed", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        var next = stream.catchError(function (e) {
                            called = true;
                            throw e;
                        });
                        next.finally(function () {});
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Never);
                            done();
                        });
                    });
                });

                describe("returned stream", {
                    if (tail) {
                        it("should be a never stream", function (done) {
                            create().then(function (stream) {
                                var next = stream.catchError(function (e) {
                                    return ReactiveStream.empty();
                                });
                                next.state.should.equal(Never);
                                done();
                            });
                        });
                    } else {
                        testNeverStream(function () {
                            return create().catchError(function (e) {
                                return ReactiveStream.empty();
                            });
                        }, true);
                    }
                });
            });

            describe("finally()", {
                it("should not call a handler", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        stream.finally(function () {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Never);
                            done();
                        });
                    });
                });

                it("should unsubscribe", function (done) {
                    var called = false;
                    create().then(function (stream) {
                        var unsubscribe = stream.finally(function () {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Never);
                            done();
                        });
                    });
                });
            });

            describe("close()", {
                testEndedStream(function () {
                    return create().then(function (stream) {
                        stream.close();
                        return stream;
                    });
                }, true);
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
                it("should not call a handler", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        stream.subscribe(function (_) {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Failed("error"));
                            done();
                        });
                    });
                });

                it("should unsubscribe", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        var unsubscribe = stream.subscribe(function (_) {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Failed("error"));
                            done();
                        });
                    });
                });
            });

            describe("subscribeEnd()", {
                it("should not call a handler", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        stream.subscribeEnd(function () {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Failed("error"));
                            done();
                        });
                    });
                });

                it("should unsubscribe", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        var unsubscribe = stream.subscribeEnd(function () {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Failed("error"));
                            done();
                        });
                    });
                });
            });

            describe("subscribeError()", {
                it("should call a handler", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        stream.subscribeError(function (error) {
                            called = true;
                            (error: String).should.be("error");
                        });
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Failed("error"));
                            done();
                        });
                    });
                });

                it("should unsubscribe but it should call a handler", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        var unsubscribe = stream.subscribeError(function (error) {
                            called = true;
                            (error: String).should.be("error");
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Failed("error"));
                            done();
                        });
                    });
                });
            });

            describe("catchError()", {
                it("should not call a handler when it is not subscribed", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        stream.catchError(function (e) {
                            called = true;
                            throw e;
                        });
                        wait(10, function () {
                            called.should.be(false);
                            stream.state.should.equal(Failed("error"));
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
                            done();
                        });
                    });
                });

                it("should be a failed stream", function (done) {
                    create("error").then(function (stream) {
                        stream.catchError(function (e) {
                            return ReactiveStream.empty();
                        });
                        stream.state.should.equal(Failed("error"));
                        done();
                    });
                });

                // testNeverStream(function () {
                //     return create("error").then(function (stream) {
                //         return stream.catchError(function (e) return ReactiveStream.never());
                //     });
                // }, true);

                // never
                // ended
                // failed
                // idle

                // TODO
                // describe("returned stream", {
                //     if (tail) {
                //     } else {
                //         testFailedStream(function (error) {
                //             create("xxx").then(function (s) return s.catchError(x))
                //         })
                //     }
                // });
            });

            describe("finally()", {
                it("should call a handler", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        stream.finally(function () {
                            called = true;
                        });
                        wait(10, function () {
                            called.should.be(true);
                            done();
                        });
                    });
                });

                it("should unsubscribe", function (done) {
                    var called = false;
                    create("error").then(function (stream) {
                        var unsubscribe = stream.finally(function () {
                            called = true;
                        });
                        unsubscribe();
                        wait(10, function () {
                            called.should.be(true);
                            done();
                        });
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
                    testFailedStream(function (error) {
                        return create(error).then(function (stream) {
                            stream.close();
                            return stream;
                        });
                    }, true);
                }
            });
        }

        function testInitStream(create: Void -> Promise<ReactiveStream<Int>>) {
            describe("state", {
                it("should pass", function (done) {
                    create().then(function (stream) {
                        stream.state.should.equal(Init);
                        done();
                    });
                });
            });

            describe("close()", {
                testEndedStream(function () {
                    return create().then(function (stream) {
                        stream.close();
                        return stream;
                    });
                });
            });
        }

        function testCatchError() {

        }

        function testRunningStream(create: ReactableStreamMiddleware<Int> -> Promise<ReactiveStream<Int>>) {
            describe("state", {
                it("should pass", function (done) {
                    create(function (ctx) {
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.state.should.equal(Running);
                        done();
                    });
                });
            });

            testMiddleware(create);

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

        function testSuspendedStream(create: ReactableStreamMiddleware<Int> -> Promise<ReactiveStream<Int>>) {
            describe("state", {
                it("should pass", function (done) {
                    create(function (ctx) {
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    }).then(function (stream) {
                        stream.state.should.equal(Suspended);
                        done();
                    });
                });
            });

            testMiddleware(create);

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
            describe("no subscribing", {
                testInitStream(function () {
                    var stream = ReactiveStream.create(function (ctx) {
                        fail();
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    });
                    return SyncPromise.resolve(stream);
                });
            });

            describe("subscribe()", {
                describe("running", {
                    it("should call middleware", function (done) {
                        var called = false;
                        var stream = ReactiveStream.create(function (ctx) {
                            called = true;
                            return {
                                attach: function () {},
                                detach: function () {},
                                close: function () {}
                            }
                        });
                        stream.subscribe(function (_) fail());
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Running);
                            done();
                        });
                    });

                    testRunningStream(function (middleware) {
                        var stream = ReactiveStream.create(middleware);
                        stream.subscribe(function (_) {});
                        return Promise.resolve(stream);
                    });
                });

                describe("suspended", {
                    testSuspendedStream(function (middleware) {
                        return new Promise(function (f, _) {
                            var stream = ReactiveStream.create(middleware);
                            var unsubscribe = stream.subscribe(function (_) {});
                            unsubscribe();
                            wait(5, f.bind(stream));
                        });
                    });
                });

                testEndedStream(function () {
                    var stream = ReactiveStream.create(function (ctx) {
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    });
                    stream.subscribe(function (_) fail());
                    stream.close();
                    return SyncPromise.resolve(stream);
                });
            });

            describe("subscribeEnd()", {
                describe("running", {
                    it("should call middleware", function (done) {
                        var called = false;
                        var stream = ReactiveStream.create(function (ctx) {
                            called = true;
                            return {
                                attach: function () {},
                                detach: function () {},
                                close: function () {}
                            }
                        });
                        stream.subscribeEnd(function () fail());
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Running);
                            done();
                        });
                    });

                    testRunningStream(function (middleware) {
                        var stream = ReactiveStream.create(middleware);
                        stream.subscribeEnd(function () {});
                        return Promise.resolve(stream);
                    });
                });

                describe("suspended", {
                    testSuspendedStream(function (middleware) {
                        return new Promise(function (f, _) {
                            var stream = ReactiveStream.create(middleware);
                            var unsubscribe = stream.subscribeEnd(function () {});
                            unsubscribe();
                            wait(5, f.bind(stream));
                        });
                    });
                });

                testEndedStream(function () {
                    var stream = ReactiveStream.create(function (ctx) {
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    });
                    stream.subscribeEnd(function () {});
                    stream.close();
                    return SyncPromise.resolve(stream);
                });
            });

            describe("subscribeError()", {
                describe("running", {
                    it("should call middleware", function (done) {
                        var called = false;
                        var stream = ReactiveStream.create(function (ctx) {
                            called = true;
                            return {
                                attach: function () {},
                                detach: function () {},
                                close: function () {}
                            }
                        });
                        stream.subscribeError(function (_) fail());
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Running);
                            done();
                        });
                    });

                    testRunningStream(function (middleware) {
                        var stream = ReactiveStream.create(middleware);
                        stream.subscribeError(function (_) {});
                        return Promise.resolve(stream);
                    });
                });

                describe("suspended", {
                    testSuspendedStream(function (middleware) {
                        return new Promise(function (f, _) {
                            var stream = ReactiveStream.create(middleware);
                            var unsubscribe = stream.subscribeError(function (e) {});
                            unsubscribe();
                            wait(5, f.bind(stream));
                        });
                    });
                });

                testEndedStream(function () {
                    var stream = ReactiveStream.create(function (ctx) {
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    });
                    stream.subscribeError(function (_) fail());
                    stream.close();
                    return SyncPromise.resolve(stream);
                });
            });

            describe("catchError()", {
                // TODO

                testInitStream(function () {
                    var stream = ReactiveStream.create(function (ctx) {
                        fail();
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    });
                    stream.catchError(function (e) {
                        fail();
                        throw e;
                    });
                    return SyncPromise.resolve(stream);
                });
            });

            describe("finally()", {
                describe("running", {
                    it("should call middleware", function (done) {
                        var called = false;
                        var stream = ReactiveStream.create(function (ctx) {
                            called = true;
                            return {
                                attach: function () {},
                                detach: function () {},
                                close: function () {}
                            }
                        });
                        stream.finally(function () fail());
                        wait(10, function () {
                            called.should.be(true);
                            stream.state.should.equal(Running);
                            done();
                        });
                    });

                    testRunningStream(function (middleware) {
                        var stream = ReactiveStream.create(middleware);
                        stream.finally(function () {});
                        return Promise.resolve(stream);
                    });
                });

                describe("suspended", {
                    testSuspendedStream(function (middleware) {
                        return new Promise(function (f, _) {
                            var stream = ReactiveStream.create(middleware);
                            var unsubscribe = stream.finally(function () {});
                            unsubscribe();
                            wait(5, f.bind(stream));
                        });
                    });
                });

                testEndedStream(function () {
                    var stream = ReactiveStream.create(function (ctx) {
                        return {
                            attach: function () {},
                            detach: function () {},
                            close: function () {}
                        }
                    });
                    stream.finally(function () {});
                    stream.close();
                    return SyncPromise.resolve(stream);
                });
            });
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