package specs;

import haxe.Timer;
import hxgnd.Error;
import hxgnd.Promise;
import hxmocha.Mocha;

class PromiseSpec {
    @:describe
    public static function isPending(): Void {
        Mocha.it("pending", function () {
            var p = new Promise(function (_) {
            });
            Mocha.expect(p.isPending).to.equal(true);
        });
    }

    @:describe
    public static function resolve(): Void {
        Mocha.it("then() - before", function (done) {
            var p = new Promise(function (context) {
                Timer.delay(context.fulfill.bind("test"), 0);
                return function () { };
            });

            p.then(function (x) {
                Mocha.expect(x).to.equal("test");
                Mocha.expect(p.isPending).to.equal(false);
                done(null);
            }, function (e) {
                done(e);
            });

            Mocha.expect(p.isPending).to.equal(true);
        });

        Mocha.it("then() - after", function (done) {
            var p = new Promise(function (context) {
                context.fulfill("test");
            });

            // don't call again
            var isCalled = false;
            p.then(function (_) {
                Mocha.expect(isCalled).to.equal(false);
                isCalled = true;
            });

            Timer.delay(function () {
                Mocha.expect(isCalled).to.equal(true);
                Mocha.expect(p.isPending).to.equal(false);
                p.then(function (x) {
                    Mocha.expect(x).to.equal("test");
                    done(null);
                }, function (e) {
                    done(e);
                });
            }, 0);
        });

        Mocha.it("thenError() - before", function (done) {
            var p = new Promise(function (context) {
                Timer.delay(context.fulfill.bind("test"), 0);
            });

            var isCalled = false;
            p.thenError(function (e) {
                isCalled = true;
            });

            p.thenFinally(function () {
                done(isCalled ? new Error() : null);
            });

            Mocha.expect(p.isPending).to.equal(true);
        });

        Mocha.it("thenError() - after", function (done) {
            var p = new Promise(function (context) {
                context.fulfill("test");
            });

            Timer.delay(function () {
                Mocha.expect(p.isPending).to.equal(false);
                var isCalled = false;
                p.thenError(function (e) {
                    isCalled = true;
                });

                p.thenFinally(function () {
                    done(isCalled ? new Error() : null);
                });
            }, 0);
        });

        Mocha.it("finally", function (done) {
            var p = new Promise(function (context) {
                context.fulfill("test");
            });

            // don't call again
            var isCalled = false;
            p.then(null, null, function () {
                Mocha.expect(isCalled).to.equal(false);
                isCalled = true;
            });

            Timer.delay(function () {
                Mocha.expect(isCalled).to.equal(true);
                Mocha.expect(p.isPending).to.equal(false);
                p.then(null, null, function () {
                    done();
                });
            }, 0);
        });

        Mocha.it("thenFinally()", function (done) {
            var p = new Promise(function (context) {
                context.fulfill("test");
            });

            // don't call again
            var isCalled = false;
            p.thenFinally(function () {
                Mocha.expect(isCalled).to.equal(false);
                isCalled = true;
            });

            Timer.delay(function () {
                Mocha.expect(isCalled).to.equal(true);
                Mocha.expect(p.isPending).to.equal(false);
                p.thenFinally(function () {
                    done();
                });
            }, 0);
        });
    }

    @:describe
    public static function reject(): Void {
        Mocha.it("then() - before", function (done) {
            var p = new Promise(function (context) {
                Timer.delay(context.reject.bind(new Error("my error")), 0);
            });

            p.then(function (x) {
                done(new Error());
            }, function (e) {
                Mocha.expect(e.message).to.equal("my error");
                Mocha.expect(p.isPending).to.equal(false);
                done(null);
            });

            Mocha.expect(p.isPending).to.equal(true);
        });

        Mocha.it("then() - after", function (done) {
            var p = new Promise(function (context) {
                context.reject(new Error("my error"));
            });

            // don't call again
            var isCalled = false;
            p.then(null, function (_) {
                Mocha.expect(isCalled).to.equal(false);
                isCalled = true;
            });

            Timer.delay(function () {
                Mocha.expect(isCalled).to.equal(true);
                Mocha.expect(p.isPending).to.equal(false);
                p.then(function (x) {
                    done(new Error());
                }, function (e) {
                    Mocha.expect(e.message).to.equal("my error");
                    Mocha.expect(p.isPending).to.equal(false);
                    done(null);
                });
            }, 0);
        });

        Mocha.it("thenError() - before", function (done) {
            var p = new Promise(function (context) {
                Timer.delay(context.reject.bind(new Error("my error")), 0);
            });

            p.thenError(function (e) {
                Mocha.expect(e.message).to.equal("my error");
                Mocha.expect(p.isPending).to.equal(false);
                done(null);
            });

            Mocha.expect(p.isPending).to.equal(true);
        });

        Mocha.it("thenError() - after", function (done) {
            var p = new Promise(function (context) {
                context.reject(new Error("my error"));
            });

            // don't call again
            var isCalled = false;
            p.thenError(function (_) {
                Mocha.expect(isCalled).to.equal(false);
                isCalled = true;
            });

            Timer.delay(function () {
                Mocha.expect(isCalled).to.equal(true);
                Mocha.expect(p.isPending).to.equal(false);
                p.thenError(function (e) {
                    Mocha.expect(e.message).to.equal("my error");
                    Mocha.expect(p.isPending).to.equal(false);
                    done(null);
                });
            }, 0);
        });

        Mocha.it("finally", function (done) {
            var p = new Promise(function (context) {
                context.reject(new Error("my error"));
            });

            // don't call again
            var isCalled = false;
            p.then(null, null, function () {
                Mocha.expect(isCalled).to.equal(false);
                isCalled = true;
            });

            Timer.delay(function () {
                Mocha.expect(isCalled).to.equal(true);
                Mocha.expect(p.isPending).to.equal(false);
                p.then(null, null, function () {
                    done();
                });
            }, 0);
        });

        Mocha.it("thenFinally()", function (done) {
            var p = new Promise(function (context) {
                context.reject(new Error("my error"));
            });

            // don't call again
            var isCalled = false;
            p.thenFinally(function () {
                Mocha.expect(isCalled).to.equal(false);
                isCalled = true;
            });

            Timer.delay(function () {
                Mocha.expect(isCalled).to.equal(true);
                Mocha.expect(p.isPending).to.equal(false);
                p.thenFinally(function () {
                    done();
                });
            }, 0);
        });
    }

    @:describe
    public static function cancel() {
        Mocha.it("cancel - before", function (done) {
            var p = new Promise(function (_) {});

            Mocha.expect(p.isPending).to.equal(true);
            Mocha.expect(p.isCanceled).to.equal(false);
            p.then(function (_) {
                done(new Error());
            }, function (e) {
                Mocha.expect(p.isPending).to.equal(false);
                Mocha.expect(p.isCanceled).to.equal(true);
                Mocha.expect(e.message).to.equal("Canceled");
                done(null);
            });

            p.cancel();
        });

        Mocha.it("cancel - after", function (done) {
            var p = new Promise(function (_) {});

            p.cancel();

            Mocha.expect(p.isPending).to.equal(false);
            Mocha.expect(p.isCanceled).to.equal(true);
            p.then(function (_) {
                done(new Error());
            }, function (e) {
                Mocha.expect(p.isPending).to.equal(false);
                Mocha.expect(p.isCanceled).to.equal(true);
                Mocha.expect(e.message).to.equal("Canceled");
                done(null);
            });
        });

        Mocha.it("onCancel", function () {
            var called = false;

            var p = new Promise(function (ctx) {
                ctx.onCancel = function () {
                    called = true;
                };
            });

            Mocha.expect(called).to.equal(false);
            p.cancel();
            Mocha.expect(called).to.equal(true);
        });

        Mocha.it("onCancel fulfill", function (done) {
            var p = new Promise(function (ctx) {
                ctx.onCancel = function () {
                    ctx.fulfill("override");
                };
            });

            p.then(function (x) {
                Mocha.expect(x).to.equal("override");
                Mocha.expect(p.isCanceled).to.equal(true);
                done();
            });

            p.cancel();
        });

        Mocha.it("onCancel reject", function (done) {
            var p = new Promise(function (ctx) {
                ctx.onCancel = function () {
                    ctx.reject(new Error("override"));
                };
            });

            p.thenError(function (e) {
                Mocha.expect(e.message).to.equal("override");
                Mocha.expect(p.isCanceled).to.equal(true);
                done();
            });

            p.cancel();
        });

        Mocha.it("onCancel cancel", function (done) {
            var p = new Promise(function (ctx) {
                // 無限ループにならないこと
                ctx.onCancel = function () {
                    ctx.cancel();
                };
            });

            p.thenError(function (e) {
                Mocha.expect(p.isCanceled).to.equal(true);
                done();
            });

            p.cancel();
        });
    }

    @:describe("#fulfilled")
    public static function fulfilled() {
        Mocha.it("fulfilled", function (done) {
            Promise.fulfilled({hoge: 1}).then(function (x) {
                Mocha.expect(x).to.eql({hoge: 1});
                done(null);
            }, function (err) {
                done(err);
            });
        });
    }

    @:describe("#rejected")
    public static function rejected() {
        Mocha.it("default error", function (done) {
            Promise.rejected().thenError(function (e) {
                Mocha.expect(e).to.a(Error);
                Mocha.expect(e.message).to.equal("Rejected");
                done();
            });
        });
        Mocha.it("user error", function (done) {
            Promise.rejected(new Error("my error")).thenError(function (e) {
                Mocha.expect(e).to.a(Error);
                Mocha.expect(e.message).to.equal("my error");
                done();
            });
        });
    }

    @:describe
    public static function map() {
        Mocha.it("resolved", function (done) {
            Promise.fulfilled("hello").map(function (x) return '$x world').then(function (x) {
                Mocha.expect(x).to.equal("hello world");
                done();
            });
        });

        Mocha.it("rejected", function (done) {
            var isCalled = false;
            Promise.rejected(new Error("1st error"))
                .map(function (x) {
                    isCalled = true;
                    return '$x world';
                })
                .thenError(function (e) {
                    Mocha.expect(isCalled).to.equal(false);
                    Mocha.expect(e.message).to.equal("1st error");
                    done();
                });
        });
    }

    @:describe
    public static function flatMap() {
        Mocha.it("resolved -> resolved", function (done) {
            Promise.fulfilled("hello")
                .flatMap(function (x) {
                    return new Promise(function (context) {
                        context.fulfill('$x world');
                        return function () { };
                    });
                })
                .then(function (x) {
                    Mocha.expect(x).to.equal("hello world");
                    done();
                });
        });

        Mocha.it("resolved -> rejected", function (done) {
            Promise.fulfilled("hello")
                .flatMap(function (x) {
                    return Promise.rejected(new Error("inner error"));
                })
                .then(function (x) {
                    Mocha.expectFail();
                    done();
                }, function (e) {
                    Mocha.expect(e.message).to.equal("inner error");
                    done();
                });
        });

        Mocha.it("rejected", function (done) {
            Promise.rejected(new Error("my error"))
                .flatMap(function (x) {
                    return new Promise(function (context) {
                        context.fulfill('$x world');
                    });
                })
                .then(function (x) {
                    Mocha.expectFail();
                    done();
                }, function (err) {
                    Mocha.expect(err.message).to.equal("my error");
                    done();
                });
        });
    }

    @:describe("#all")
    public static function all() {
        Mocha.it("empty", function (done) {
            Promise.all([]).then(function (x) {
                Mocha.expect(x).to.empty();
                done();
            });
        });

        Mocha.it("single", function (done) {
            Promise.all([
                new Promise(function (context) {
                    Timer.delay(context.fulfill.bind("task1"), 0);
                })
            ]).then(function (x) {
                Mocha.expect(x).to.eql(["task1"]);
                done();
            });
        });

        Mocha.it("many", function (done) {
            Promise.all([
                new Promise(function (context) {
                    Timer.delay(context.fulfill.bind("task1"), 0);
                }),
                new Promise(function (context) {
                    Timer.delay(context.fulfill.bind("task2"), 0);
                }),
                new Promise(function (context) {
                    Timer.delay(context.fulfill.bind("task3"), 0);
                })
            ]).then(function (x) {
                Mocha.expect(x).to.eql(["task1", "task2", "task3"]);
                done();
            });
        });

        Mocha.it("many order", function (done) {
            Promise.all([
                new Promise(function (context) {
                    Timer.delay(context.fulfill.bind("task1"), 30);
                }),
                new Promise(function (context) {
                    Timer.delay(context.fulfill.bind("task2"), 10);
                }),
                new Promise(function (context) {
                    Timer.delay(context.fulfill.bind("task3"), 0);
                })
            ]).then(function (x) {
                Mocha.expect(x).to.eql(["task1", "task2", "task3"]);
                done();
            });
        });

        Mocha.it("rejected", function (done) {
            Promise.all([
                new Promise(function (context) {
                    Timer.delay(context.fulfill.bind("task1"), 0);
                }),
                new Promise(function (context) {
                    Timer.delay(context.fulfill.bind("task2"), 0);
                }),
                new Promise(function (context) {
                    Timer.delay(context.reject.bind(new Error("task3 error")), 0);
                })
            ]).then(function (x) {
                Mocha.expectFail();
                done();
            }, function (e) {
                Mocha.expect(e.message).to.equal("task3 error");
                done();
            });
        });
    }
}