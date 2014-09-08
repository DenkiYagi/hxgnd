package specs;

import haxe.Timer;
import hxgnd.Error;
import hxgnd.Promise;
import hxgnd.Stream;
import hxmocha.Mocha;

class StreamSpec {
    @:describe
    public static function beforeState() {
        Mocha.it("pending", function () {
            var s = new Stream(function (_) {
            });
            Mocha.expect(s.isPending).to.equal(true);
        });

        Mocha.it("isClosed", function () {
            var s = new Stream(function (_) {
            });
            Mocha.expect(s.isClosed).to.equal(false);
        });
    }

    @:descripbe
    public static function update() {
        Mocha.it("then() - before update", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.update.bind("updated"), 0);
            });

            s.then(function (x) {
                Mocha.expect(x).to.equal("updated");
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(false);
                done();
            }, function () {
                Mocha.expectFail();
                done();
            }, function (e) {
                Mocha.expectFail();
                done();
            }, function () {
                Mocha.expectFail();
                done();
            });

            Mocha.expect(s.isPending).to.equal(true);
            Mocha.expect(s.isClosed).to.equal(false);
        });

        Mocha.it("then() - after update", function (done) {
            var s = new Stream(function (context) {
                context.update("updated");
            });

            // does not call callback
            Timer.delay(function () {
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(false);
                s.then(function (x) {
                    Mocha.expectFail();
                    done();
                }, function () {
                    Mocha.expectFail();
                    done();
                }, function (e) {
                    Mocha.expectFail();
                    done();
                }, function () {
                    Mocha.expectFail();
                    done();
                });
                Timer.delay(function () done(), 0);
            }, 0);
        });
    }

    @:descripbe
    public static function close() {
        Mocha.it("then(_, closed) - before closed", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.close, 0);
            });

            var closed = false;
            s.then(function (x) {
                Mocha.expectFail();
                done();
            }, function () {
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(true);
                closed = true;
                done();
            }, function (e) {
                Mocha.expectFail();
                done();
            }, function () {
                if (!closed) {
                    Mocha.expectFail();
                    done();
                }
            });

            Mocha.expect(s.isPending).to.equal(true);
            Mocha.expect(s.isClosed).to.equal(false);
        });

        Mocha.it("thenClosed() - before closed", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.close, 0);
            });

            var closed = false;
            s.thenClosed(function () {
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(true);
                closed = true;
                done();
            });

            s.then(function (x) {
                Mocha.expectFail();
                done();
            }, null, function (e) {
                Mocha.expectFail();
                done();
            }, function () {
                if (!closed) {
                    Mocha.expectFail();
                    done();
                }
            });

            Mocha.expect(s.isPending).to.equal(true);
            Mocha.expect(s.isClosed).to.equal(false);
        });

        Mocha.it("then(_, closed) - after closed", function (done) {
            var s = new Stream(function (context) {
                context.close();
            });

            var closed = false;
            Timer.delay(function () {
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(true);
                s.then(function (x) {
                    Mocha.expectFail();
                    done();
                }, function () {
                    Mocha.expect(s.isPending).to.equal(false);
                    Mocha.expect(s.isClosed).to.equal(true);
                    closed = true;
                    done();
                }, function (e) {
                    Mocha.expectFail();
                    done();
                }, function () {
                    if (!closed) {
                        Mocha.expectFail();
                        done();
                    }
                });
            }, 0);
        });

        Mocha.it("thenClosed() - after closed", function (done) {
            var s = new Stream(function (context) {
                context.close();
            });

            var closed = false;
            Timer.delay(function () {
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(true);
                s.thenClosed(function () {
                    Mocha.expect(s.isPending).to.equal(false);
                    Mocha.expect(s.isClosed).to.equal(true);
                    closed = true;
                    done();
                });
                s.then(function (x) {
                    Mocha.expectFail();
                    done();
                }, null, function (e) {
                    Mocha.expectFail();
                    done();
                }, function () {
                    if (!closed) {
                        Mocha.expectFail();
                        done();
                    }
                });
            }, 0);
        });
    }

    @:descripbe
    public static function fail() {
        Mocha.it("then(_, _, error) - before failed", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(function () context.fail(new Error("my error")), 0);
            });

            var hasError = false;
            s.then(function (x) {
                Mocha.expectFail();
                done();
            }, function () {
                Mocha.expectFail();
                done();
            }, function (e) {
                hasError = true;
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(true);
                Mocha.expect(e.message).to.equal("my error");
                done();
            }, function () {
                if (!hasError) {
                    Mocha.expectFail();
                    done();
                }
            });
        });

        Mocha.it("thenError() - before failed", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(function () context.fail(new Error("my error")), 0);
            });

            var hasError = false;
            s.thenError(function (e) {
                hasError = true;
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(true);
                Mocha.expect(e.message).to.equal("my error");
                done();
            });

            s.then(function (x) {
                Mocha.expectFail();
                done();
            }, function () {
                Mocha.expectFail();
                done();
            }, null, function () {
                if (!hasError) {
                    Mocha.expectFail();
                    done();
                }
            });
        });

        Mocha.it("then(_, _, error) - after failed", function (done) {
            var s = new Stream(function (context) {
                context.fail(new Error("my error"));
            });
            Timer.delay(function () {
                var hasError = false;
                s.then(function (x) {
                    Mocha.expectFail();
                    done();
                }, function () {
                    Mocha.expectFail();
                    done();
                }, function (e) {
                    Mocha.expect(s.isPending).to.equal(false);
                    Mocha.expect(s.isClosed).to.equal(true);
                    Mocha.expect(e.message).to.equal("my error");
                    hasError = true;
                    done();
                }, function () {
                    if (!hasError) {
                        Mocha.expectFail();
                        done();
                    }
                });
            }, 0);
        });

        Mocha.it("thenError() - after failed", function (done) {
            var s = new Stream(function (context) {
                context.fail(new Error("my error"));
            });
            Timer.delay(function () {
                var hasError = false;
                s.thenError(function (e) {
                    Mocha.expect(s.isPending).to.equal(false);
                    Mocha.expect(s.isClosed).to.equal(true);
                    Mocha.expect(e.message).to.equal("my error");
                    hasError = true;
                    done();
                });
                s.then(function (x) {
                    Mocha.expectFail();
                    done();
                }, function () {
                    Mocha.expectFail();
                    done();
                }, null, function () {
                    if (!hasError) {
                        Mocha.expectFail();
                        done();
                    }
                });
            }, 0);
        });
    }

    @:descripbe
    public static function finally() {
        Mocha.it("then(_, _, _, finally) - before", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.close, 0);
            });
            s.then(null, null, null, function () {
                done();
            });
        });

        Mocha.it("thenFinally() - before", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.close, 0);
            });
            s.thenFinally(function () {
                done();
            });
        });

        Mocha.it("then(_, _, _, finally) - after", function (done) {
            var s = new Stream(function (context) {
                context.close();
            });
            Timer.delay(function () {
                s.then(null, null, null, function () {
                    done();
                });
            }, 0);
        });

        Mocha.it("thenFinally - after", function (done) {
            var s = new Stream(function (context) {
                context.close();
            });
            Timer.delay(function () {
                s.thenFinally(function () {
                    done();
                });
            }, 0);
        });
    }

    @:descripbe
    public static function updateAndClose() {
        Mocha.it("then() - before", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(function () {
                    context.update("update");
                    Timer.delay(context.close, 0);
                }, 0);
            });

            s.then(function (x) {
                Mocha.expect(x).to.equal("update");
            }, function () {
                done();
            }, function (e) {
                Mocha.expectFail();
                done();
            });
        });

        Mocha.it("then() - after", function (done) {
            var s = new Stream(function (context) {
                context.update("update");
                context.close();
            });

            Timer.delay(function () {
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(true);
                s.then(function (x) {
                    Mocha.expectFail();
                }, function () {
                    done();
                }, function (e) {
                    Mocha.expectFail();
                    done();
                });
            }, 0);
        });
    }

    @:descripbe
    public static function updateAndFail() {
        Mocha.it("then() - before", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(function () {
                    context.update("update");
                    Timer.delay(context.fail.bind(new Error("my error")), 0);
                }, 0);
            });

            var isUpdated = false;
            s.then(function (x) {
                isUpdated = true;
                Mocha.expect(x).to.equal("update");
            }, function () {
                Mocha.expectFail();
                done();
            }, function (e) {
                Mocha.expect(isUpdated).to.equal(true);
                Mocha.expect(e.message).to.equal("my error");
                done();
            });
        });

        Mocha.it("then() - after", function (done) {
            var s = new Stream(function (context) {
                context.update("update");
                context.fail(new Error("my error"));
            });

            Timer.delay(function () {
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(true);
                s.then(function (x) {
                    Mocha.expectFail();
                }, function () {
                    Mocha.expectFail();
                    done();
                }, function (e) {
                    Mocha.expect(e.message).to.equal("my error");
                    done();
                });
            }, 0);
        });
    }

    @:descripbe
    public static function cancel() {
        Mocha.it("cancel - before", function (done) {
            var s = new Stream(function (_) {});

            Mocha.expect(s.isPending).to.equal(true);
            Mocha.expect(s.isCanceled).to.equal(false);
            Mocha.expect(s.isClosed).to.equal(false);
            s.then(function (_) {
                done(new Error());
            }, function (e) {
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isCanceled).to.equal(true);
                Mocha.expect(s.isClosed).to.equal(true);
                Mocha.expect(e.message).to.equal("Canceled");
                done(null);
            });
            s.cancel();
        });

        Mocha.it("cancel - after", function (done) {
            var s = new Stream(function (_) {});

            s.cancel();

            Mocha.expect(s.isPending).to.equal(false);
            Mocha.expect(s.isCanceled).to.equal(true);
            Mocha.expect(s.isClosed).to.equal(false);
            s.then(function (_) {
                done(new Error());
            }, function (e) {
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isCanceled).to.equal(true);
                Mocha.expect(s.isClosed).to.equal(true);
                Mocha.expect(e.message).to.equal("Canceled");
                done(null);
            });
        });


        Mocha.it("onCancel update", function (done) {
            var s = new Stream(function (ctx) {
                ctx.onCancel = function () {
                    ctx.update("update");
                };
            });

            var called = false;
            s.then(function (x) {
                Mocha.expect(x).to.equal("update");
                Mocha.expect(s.isCanceled).to.equal(true);
                called = true;
            });
            s.thenError(function (e) {
                Mocha.expect(called).to.ok();
                done();
            });

            s.cancel();
        });

        Mocha.it("onCancel close", function (done) {
            var s = new Stream(function (ctx) {
                ctx.onCancel = function () {
                    ctx.close();
                };
            });

            s.thenClosed(function () {
                Mocha.expect(s.isCanceled).to.equal(true);
                done();
            });

            s.cancel();
        });

        Mocha.it("onCancel reject", function (done) {
            var s = new Stream(function (ctx) {
                ctx.onCancel = function () {
                    ctx.fail(new Error("override"));
                };
            });

            s.thenError(function (e) {
                Mocha.expect(e.message).to.equal("override");
                Mocha.expect(s.isCanceled).to.equal(true);
                done();
            });

            s.cancel();
        });

        Mocha.it("onCancel cancel", function (done) {
            var s = new Stream(function (ctx) {
                // 無限ループにならないこと
                ctx.onCancel = function () {
                    ctx.cancel();
                };
            });

            s.thenError(function (e) {
                Mocha.expect(s.isCanceled).to.equal(true);
                done();
            });

            s.cancel();
        });
    }

    @:descripbe
    public static function next() {
        Mocha.it("next() - update", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(function () context.update("update"), 0);
            });

            s.next().then(function (x) {
                Mocha.expect(x).to.equal("update");
                done();
            }, function (e) {
                Mocha.expectFail();
                done();
            });
        });

        Mocha.it("next() - close", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.close, 0);
            });

            s.next().then(function (x) {
                Mocha.expectFail();
                done();
            }, function (e) {
                Mocha.expect(e.message).to.equal("Closed");
                done();
            });
        });

        Mocha.it("next() - fail", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(function () context.fail(new Error("my error")), 0);
            });

            s.next().then(function (x) {
                Mocha.expectFail();
                done();
            }, function (e) {
                Mocha.expect(e.message).to.equal("my error");
                done();
            });
        });

        Mocha.it("next() - cancel", function (done) {
            var s = new Stream(function (context) {
            });
            s.cancel();

            s.next().then(function (x) {
                Mocha.expectFail();
                done();
            }, function (e) {
                Mocha.expect(e.message).to.equal("Canceled");
                done();
            });
        });
    }

    @:descripbe
    public static function tail() {
        Mocha.it("tail() - close", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.close, 0);
            });

            s.tail().then(function (_) {
                done();
            }, function (e) {
                Mocha.expectFail();
                done();
            });
        });

        Mocha.it("tail() - fail", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.fail.bind(new Error("my error")), 0);
            });

            s.tail().then(function (_) {
                Mocha.expectFail();
            }, function (e) {
                Mocha.expect(e.message).to.equal("my error");
                done();
            });
        });

        Mocha.it("tail() - cancel", function (done) {
            var s = new Stream(function (_) {
            });
            s.cancel();

            s.tail().then(function (x) {
                Mocha.expectFail();
                done();
            }, function (e) {
                Mocha.expect(e.message).to.equal("Canceled");
                done();
            });
        });
    }

    @:descripbe
    public static function map() {
        Mocha.it("map() - close", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.update.bind("1"), 0);
                Timer.delay(context.update.bind("2"), 0);
                Timer.delay(context.close, 0);
            });

            var s2 = s.map(function (x) {
                return x + "_conv";
            });

            var count = 0;
            s2.then(function (x) {
                Mocha.expect(x).to.equal('${++count}_conv');
            }, function () {
                Mocha.expect(count).to.equal(2);
                done();
            });
        });

        Mocha.it("map() - fail", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.update.bind("1"), 0);
                Timer.delay(context.update.bind("2"), 0);
                Timer.delay(context.fail.bind(new Error()), 0);
            });

            var s2 = s.map(function (x) {
                return x + "_conv";
            });

            var count = 0;
            s2.then(function (x) {
                Mocha.expect(x).to.equal('${++count}_conv');
            }, null, function (e) {
                Mocha.expect(count).to.equal(2);
                done();
            });
        });
    }

    @:descripbe
    public static function chain() {
        Mocha.it("chain() - close", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.update.bind("1"), 0);
                Timer.delay(context.update.bind("2"), 0);
                Timer.delay(context.close, 0);
            });

            var s2 = s.chain(function (x) {
                return Promise.fulfilled(x + "_conv");
            });

            var count = 0;
            s2.then(function (x) {
                Mocha.expect(x).to.equal('${++count}_conv');
            }, function () {
                Mocha.expect(count).to.equal(2);
                done();
            });
        });

        Mocha.it("chain() - fail", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.update.bind("1"), 0);
                Timer.delay(context.update.bind("2"), 0);
                Timer.delay(context.fail.bind(new Error()), 0);
            });

            var s2 = s.chain(function (x) {
                return Promise.fulfilled(x + "_conv");
            });

            var count = 0;
            s2.then(function (x) {
                Mocha.expect(x).to.equal('${++count}_conv');
            }, null, function (e) {
                Mocha.expect(count).to.equal(2);
                done();
            });
        });

        Mocha.it("chain() - cancel", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.update.bind("1"), 0);
                Timer.delay(context.update.bind("2"), 0);
            });
            Timer.delay(s.cancel, 50);

            var s2 = s.chain(function (x) {
                return Promise.fulfilled(x + "_conv");
            });

            var count = 0;
            s2.then(function (x) {
                Mocha.expect(x).to.equal('${++count}_conv');
            }, null, function (e) {
                Mocha.expect(count).to.equal(2);
                done();
            });
        });

        Mocha.it("chain() - delay", function (done) {
            var s = new Stream(function (context) {
                Timer.delay(context.update.bind("1"), 0);
                Timer.delay(context.update.bind("2"), 0);
                Timer.delay(context.update.bind("3"), 0);
                Timer.delay(context.update.bind("4"), 0);
                Timer.delay(context.update.bind("5"), 0);
                Timer.delay(context.close, 0);
            });

            var s2 = s.chain(function (x) {
                return if (x == "1") {
                    new Promise(function (context) {
                        Timer.delay(context.fulfill.bind(x + "_conv"), 50);
                    });
                } else if (x == "2") {
                    new Promise(function (context) {
                        Timer.delay(context.fulfill.bind(x + "_conv"), 10);
                    });
                } else {
                    Promise.fulfilled(x + "_conv");
                }
            });

            var count = 0;
            s2.then(function (x) {
                Mocha.expect(x).to.equal('${++count}_conv');
            }, function () {
                Mocha.expect(count).to.equal(5);
                done();
            });
        });
    }
}