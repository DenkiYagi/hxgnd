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

            describe("recover", {
                it("should be rejected", function (done) {
                    AbortablePromise.reject("foo")
                    .then(null, function (x) {
                        return 100;
                    }).then(function (x) {
                        x.should.be(100);
                        done();
                    });
                });
            });

            describe("throw error", {
                it("should chain rejected when it throw error in fulfilled", function (done) {
                    AbortablePromise.resolve(1)
                    .then(function (x) {
                        throw "error";
                    }).then(null, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should chain rejected when it throw error in rejected", function (done) {
                    AbortablePromise.reject("foo")
                    .catchError(function (x) {
                        throw "error";
                    }).then(null, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain value", function (done) {
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

                    it("should chain resolved AbortablePromise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return AbortablePromise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected AbortablePromise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return AbortablePromise.reject("error");
                        }).then(null, function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should call fulfilled : sync resolve(1) -> catchError() -> then() ", function (done) {
                        AbortablePromise.resolve(1)
                        .then(null, function (e) {
                            return -1;
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should call fulfilled : async resolve(1) -> catchError() -> then() ", function (done) {
                        new AbortablePromise(function (fulfill, _) {
                            wait(5, fulfill.bind(1));
                            return function () {};
                        })
                        .then(null, function (e) {
                            return -1;
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    #if js
                    it("should chain resolved js.Promise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected js.Promise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return js.Promise.reject("error");
                        }).then(null, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });
                    #end
                });

                describe("from rejected", {
                    it("should chain value", function (done) {
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

                    it("should chain resolved AbortablePromise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (e) {
                            return AbortablePromise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected AbortablePromise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (e) {
                            return AbortablePromise.reject("error chained");
                        }).then(null, function (e) {
                            (e: String).should.be("error chained");
                            done();
                        });
                    });

                    it("should chain rejected AbortablePromise : throw error", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (e) {
                            throw "error chained";
                        })
                        .then(null, function (e) {
                            (e: String).should.be("error chained");
                            done();
                        });
                    });

                    it("should call rejected : sync reject('error') -> then() -> catchError()", function (done) {
                        AbortablePromise.reject("error")
                        .then(function (x) {
                            return 100;
                        }).then(null, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should call rejected : async reject('error') -> then() -> catchError()", function (done) {
                        new AbortablePromise(function (_, reject) {
                            wait(5, reject.bind("error"));
                            return function () {};
                        }).then(function (x) {
                            return 100;
                        }).then(null, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    #if js
                    it("should chain resolved js.Promise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (e) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected js.Promise", function (done) {
                        AbortablePromise.reject("error")
                        .then(null, function (e) {
                            return js.Promise.reject("error chained");
                        }).then(null, function (e) {
                            LangTools.same(e, "error chained").should.be(true);
                            done();
                        });
                    });
                    #end
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

            describe("recover", {
                it("should be rejected", function (done) {
                    AbortablePromise.reject("foo")
                    .catchError(function (x) {
                        return 100;
                    }).then(function (x) {
                        x.should.be(100);
                        done();
                    });
                });
            });

            describe("throw error", {
                it("should chain rejected when it throw error in fulfilled", function (done) {
                    AbortablePromise.resolve(1)
                    .then(function (x) {
                        throw "error";
                    }).catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should chain rejected when it throw error in rejected", function (done) {
                    AbortablePromise.reject("foo")
                    .catchError(function (x) {
                        throw "error";
                    }).catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("chain", {
                describe("from resolved", {
                    it("should chain rejected AbortablePromise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return AbortablePromise.reject("error");
                        }).catchError(function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should call fulfilled : sync resolve(1) -> catchError() -> then() ", function (done) {
                        AbortablePromise.resolve(1)
                        .catchError(function (e) {
                            return -1;
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should call fulfilled : async resolve(1) -> catchError() -> then() ", function (done) {
                        new AbortablePromise(function (fulfill, _) {
                            wait(5, fulfill.bind(1));
                            return function () {};
                        }).catchError(function (e) {
                            return -1;
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    #if js
                    it("should chain rejected js.Promise", function (done) {
                        AbortablePromise.resolve(1)
                        .then(function (x) {
                            return js.Promise.reject("error");
                        }).catchError(function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });
                    #end
                });

                describe("from rejected", {
                    it("should chain value", function (done) {
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

                    it("should chain resolved AbortablePromise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return AbortablePromise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected AbortablePromise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return AbortablePromise.reject("error chained");
                        }).catchError(function (e) {
                            (e: String).should.be("error chained");
                            done();
                        });
                    });

                    it("should chain rejected AbortablePromise : throw error", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            throw "error chained";
                        }).catchError(function (e) {
                            (e: String).should.be("error chained");
                            done();
                        });
                    });

                    it("should call rejected : sync reject('error') -> then() -> catchError()", function (done) {
                        AbortablePromise.reject("error")
                        .then(function (x) {
                            return 100;
                        }).catchError(function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should call rejected : async reject('error') -> then() -> catchError()", function (done) {
                        new AbortablePromise(function (_, reject) {
                            wait(5, reject.bind("error"));
                            return function () {};
                        }).then(function (x) {
                            return 100;
                        }).catchError(function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    #if js
                    it("should chain resolved js.Promise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected js.Promise", function (done) {
                        AbortablePromise.reject("error")
                        .catchError(function (e) {
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

        describe("AbortablePromise.abort()", {
            // 未完了で呼び出し
            // resolve済み
            // reject済み
            // 2度abort
        });
    }
}