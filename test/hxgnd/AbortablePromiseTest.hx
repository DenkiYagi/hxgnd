package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using hxgnd.LangTools;
using buddy.Should;

class AbortablePromiseTest extends BuddySuite {
    public function new() {
        describe("AbortablePromise.new()", {
            timeoutMs = 500;

            describe("executor", {
                it("should call", function (done) {
                    new AbortablePromise(function (_, _) {
                        done();
                        return function () {};
                    });
                });
            });

            describe("pending", {
                it("should be not completed", function (done) {
                    new AbortablePromise(function (_, _) {
                        return function () {};
                    }).then(
                        function (_) { fail(); done(); },
                        function (_) { fail(); done(); }
                    );
                    wait(5, done);
                });
            });

            describe("fulfilled", {
                describe("sync", {
                    it("should pass", function (done) {
                        new AbortablePromise(function (fulfill, _) {
                            fulfill();
                            return function () {};
                        });
                        wait(5, done);
                    });

                    it("should pass when it have no fulfilled", function (done) {
                        new AbortablePromise(function (fulfill, _) {
                            fulfill();
                            return function () {};
                        }).then(null, function (_) { fail(); done(); });
                        wait(5, done);
                    });

                    it("should call fulfilled(_)", function (done) {
                        new AbortablePromise(function (fulfill, _) {
                            fulfill();
                            return function () {};
                        }).then(
                            function (_) { done(); },
                            function (_) { fail(); done(); }
                        );
                    });

                    it("should call fulfilled(x)", function (done) {
                        new AbortablePromise(function (fulfill, _) {
                            fulfill(1);
                            return function () {};
                        }).then(
                            function (x) {
                                x.should.be(1);
                                done();
                            },
                            function (_) { fail(); done(); }
                        );
                    });
                });

                describe("async", {
                    it("should pass", function (done) {
                        new AbortablePromise(function (fulfill, _) {
                            wait(5, fulfill.bind());
                            return function () {};
                        });
                        wait(10, done);
                    });

                    it("should pass when it have no fulfilled", function (done) {
                        new AbortablePromise(function (fulfill, _) {
                            wait(5, fulfill.bind());
                            return function () {};
                        }).then(null, function (_) { fail(); done(); });
                        wait(10, done);
                    });

                    it("should call fulfilled(_)", function (done) {
                        new AbortablePromise(function (fulfill, _) {
                            wait(5, fulfill.bind());
                            return function () {};
                        }).then(
                            function (_) { done(); },
                            function (_) { fail(); done(); }
                        );
                    });

                    it("should call fulfilled(x)", function (done) {
                        new AbortablePromise(function (fulfill, _) {
                            wait(5, fulfill.bind(1));
                            return function () {};
                        }).then(
                            function (x) {
                                x.should.be(1);
                                done();
                            },
                            function (_) { fail(); done(); }
                        );
                    });
                });
            });

            describe("rejected", {
                describe("sync", {
                    it("should pass", function (done) {
                        new AbortablePromise(function (_, reject) {
                            reject();
                            return function () {};
                        });
                        wait(5, done);
                    });

                    it("should pass when it have no rejected", function (done) {
                        new AbortablePromise(function (_, reject) {
                            reject();
                            return function () {};
                        }).then(function (_) { fail(); done(); });
                        wait(5, done);
                    });

                    it("should call rejected(_)", function (done) {
                        new AbortablePromise(function (_, reject) {
                            reject();
                            return function () {};
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(_)", function (done) {
                        new AbortablePromise(function (_, reject) {
                            reject();
                            return function () {};
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(x)", function (done) {
                        new AbortablePromise(function (_, reject) {
                            reject("error");
                            return function () {};
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                (e: String).should.be("error");
                                done();
                            }
                        );
                    });

                    it("should call rejected when it is thrown error", function (done) {
                        new AbortablePromise(function (_, _) {
                            throw "error";
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                (e: String).should.be("error");
                                done();
                            }
                        );
                    });
                });

                describe("async", {
                    it("should pass", function (done) {
                        new AbortablePromise(function (_, reject) {
                            wait(5, reject.bind());
                            return function () {};
                        });
                        wait(10, done);
                    });

                    it("should pass when it have no rejected", function (done) {
                        new AbortablePromise(function (_, reject) {
                            wait(5, reject.bind());
                            return function () {};
                        }).then(function (_) { fail(); done(); });
                        wait(10, done);
                    });

                    it("should call rejected(_)", function (done) {
                        new AbortablePromise(function (_, reject) {
                            wait(5, reject.bind());
                            return function () {};
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(_)", function (done) {
                        new AbortablePromise(function (_, reject) {
                            wait(5, reject.bind());
                            return function () {};
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(x)", function (done) {
                        new AbortablePromise(function (_, reject) {
                            wait(5, reject.bind("error"));
                            return function () {};
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.same(e, "error").should.be(true);
                                done();
                            }
                        );
                    });
                });
            });

            #if js
            describe("JavaScript compatibility", {
                it("should be js.Promise", {
                    var AbortablePromise = new AbortablePromise(function (_, _) {
                        return function () {};
                    });
                    AbortablePromise.should.beType(js.Promise);
                });
            });
            #end
        });

        describe("AbortablePromise.resolve()", {
            timeoutMs = 500;

            it("should call resolved(_)", function (done) {
                AbortablePromise.resolve().then(
                    function (_) { done(); },
                    function (_) { fail(); done(); }
                );
            });

            it("should call resolved(x)", function (done) {
                AbortablePromise.resolve(1).then(
                    function (x) {
                        x.should.be(1);
                        done();
                    },
                    function (_) { fail(); done(); }
                );
            });

            it("should not abort", function (done) {
                var promise = AbortablePromise.resolve(1);
                promise.abort();
                promise.then(function (x) {
                    x.should.be(1);
                    done();
                }, function (e) {
                    fail();
                    done();
                });
            });
        });

        describe("AbortablePromise.reject()", {
            timeoutMs = 500;

           it("should call rejected(x)", function (done) {
                AbortablePromise.reject("error").then(
                    function (_) { fail(); done(); },
                    function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    }
                );
            });

            it("should call rejected(_)", function (done) {
                 AbortablePromise.reject("error").then(
                    function (_) { fail(); done(); },
                    function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    }
                );
            });

            it("should not abort", function (done) {
                var promise = AbortablePromise.reject("hello");
                promise.abort();
                promise.then(function (x) {
                    fail();
                    done();
                }, function (e) {
                    (e: String).should.be("hello");
                    done();
                });
            });
        });

        describe("AbortablePromise.then()", {
            timeoutMs = 500;

            describe("sync", {
                it("should call fulfilled", function (done) {
                    new AbortablePromise(function (fulfill, _) {
                        fulfill(100);
                        return function () {};
                    }).then(function (x) {
                        x.should.be(100);
                        done();
                    }, function (_) {
                        fail();
                        done();
                    });
                });

                it("should call rejected", function (done) {
                    new AbortablePromise(function (_, reject) {
                        reject("error");
                        return function () {};
                    }).then(function (_) {
                        fail();
                        done();
                    }, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("async", {
                it("should call fulfilled", function (done) {
                    new AbortablePromise(function (fulfill, _) {
                        wait(5, function () {
                            fulfill(100);
                        });
                        return function () {};
                    }).then(function (x) {
                        x.should.be(100);
                        done();
                    }, function (_) {
                        fail();
                        done();
                    });
                });

                it("should call rejected", function (done) {
                    new AbortablePromise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
                        return function () {};
                    }).then(function (_) {
                        fail();
                        done();
                    }, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain using value", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return x + 1;
                        }).then(function (x) {
                            return x + 100;
                        }).then(function (x) {
                            x.should.be(102);
                            done();
                        });
                    });

                    it("should not call 1st-then()", function (done) {
                        AbortablePromise.resolve(1)
                        .then(null, function (e) {
                            fail();
                            return -1;
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected Promise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return Promise.reject("error");
                        }).then(null, function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return SyncPromise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return SyncPromise.reject("error");
                        }).then(null, function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.Promise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.Promise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return js.Promise.reject("error");
                        }).then(null, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            throw "error";
                        }).then(null, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain using value", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (e) {
                            return 1;
                        }).then(function (x) {
                            return x + 100;
                        }).then(function (x) {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should not call 1st-then()", function (done) {
                        AbortablePromise.reject("error")
                        .then(function (x) {
                            fail();
                            return -1;
                        }).then(null, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved Promise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (x) {
                            return Promise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (x) {
                            return Promise.reject("error");
                        }).then(null, function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (x) {
                            return SyncPromise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (x) {
                            return SyncPromise.reject("rewrited error");
                        }).then(null, function (e) {
                            LangTools.same(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (x) {
                            return AbortablePromise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (x) {
                            return AbortablePromise.reject("rewrited error");
                        }).then(null, function (e) {
                            LangTools.same(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.Promise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (x) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.Promise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (x) {
                            return js.Promise.reject("rewrited error");
                        }).then(null, function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (x) {
                            throw "rewrited error";
                        }).then(null, function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("AbortablePromise.catchError()", {
            timeoutMs = 500;

            describe("sync", {
                it("should not call", function (done) {
                    new AbortablePromise(function (fulfill, _) {
                        fulfill(100);
                        return function () {};
                    }).catchError(function (_) {
                        fail();
                        done();
                    });
                    wait(5, done);
                });

                it("should call", function (done) {
                    new AbortablePromise(function (_, reject) {
                        reject("error");
                        return function () {};
                    }).catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("async", {
                it("should not call", function (done) {
                    new AbortablePromise(function (fulfill, _) {
                        wait(5, function () {
                            fulfill(100);
                        });
                        return function () {};
                    }).catchError(function (_) {
                        fail();
                        done();
                    });
                    wait(5, done);
                });

                it("should call", function (done) {
                    new AbortablePromise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
                        return function () {};
                    }).catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should not call catchError()", function (done) {
                        AbortablePromise.resolve(1)
                        .catchError(function (e) {
                            fail();
                            return -1;
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain using value", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return 1;
                        }).then(function (x) {
                            return x + 100;
                        }).then(function (x) {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return Promise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return Promise.reject("rewrited error");
                        }).catchError(function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return SyncPromise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return SyncPromise.reject("rewrited error");
                        }).then(null, function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return AbortablePromise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return AbortablePromise.reject("rewrited error");
                        }).then(null, function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.Promise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return js.Promise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected js.Promise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return js.Promise.reject("rewrited error");
                        }).then(null, function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            throw "rewrited error";
                        }).then(null, function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("AbortablePromise.finally()", {
            timeoutMs = 500;

            describe("sync", {
                it("should call when it is fulfilled", function (done) {
                    new AbortablePromise(function (fulfill, _) {
                        fulfill(100);
                        return function () {};
                    }).finally(function () {
                        done();
                    });
                });

                it("should call when it is rejected", function (done) {
                    new AbortablePromise(function (_, reject) {
                        reject("error");
                        return function () {};
                    }).finally(function () {
                        done();
                    });
                });
            });

            describe("async", {
                it("should call when it is fulfilled", function (done) {
                    new AbortablePromise(function (fulfill, _) {
                        wait(5, function () {
                            fulfill(100);
                        });
                        return function () {};
                    }).finally(function () {
                        done();
                    });
                });

                it("should call when it is rejected", function (done) {
                    new AbortablePromise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
                        return function () {};
                    }).finally(function () {
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain", function (done) {
                        AbortablePromise.resolve(1)
                        .finally(function () {})
                        .then(function (x) {
                            return x + 100;
                        })
                        .then(function (x) {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain using exception", function (done) {
                        AbortablePromise.resolve(1)
                        .finally(function () {
                            throw "error";
                        })
                        .catchError(function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });
                });

                describe("from rejected", {
                    it("should chain", function (done) {
                        AbortablePromise.reject("error")
                        .finally(function () {})
                        .catchError(function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using exception", function (done) {
                        AbortablePromise.reject("error")
                        .finally(function () {
                            throw "rewrited error";
                        })
                        .catchError(function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });
                });
            });
        });

        describe("AbortablePromise.abort()", {
            describe("before execution", {
                it("should not call the executor", function (done) {
                    var promise = new AbortablePromise(function (_, _) {
                        fail();
                        done();
                        return function () {}
                    });
                    promise.abort();
                    wait(10, done);
                });

                it("should not call the abort callback", function (done) {
                    var promise = new AbortablePromise(function (_, _) {
                        return function () {
                            fail();
                            done();
                        }
                    });
                    promise.abort();
                    wait(10, done);
                });

                it("should call rejected that is set before abort()", function (done) {
                    var promise = new AbortablePromise(function (_, _) {
                        return function () {};
                    });
                    promise.catchError(function (e) {
                        Std.is(e, AbortedError).should.be(true);
                        done();
                    });
                    promise.abort();
                });

                it("should call rejected that is set after abort()", function (done) {
                    var promise = new AbortablePromise(function (_, _) {
                        return function () {};
                    });
                    promise.abort();
                    promise.catchError(function (e) {
                        Std.is(e, AbortedError).should.be(true);
                        done();
                    });
                });

                it("should pass when it is called abort() 2-times", {
                    var promise = new AbortablePromise(function (_, _) {
                        return function () {};
                    });
                    promise.abort();
                    promise.abort();
                });

                it("should not apply fulfill() when it is aborted", function (done) {
                    var promise = new AbortablePromise(function (f, _) {
                        wait(5, f.bind(1));
                        return function () {};
                    });
                    promise.abort();
                    wait(10, function () {
                        promise.catchError(function (e) {
                            Std.is(e, AbortedError).should.be(true);
                            done();
                        });
                    });
                });

                it("should not apply reject() when it is aborted", function (done) {
                    var promise = new AbortablePromise(function (_, r) {
                        wait(5, r.bind("error"));
                        return function () {};
                    });
                    promise.abort();
                    wait(10, function () {
                        promise.catchError(function (e) {
                            Std.is(e, AbortedError).should.be(true);
                            done();
                        });
                    });
                });
            });

            describe("pending call the abort callback", {
                it("should call onAbort", function (done) {
                    var promise = new AbortablePromise(function (_, _) {
                        return function () {
                            done();
                        }
                    });
                    wait(5, function () {
                        promise.abort();
                    });
                });

                it("should call rejected that is set before abort()", function (done) {
                    var promise = new AbortablePromise(function (_, _) {
                        return function () {};
                    });
                    promise.catchError(function (e) {
                        Std.is(e, AbortedError).should.be(true);
                        done();
                    });
                    wait(5, function () {
                        promise.abort();
                    });
                });

                it("should call rejected that is set after abort()", function (done) {
                    var promise = new AbortablePromise(function (_, _) {
                        return function () {};
                    });
                    wait(5, function () {
                        promise.abort();
                        promise.catchError(function (e) {
                            Std.is(e, AbortedError).should.be(true);
                            done();
                        });
                    });
                });

                it("should pass when it is called abort() 2-times", function (done) {
                    var count = 0;
                    var promise = new AbortablePromise(function (_, _) {
                        return function () {
                            count++;
                        };
                    });
                    wait(5, function () {
                        promise.abort();
                        count.should.be(1);
                    });
                    wait(10, function () {
                        promise.abort();
                        count.should.be(1);
                        done();
                    });
                });
            });

            describe("fulfilled", {
                it("should not call the abort callback", function (done) {
                    var promise = new AbortablePromise(function (f, _) {
                        f(1);
                        return function () {
                            fail();
                            done();
                        }
                    });
                    wait(5, function () {
                        promise.abort();
                    });
                    wait(10, done);
                });

                it("should call resolved that is set before abort()", function (done) {
                    var promise = new AbortablePromise(function (f, _) {
                        f(1);
                        return function () {};
                    });
                    promise.then(function (x) {
                        (x: Int).should.be(1);
                        done();
                    });
                    wait(5, function () {
                        promise.abort();
                    });
                });

                it("should call resolved that is set after abort()", function (done) {
                    var promise = new AbortablePromise(function (f, _) {
                        f(1);
                        return function () {};
                    });
                    wait(5, function () {
                        promise.abort();
                        promise.then(function (x) {
                            (x: Int).should.be(1);
                            done();
                        });
                    });
                });

                it("should pass when it is called abort() 2-times", function (done) {
                    var promise = new AbortablePromise(function (f, _) {
                        f(1);
                        return function () {
                            fail();
                            done();
                        };
                    });
                    wait(5, function () {
                        promise.abort();
                    });
                    wait(10, function () {
                        promise.abort();
                        done();
                    });
                });
            });

            describe("rejected", {
                it("should not call the abort callback", function (done) {
                    var promise = new AbortablePromise(function (_, r) {
                        r("error");
                        return function () {
                            fail();
                            done();
                        }
                    });
                    wait(5, function () {
                        promise.abort();
                    });
                    wait(10, done);
                });

                it("should call rejected that is set before abort()", function (done) {
                    var promise = new AbortablePromise(function (_, r) {
                        r("error");
                        return function () {};
                    });
                    promise.catchError(function (e) {
                        Std.is(e, AbortedError).should.be(false);
                        (e: String).should.be("error");
                        done();
                    });
                    wait(5, function () {
                        promise.abort();
                    });
                });

                it("should call rejected that is set after abort()", function (done) {
                    var promise = new AbortablePromise(function (_, r) {
                        r("error");
                        return function () {};
                    });
                    wait(5, function () {
                        promise.abort();
                        promise.catchError(function (e) {
                            Std.is(e, AbortedError).should.be(false);
                            (e: String).should.be("error");
                            done();
                        });
                    });
                });

                it("should pass when it is called abort() 2-times", function (done) {
                    var promise = new AbortablePromise(function (_, r) {
                        r("error");
                        return function () {
                            fail();
                            done();
                        };
                    });
                    wait(5, function () {
                        promise.abort();
                    });
                    wait(10, function () {
                        promise.abort();
                        done();
                    });
                });
            });

            describe("chain", {
                it("should pass when it is using then()", function (done) {
                    var promise = new AbortablePromise(function (_, _) {
                        return done;
                    })
                    .then(function (_) {});

                    wait(5, promise.abort);
                });

                it("should pass when it is using catchError()", function (done) {
                    var promise = new AbortablePromise(function (_, _) {
                        return done;
                    })
                    .catchError(function (_) {});

                    wait(5, promise.abort);
                });

                it("should pass when it is using finally()", function (done) {
                    var promise = new AbortablePromise(function (_, _) {
                        return done;
                    })
                    .finally(function () {});

                    wait(5, promise.abort);
                });
            });
        });

        describe("Promise.compute()", {
            it("should use AbortablePromise", function (done) {
                Promise.compute({
                    var a = @await AbortablePromise.resolve(3);
                    var b = @await Promise.resolve(2);
                    a + b;
                }).then(function (x) {
                    x.should.be(5);
                    done();
                });
            });
        });
    }
}