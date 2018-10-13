package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using hxgnd.LangTools;
using buddy.Should;

class SyncPromiseTest extends BuddySuite {
    public function new() {
        describe("SyncPromise.new()", {
            timeoutMs = 500;

            describe("executor", {
                it("should call", function (done) {
                    new SyncPromise(function (_, _) {
                        done();
                    });
                });
            });

            describe("pending", {
                it("should be not completed", function (done) {
                    new SyncPromise(function (_, _) {}).then(
                        function (_) { fail(); },
                        function (_) { fail(); }
                    );
                    wait(5, done);
                });
            });

            describe("fulfilled", {
                describe("sync", {
                    it("should pass", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            fulfill();
                        });
                        wait(5, done);
                    });

                    it("should pass when it have no fulfilled", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            fulfill();
                        }).then(null, function (_) { fail(); });
                        wait(5, done);
                    });

                    it("should call fulfilled(_)", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            fulfill();
                        }).then(
                            function (_) { done(); },
                            function (_) { fail(); }
                        );
                    });

                    it("should call fulfilled(x)", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            fulfill(1);
                        }).then(
                            function (x) {
                                x.should.be(1);
                                done();
                            },
                            function (_) { fail(); }
                        );
                    });
                });

                describe("async", {
                    it("should pass", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            wait(5, fulfill.bind());
                        });
                        wait(10, done);
                    });

                    it("should pass when it have no fulfilled", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            wait(5, fulfill.bind());
                        }).then(null, function (_) { fail(); });
                        wait(10, done);
                    });

                    it("should call fulfilled(_)", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            wait(5, fulfill.bind());
                        }).then(
                            function (_) { done(); },
                            function (_) { fail(); }
                        );
                    });

                    it("should call fulfilled(x)", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            wait(5, fulfill.bind(1));
                        }).then(
                            function (x) {
                                x.should.be(1);
                                done();
                            },
                            function (_) { fail(); }
                        );
                    });
                });
            });

            describe("rejected", {
                describe("sync", {
                    it("should pass", function (done) {
                        new SyncPromise(function (_, reject) {
                            reject();
                        });
                        wait(5, done);
                    });

                    it("should pass when it have no rejected", function (done) {
                        new SyncPromise(function (_, reject) {
                            reject();
                        }).then(function (_) { fail(); });
                        wait(5, done);
                    });

                    it("should call rejected(_)", function (done) {
                        new SyncPromise(function (_, reject) {
                            reject();
                        }).then(
                            function (_) { fail(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(_)", function (done) {
                        new SyncPromise(function (_, reject) {
                            reject();
                        }).then(
                            function (_) { fail(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(x)", function (done) {
                        new SyncPromise(function (_, reject) {
                            reject("error");
                        }).then(
                            function (_) { fail(); },
                            function (e) {
                                (e: String).should.be("error");
                                done();
                            }
                        );
                    });

                    it("should call rejected when it is thrown error", function (done) {
                        new SyncPromise(function (_, _) {
                            throw "error";
                        }).then(
                            function (_) { fail(); },
                            function (e) {
                                (e: String).should.be("error");
                                done();
                            }
                        );
                    });
                });

                describe("async", {
                    it("should pass", function (done) {
                        new SyncPromise(function (_, reject) {
                            wait(5, reject.bind());
                        });
                        wait(10, done);
                    });

                    it("should pass when it have no rejected", function (done) {
                        new SyncPromise(function (_, reject) {
                            wait(5, reject.bind());
                        }).then(function (_) { fail(); });
                        wait(10, done);
                    });

                    it("should call rejected(_)", function (done) {
                        new SyncPromise(function (_, reject) {
                            wait(5, reject.bind());
                        }).then(
                            function (_) { fail(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(_)", function (done) {
                        new SyncPromise(function (_, reject) {
                            wait(5, reject.bind());
                        }).then(
                            function (_) { fail(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(x)", function (done) {
                        new SyncPromise(function (_, reject) {
                            wait(5, reject.bind("error"));
                        }).then(
                            function (_) { fail(); },
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
                    var promise = new SyncPromise(function (_, _) {});
                    promise.should.beType(js.Promise);
                });
            });
            #end
        });

        describe("SyncPromise.resolve()", {
            timeoutMs = 500;

            it("should call resolved(_)", function (done) {
                SyncPromise.resolve().then(
                    function (_) { done(); },
                    function (_) { fail(); }
                );
            });

            it("should call resolved(x)", function (done) {
                SyncPromise.resolve(1).then(
                    function (x) {
                        x.should.be(1);
                        done();
                    },
                    function (_) { fail(); }
                );
            });
        });

        describe("SyncPromise.reject()", {
            timeoutMs = 500;

           it("should call rejected(x)", function (done) {
                SyncPromise.reject("error").then(
                    function (_) { fail(); },
                    function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    }
                );
            });

            it("should call rejected(_)", function (done) {
                 SyncPromise.reject("error").then(
                    function (_) { fail(); },
                    function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    }
                );
            });
        });

        describe("SyncPromise.then()", {
            timeoutMs = 500;

            describe("sync", {
                it("should call fulfilled", function (done) {
                    new SyncPromise(function (fulfill, _) {
                        fulfill(100);
                    }).then(function (x) {
                        x.should.be(100);
                        done();
                    }, function (_) {
                        fail();
                    });
                });

                it("should call rejected", function (done) {
                    new SyncPromise(function (_, reject) {
                        reject("error");
                    }).then(function (_) {
                        fail();
                    }, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("async", {
                it("should call fulfilled", function (done) {
                    new SyncPromise(function (fulfill, _) {
                        wait(5, function () {
                            fulfill(100);
                        });
                    }).then(function (x) {
                        x.should.be(100);
                        done();
                    }, function (_) {
                        fail();
                    });
                });

                it("should call rejected", function (done) {
                    new SyncPromise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
                    }).then(function (_) {
                        fail();
                    }, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain using value", function (done) {
                        SyncPromise.resolve(1)
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
                        SyncPromise.resolve(1)
                        .then(null, function (e) {
                            fail();
                            return -1;
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using resolved Promise", function (done) {
                        SyncPromise.resolve(1)
                        .then(function (x) {
                            return Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected Promise", function (done) {
                        SyncPromise.resolve(1)
                        .then(function (x) {
                            return Promise.reject("error");
                        }).then(null, function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", function (done) {
                        SyncPromise.resolve(1)
                        .then(function (x) {
                            return SyncPromise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", function (done) {
                        SyncPromise.resolve(1)
                        .then(function (x) {
                            return SyncPromise.reject("error");
                        }).then(null, function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.Promise", function (done) {
                        SyncPromise.resolve(1)
                        .then(function (x) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.Promise", function (done) {
                        SyncPromise.resolve(1)
                        .then(function (x) {
                            return js.Promise.reject("error");
                        }).then(null, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", function (done) {
                        SyncPromise.resolve(1)
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
                        SyncPromise.reject("error")
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
                        SyncPromise.reject("error")
                        .then(function (x) {
                            fail();
                            return -1;
                        }).then(null, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using resolved Promise", function (done) {
                        SyncPromise.reject("error")
                        .then(null, function (x) {
                            return Promise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", function (done) {
                        SyncPromise.reject("error")
                        .then(null, function (x) {
                            return Promise.reject("error");
                        }).then(null, function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", function (done) {
                        SyncPromise.reject("error")
                        .then(null, function (x) {
                            return SyncPromise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", function (done) {
                        SyncPromise.reject("error")
                        .then(null, function (x) {
                            return SyncPromise.reject("rewrited error");
                        }).then(null, function (e) {
                            LangTools.same(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", function (done) {
                        SyncPromise.reject("error")
                        .then(null, function (x) {
                            return AbortablePromise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", function (done) {
                        SyncPromise.reject("error")
                        .then(null, function (x) {
                            return AbortablePromise.reject("rewrited error");
                        }).then(null, function (e) {
                            LangTools.same(e, "rewrited error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.Promise", function (done) {
                        SyncPromise.reject("error")
                        .then(null, function (x) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain using rejected js.Promise", function (done) {
                        SyncPromise.reject("error")
                        .then(null, function (x) {
                            return js.Promise.reject("rewrited error");
                        }).then(null, function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", function (done) {
                        SyncPromise.reject("error")
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

        describe("SyncPromise.catchError()", {
            timeoutMs = 500;

            describe("sync", {
                it("should not call", function (done) {
                    new SyncPromise(function (fulfill, _) {
                        fulfill(100);
                    }).catchError(function (_) {
                        fail();
                    });
                    wait(5, done);
                });

                it("should call", function (done) {
                    new SyncPromise(function (_, reject) {
                        reject("error");
                    }).catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("async", {
                it("should not call", function (done) {
                    new SyncPromise(function (fulfill, _) {
                        wait(5, function () {
                            fulfill(100);
                        });
                    }).catchError(function (_) {
                        fail();
                    });
                    wait(5, done);
                });

                it("should call", function (done) {
                    new SyncPromise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
                    }).catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should not call catchError()", function (done) {
                        SyncPromise.resolve(1)
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
                        SyncPromise.reject("error")
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
                        SyncPromise.reject("error")
                        .catchError(function (e) {
                            return Promise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected Promise", function (done) {
                        SyncPromise.reject("error")
                        .catchError(function (e) {
                            return Promise.reject("rewrited error");
                        }).catchError(function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved SyncPromise", function (done) {
                        SyncPromise.reject("error")
                        .catchError(function (e) {
                            return SyncPromise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected SyncPromise", function (done) {
                        SyncPromise.reject("error")
                        .catchError(function (e) {
                            return SyncPromise.reject("rewrited error");
                        }).then(null, function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });

                    it("should chain using resolved AbortablePromise", function (done) {
                        SyncPromise.reject("error")
                        .catchError(function (e) {
                            return AbortablePromise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected AbortablePromise", function (done) {
                        SyncPromise.reject("error")
                        .catchError(function (e) {
                            return AbortablePromise.reject("rewrited error");
                        }).then(null, function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });

                    #if js
                    it("should chain using resolved js.Promise", function (done) {
                        SyncPromise.reject("error")
                        .catchError(function (e) {
                            return js.Promise.resolve(1);
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should chain using rejected js.Promise", function (done) {
                        SyncPromise.reject("error")
                        .catchError(function (e) {
                            return js.Promise.reject("rewrited error");
                        }).then(null, function (e) {
                            (e: String).should.be("rewrited error");
                            done();
                        });
                    });
                    #end

                    it("should chain using exception", function (done) {
                        SyncPromise.reject("error")
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

        describe("SyncPromise.finally()", {
            timeoutMs = 500;

            describe("sync", {
                it("should call when it is fulfilled", function (done) {
                    new SyncPromise(function (fulfill, _) {
                        fulfill(100);
                    }).finally(function () {
                        done();
                    });
                });

                it("should call when it is rejected", function (done) {
                    new SyncPromise(function (_, reject) {
                        reject("error");
                    }).finally(function () {
                        done();
                    });
                });
            });

            describe("async", {
                it("should call when it is fulfilled", function (done) {
                    new SyncPromise(function (fulfill, _) {
                        wait(5, function () {
                            fulfill(100);
                        });
                    }).finally(function () {
                        done();
                    });
                });

                it("should call when it is rejected", function (done) {
                    new SyncPromise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
                    }).finally(function () {
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain", function (done) {
                        SyncPromise.resolve(1)
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
                        SyncPromise.resolve(1)
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
                        SyncPromise.reject("error")
                        .finally(function () {})
                        .catchError(function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should chain using exception", function (done) {
                        SyncPromise.reject("error")
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

        describe("Promise.compute()", {
            it("should use SyncPromise", function (done) {
                Promise.compute({
                    var a = @await SyncPromise.resolve(3);
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