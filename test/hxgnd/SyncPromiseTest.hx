package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using hxgnd.LangTools;
using buddy.Should;

class SyncPromiseTest extends BuddySuite {
    public function new() {
        describe("SyncPromise.new()", {
            timeoutMs = 1000;

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
                        function (_) { fail(); done(); },
                        function (_) { fail(); done(); }
                    );
                    wait(5, done);
                });
            });

            describe("fulfilling", {
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
                        }).then(null, function (_) { fail(); done(); });
                        wait(5, done);
                    });

                    it("should call fulfilled(_)", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            fulfill();
                        }).then(
                            function (_) {
                                done();
                            },
                            function (_) { fail(); done(); }
                        );
                        wait(5, done);
                    });

                    it("should call fulfilled(x)", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            fulfill(1);
                        }).then(
                            function (x) {
                                x.should.be(1);
                                done();
                            },
                            function (_) { fail(); done(); }
                        );
                        wait(5, done);
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
                        }).then(null, function (_) { fail(); done(); });
                        wait(10, done);
                    });

                    it("should call fulfilled(_)", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            wait(5, fulfill.bind());
                        }).then(
                            function (_) {
                                done();
                            },
                            function (_) { fail(); done(); }
                        );
                        wait(10, done);
                    });

                    it("should call fulfilled(x)", function (done) {
                        new SyncPromise(function (fulfill, _) {
                            wait(5, fulfill.bind(1));
                        }).then(
                            function (x) {
                                x.should.be(1);
                                done();
                            },
                            function (_) { fail(); done(); }
                        );
                        wait(10, done);
                    });
                });
            });

            describe("rejecting", {
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
                        }).then(function (_) { fail(); done(); });
                        wait(5, done);
                    });

                    it("should call rejected(_)", function (done) {
                        new SyncPromise(function (_, reject) {
                            reject();
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                        wait(5, done);
                    });

                    it("should call rejected(_)", function (done) {
                        new SyncPromise(function (_, reject) {
                            reject();
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                        wait(5, done);
                    });

                    it("should call rejected(x)", function (done) {
                        new SyncPromise(function (_, reject) {
                            reject("error");
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.same(e, "error").should.be(true);
                                done();
                            }
                        );
                        wait(5, done);
                    });

                    it("should call rejected when it is thrown error", function (done) {
                        new SyncPromise(function (_, _) {
                            throw "error";
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                Std.is(e, Error).should.be(true);
                                (e: Error).message.should.be("error");
                                done();
                            }
                        );
                        wait(5, done);
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
                        }).then(function (_) { fail(); done(); });
                        wait(10, done);
                    });

                    it("should call rejected(_)", function (done) {
                        new SyncPromise(function (_, reject) {
                            wait(5, reject.bind());
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                        wait(10, done);
                    });

                    it("should call rejected(_)", function (done) {
                        new SyncPromise(function (_, reject) {
                            wait(5, reject.bind());
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                        wait(10, done);
                    });

                    it("should call rejected(x)", function (done) {
                        new SyncPromise(function (_, reject) {
                            wait(5, reject.bind("error"));
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.same(e, "error").should.be(true);
                                done();
                            }
                        );
                        wait(10, done);
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
            timeoutMs = 1000;

            it("should call resolved(_)", function (done) {
                SyncPromise.resolve().then(
                    function (_) {
                        done();
                    },
                    function (_) { fail(); done(); }
                );
                wait(5, done);
            });

            it("should call resolved(x)", function (done) {
                SyncPromise.resolve(1).then(
                    function (x) {
                        x.should.be(1);
                        done();
                    },
                    function (_) { fail(); done(); }
                );
                wait(5, done);
            });
        });

        describe("SyncPromise.reject()", {
            timeoutMs = 1000;

           it("should call rejected(x)", function (done) {
                SyncPromise.reject("error").then(
                    function (_) { fail(); done(); },
                    function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    }
                );
                wait(5, done);
            });

            it("should call rejected(_)", function (done) {
                 SyncPromise.reject("error").then(
                    function (_) { fail(); done(); },
                    function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    }
                );
                wait(5, done);
            });
        });

        describe("SyncPromise.then()/catchError()", {
            timeoutMs = 1000;

            describe("sync", {
                it("should call - then", function (done) {
                    SyncPromise.reject("error").then(null, function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    });
                });

                it("should call - catchError", function (done) {
                    SyncPromise.reject("error").catchError(function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    });
                });

                it("should not call", function (done) {
                    SyncPromise.reject("error").then( function (_) {
                        fail();
                        done();
                    });
                    wait(5, done);
                });
            });

            describe("async", {
                it("should call - then", function (done) {
                    new SyncPromise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
                    }).then(null, function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    });
                });

                it("should call - catchError", function (done) {
                    new SyncPromise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
                    }).catchError(function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    });
                });

                it("should not call", function (done) {
                    new SyncPromise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
                    }).then( function (_) {
                        fail();
                        done();
                    });
                    wait(10, done);
                });
            });

            describe("throw error", {
                it("should chain rejected when it throw in fulfilled", function (done) {
                    SyncPromise.resolve(1).then(function (x) {
                        throw "error";
                    }).catchError(function (e) {
                        Std.is(e, Error).should.be(true);
                        (e: Error).message.should.be("error");
                        done();
                    });
                });

                it("should chain rejected when it throw in rejected", function (done) {
                    SyncPromise.reject("foo").catchError(function (x) {
                        throw "error";
                    }).catchError(function (e) {
                        Std.is(e, Error).should.be(true);
                        (e: Error).message.should.be("error");
                        done();
                    });
                });
            });

            describe("recover", {
                it("should be rejected", function (done) {
                    SyncPromise.reject("foo").catchError(function (x) {
                        return 100;
                    }).then(function (x) {
                        x.should.be(100);
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain value", function (done) {
                        SyncPromise.resolve(1).then(function (x) {
                            return x + 1;
                        }).then(function (x) {
                            return x + 100;
                        }).then(function (x) {
                            x.should.be(102);
                            done();
                        });
                    });

                    it("should chain resolved SyncPromise", function (done) {
                        SyncPromise.resolve(1).then(function (x) {
                            return SyncPromise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected SyncPromise", function (done) {
                        SyncPromise.resolve(1).then(function (x) {
                            return SyncPromise.reject("error");
                        }).catchError(function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    #if js
                    it("should chain resolved js.Promise", function (done) {
                        SyncPromise.resolve(1).then(function (x) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected js.Promise", function (done) {
                        SyncPromise.resolve(1).then(function (x) {
                            return js.Promise.reject("error");
                        }).catchError(function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });
                    #end
                });

                describe("from rejected", {
                    it("should chain value", function (done) {
                        SyncPromise.reject("error").catchError(function (e) {
                            return 1;
                        }).then(function (x) {
                            return x + 100;
                        }).then(function (x) {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain resolved SyncPromise", function (done) {
                        SyncPromise.reject("error").catchError(function (e) {
                            return SyncPromise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected SyncPromise", function (done) {
                        SyncPromise.reject("error").catchError(function (e) {
                            return SyncPromise.reject("error chained");
                        }).catchError(function (e) {
                            LangTools.same(e, "error chained").should.be(true);
                            done();
                        });
                    });

                    it("should chain rejected Promise : throw error", function (done) {
                        SyncPromise.reject("error").catchError(function (e) {
                            throw "error chained";
                        }).catchError(function (e) {
                            Std.is(e, Error).should.be(true);
                            (e: Error).message.should.be("error chained");
                            done();
                        });
                    });

                    #if js
                    it("should chain resolved js.Promise", function (done) {
                        SyncPromise.reject("error").catchError(function (e) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected js.Promise", function (done) {
                        SyncPromise.reject("error").catchError(function (e) {
                            return js.Promise.reject("error chained");
                        }).catchError(function (e) {
                            LangTools.same(e, "error chained").should.be(true);
                            done();
                        });
                    });
                    #end
                });
            });
        });
    }
}