package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using hxgnd.LangTools;
using buddy.Should;

class PromiseTest extends BuddySuite {
    public function new() {
        describe("Promise.new()", {
            timeoutMs = 100;

            describe("executor", {
                it("should call", function (done) {
                    new Promise(function (_, _) {
                        done();
                    });
                });
            });

            describe("pending", {
                it("should be not completed", function (done) {
                    new Promise(function (_, _) {}).then(
                        function (_) { fail(); done(); },
                        function (_) { fail(); done(); }
                    );
                    wait(5, done);
                });
            });

            describe("fulfilled", {
                describe("sync", {
                    it("should pass", function (done) {
                        new Promise(function (fulfill, _) {
                            fulfill();
                        });
                        wait(5, done);
                    });

                    it("should pass when it have no fulfilled", function (done) {
                        new Promise(function (fulfill, _) {
                            fulfill();
                        }).then(null, function (_) { fail(); done(); });
                        wait(5, done);
                    });

                    it("should call fulfilled(_)", function (done) {
                        new Promise(function (fulfill, _) {
                            fulfill();
                        }).then(
                            function (_) { done(); },
                            function (_) { fail(); done(); }
                        );
                    });

                    it("should call fulfilled(x)", function (done) {
                        new Promise(function (fulfill, _) {
                            fulfill(1);
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
                        new Promise(function (fulfill, _) {
                            wait(5, fulfill.bind());
                        });
                        wait(10, done);
                    });

                    it("should pass when it have no fulfilled", function (done) {
                        new Promise(function (fulfill, _) {
                            wait(5, fulfill.bind());
                        }).then(null, function (_) { fail(); done(); });
                        wait(10, done);
                    });

                    it("should call fulfilled(_)", function (done) {
                        new Promise(function (fulfill, _) {
                            wait(5, fulfill.bind());
                        }).then(
                            function (_) { done(); },
                            function (_) { fail(); done(); }
                        );
                    });

                    it("should call fulfilled(x)", function (done) {
                        new Promise(function (fulfill, _) {
                            wait(5, fulfill.bind(1));
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
                        new Promise(function (_, reject) {
                            reject();
                        });
                        wait(5, done);
                    });

                    it("should pass when it have no rejected", function (done) {
                        new Promise(function (_, reject) {
                            reject();
                        }).then(function (_) { fail(); done(); });
                        wait(5, done);
                    });

                    it("should call rejected(_)", function (done) {
                        new Promise(function (_, reject) {
                            reject();
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(_)", function (done) {
                        new Promise(function (_, reject) {
                            reject();
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(x)", function (done) {
                        new Promise(function (_, reject) {
                            reject("error");
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                (e: String).should.be("error");
                                done();
                            }
                        );
                    });

                    it("should call rejected when it is thrown error", function (done) {
                        new Promise(function (_, _) {
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
                        new Promise(function (_, reject) {
                            wait(5, reject.bind());
                        });
                        wait(10, done);
                    });

                    it("should pass when it have no rejected", function (done) {
                        new Promise(function (_, reject) {
                            wait(5, reject.bind());
                        }).then(function (_) { fail(); done(); });
                        wait(10, done);
                    });

                    it("should call rejected(_)", function (done) {
                        new Promise(function (_, reject) {
                            wait(5, reject.bind());
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(_)", function (done) {
                        new Promise(function (_, reject) {
                            wait(5, reject.bind());
                        }).then(
                            function (_) { fail(); done(); },
                            function (e) {
                                LangTools.isNull(e).should.be(true);
                                done();
                            }
                        );
                    });

                    it("should call rejected(x)", function (done) {
                        new Promise(function (_, reject) {
                            wait(5, reject.bind("error"));
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
                    var promise = new Promise(function (_, _) {});
                    promise.should.beType(js.Promise);
                });
            });
            #end
        });

        describe("Promise.resolve()", {
            timeoutMs = 100;

            it("should call resolved(_)", function (done) {
                Promise.resolve().then(
                    function (_) { done(); },
                    function (_) { fail(); done(); }
                );
            });

            it("should call resolved(x)", function (done) {
                Promise.resolve(1).then(
                    function (x) {
                        x.should.be(1);
                        done();
                    },
                    function (_) { fail(); done(); }
                );
            });
        });

        describe("Promise.reject()", {
            timeoutMs = 100;

           it("should call rejected(x)", function (done) {
                Promise.reject("error").then(
                    function (_) { fail(); done(); },
                    function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    }
                );
            });

            it("should call rejected(_)", function (done) {
                 Promise.reject("error").then(
                    function (_) { fail(); done(); },
                    function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    }
                );
            });
        });

        describe("Promise.then()", {
            timeoutMs = 100;

            describe("sync", {
                it("should call fulfilled", function (done) {
                    new Promise(function (fulfill, _) {
                        fulfill(100);
                    }).then(function (x) {
                        x.should.be(100);
                        done();
                    }, function (_) {
                        fail();
                        done();
                    });
                });

                it("should call rejected", function (done) {
                    new Promise(function (_, reject) {
                        reject("error");
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
                    new Promise(function (fulfill, _) {
                        wait(5, function () {
                            fulfill(100);
                        });
                    }).then(function (x) {
                        x.should.be(100);
                        done();
                    }, function (_) {
                        fail();
                        done();
                    });
                });

                it("should call rejected", function (done) {
                    new Promise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
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
                    Promise.reject("foo")
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
                    Promise.resolve(1)
                    .then(function (x) {
                        throw "error";
                    }).then(null, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should chain rejected when it throw error in rejected", function (done) {
                    Promise.reject("foo")
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
                        Promise.resolve(1)
                        .then(function (x) {
                            return x + 1;
                        }).then(function (x) {
                            return x + 100;
                        }).then(function (x) {
                            x.should.be(102);
                            done();
                        });
                    });

                    it("should chain resolved Promise", function (done) {
                        Promise.resolve(1)
                        .then(function (x) {
                            return Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected Promise", function (done) {
                        Promise.resolve(1)
                        .then(function (x) {
                            return Promise.reject("error");
                        }).then(null, function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should call fulfilled : sync resolve(1) -> catchError() -> then() ", function (done) {
                        Promise.resolve(1)
                        .then(null, function (e) {
                            return -1;
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should call fulfilled : async resolve(1) -> catchError() -> then() ", function (done) {
                        new Promise(function (fulfill, _) {
                            wait(5, fulfill.bind(1));
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
                        Promise.resolve(1)
                        .then(function (x) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected js.Promise", function (done) {
                        Promise.resolve(1)
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
                        Promise.reject("error")
                        .then(null, function (e) {
                            return 1;
                        }).then(function (x) {
                            return x + 100;
                        }).then(function (x) {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain resolved Promise", function (done) {
                        Promise.reject("error")
                        .then(null, function (e) {
                            return Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected Promise", function (done) {
                        Promise.reject("error")
                        .then(null, function (e) {
                            return Promise.reject("error chained");
                        }).then(null, function (e) {
                            (e: String).should.be("error chained");
                            done();
                        });
                    });

                    it("should chain rejected Promise : throw error", function (done) {
                        Promise.reject("error")
                        .then(null, function (e) {
                            throw "error chained";
                        })
                        .then(null, function (e) {
                            (e: String).should.be("error chained");
                            done();
                        });
                    });

                    it("should call rejected : sync reject('error') -> then() -> catchError()", function (done) {
                        Promise.reject("error")
                        .then(function (x) {
                            return 100;
                        }).then(null, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should call rejected : async reject('error') -> then() -> catchError()", function (done) {
                        new Promise(function (_, reject) {
                            wait(5, reject.bind("error"));
                        }).then(function (x) {
                            return 100;
                        }).then(null, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    #if js
                    it("should chain resolved js.Promise", function (done) {
                        Promise.reject("error")
                        .then(null, function (e) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected js.Promise", function (done) {
                        Promise.reject("error")
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

        describe("Promise.catchError()", {
            timeoutMs = 100;

            describe("sync", {
                it("should not call", function (done) {
                    new Promise(function (fulfill, _) {
                        fulfill(100);
                    }).catchError(function (_) {
                        fail();
                        done();
                    });
                    wait(5, done);
                });

                it("should call", function (done) {
                    new Promise(function (_, reject) {
                        reject("error");
                    }).catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("async", {
                it("should not call", function (done) {
                    new Promise(function (fulfill, _) {
                        wait(5, function () {
                            fulfill(100);
                        });
                    }).catchError(function (_) {
                        fail();
                        done();
                    });
                    wait(5, done);
                });

                it("should call", function (done) {
                    new Promise(function (_, reject) {
                        wait(5, function () {
                            reject("error");
                        });
                    }).catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });
            });

            describe("recover", {
                it("should be rejected", function (done) {
                    Promise.reject("foo")
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
                    Promise.resolve(1)
                    .then(function (x) {
                        throw "error";
                    }).catchError(function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should chain rejected when it throw error in rejected", function (done) {
                    Promise.reject("foo")
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
                    it("should chain rejected Promise", function (done) {
                        Promise.resolve(1)
                        .then(function (x) {
                            return Promise.reject("error");
                        }).catchError(function (e) {
                            LangTools.same(e, "error").should.be(true);
                            done();
                        });
                    });

                    it("should call fulfilled : sync resolve(1) -> catchError() -> then() ", function (done) {
                        Promise.resolve(1)
                        .catchError(function (e) {
                            return -1;
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    it("should call fulfilled : async resolve(1) -> catchError() -> then() ", function (done) {
                        new Promise(function (fulfill, _) {
                            wait(5, fulfill.bind(1));
                        }).catchError(function (e) {
                            return -1;
                        }).then(function (x) {
                            x.should.be(1);
                            done();
                        });
                    });

                    #if js
                    it("should chain rejected js.Promise", function (done) {
                        Promise.resolve(1)
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
                        Promise.reject("error")
                        .catchError(function (e) {
                            return 1;
                        }).then(function (x) {
                            return x + 100;
                        }).then(function (x) {
                            x.should.be(101);
                            done();
                        });
                    });

                    it("should chain resolved Promise", function (done) {
                        Promise.reject("error")
                        .catchError(function (e) {
                            return Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected Promise", function (done) {
                        Promise.reject("error")
                        .catchError(function (e) {
                            return Promise.reject("error chained");
                        }).catchError(function (e) {
                            (e: String).should.be("error chained");
                            done();
                        });
                    });

                    it("should chain rejected Promise : throw error", function (done) {
                        Promise.reject("error")
                        .catchError(function (e) {
                            throw "error chained";
                        }).catchError(function (e) {
                            (e: String).should.be("error chained");
                            done();
                        });
                    });

                    it("should call rejected : sync reject('error') -> then() -> catchError()", function (done) {
                        Promise.reject("error")
                        .then(function (x) {
                            return 100;
                        }).catchError(function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should call rejected : async reject('error') -> then() -> catchError()", function (done) {
                        new Promise(function (_, reject) {
                            wait(5, reject.bind("error"));
                        }).then(function (x) {
                            return 100;
                        }).catchError(function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    #if js
                    it("should chain resolved js.Promise", function (done) {
                        Promise.reject("error")
                        .catchError(function (e) {
                            return js.Promise.resolve("hello");
                        }).then(function (x) {
                            x.should.be("hello");
                            done();
                        });
                    });

                    it("should chain rejected js.Promise", function (done) {
                        Promise.reject("error")
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

        #if js
        describe("Promise cast", {
            it("should cast from js.Promise", function (done) {
                var jsPromise = js.Promise.resolve(1);
                var promise: Promise<Int> = jsPromise;
                promise.then(function (v) {
                    v.should.be(1);
                    done();
                });
            });

            it("should cast to js.Promise", function (done) {
                var promise = Promise.resolve(1);
                var jsPromise: js.Promise<Int> = promise;
                jsPromise.then(function (v) {
                    LangTools.same(v, 1).should.be(true);
                    done();
                });
            });
        });
        #end

        describe("Promise.all()", {
            timeoutMs = 1000;

            it("should resolve empty array", function (done) {
                Promise.all([]).then(function (values) {
                    LangTools.same(values, []).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });

            it("should resolve", function (done) {
                Promise.all([
                    Promise.resolve(1)
                ]).then(function (values) {
                    LangTools.same(values, [1]).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });

            it("should reject", function (done) {
                Promise.all([
                    Promise.reject("error")
                ]).then(function (values) {
                    fail();
                    done();
                }, function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });

            it("should resolve ordered values", function (done) {
                Promise.all([
                    new Promise(function (f, _) {
                        wait(5, f.bind(1));
                    }),
                    Promise.resolve(2),
                    Promise.resolve(3)
                ]).then(function (values) {
                    LangTools.same(values, [1, 2, 3]).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });

            it("should reject by 2nd promise", function (done) {
                Promise.all([
                    new Promise(function (_, r) {
                        wait(5, r.bind("error1"));
                    }),
                    Promise.reject("error2"),
                    new Promise(function (_, r) {
                        wait(10, r.bind("error3"));
                    })
                ]).then(function (values) {
                    fail();
                    done();
                }, function (e) {
                    LangTools.same(e, "error2").should.be(true);
                    done();
                });
            });

            it("should reject by 3rd promise", function (done) {
                Promise.all([
                    Promise.resolve(1),
                    Promise.resolve(2),
                    Promise.reject("error3")
                ]).then(function (values) {
                    fail();
                    done();
                }, function (e) {
                    LangTools.same(e, "error3").should.be(true);
                    done();
                });
            });

            it("should process when it is mixed by Promise and Promise", function(done) {
                Promise.all([
                    Promise.resolve(1),
                    Promise.resolve(2)
                ]).then(function (values) {
                    LangTools.same(values, [1, 2]).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });
        });

        describe("Promise.race()", {
            timeoutMs = 100;

            it("should be pending", function (done) {
                Promise.race([]).then(function (value) {
                    fail();
                    done();
                }, function (_) {
                    fail();
                    done();
                });
                wait(10, done);
            });

            it("should resolve", function (done) {
                Promise.race([
                    Promise.resolve(1)
                ]).then(function (value) {
                    LangTools.same(value, 1).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });

            it("should reject", function (done) {
                Promise.race([
                    Promise.reject("error")
                ]).then(function (value) {
                    fail();
                    done();
                }, function (e) {
                    LangTools.same(e, "error").should.be(true);
                    done();
                });
            });

            it("should resolve by 2nd promise", function (done) {
                Promise.race([
                    new Promise(function (f, _) {
                        wait(5, f.bind(1));
                    }),
                    Promise.resolve(2),
                    Promise.resolve(3)
                ]).then(function (value) {
                    LangTools.same(value, 2).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });

            it("should reject by 2nd promise", function (done) {
                Promise.race([
                    new Promise(function (_, r) {
                        wait(5, r.bind("error1"));
                    }),
                    Promise.reject("error2"),
                    new Promise(function (_, r) {
                        wait(10, r.bind("error3"));
                    })
                ]).then(function (value) {
                    fail();
                    done();
                }, function (e) {
                    LangTools.same(e, "error2").should.be(true);
                    done();
                });
            });

            it("should resolve by 1st promise", function (done) {
                Promise.race([
                    Promise.resolve(1),
                    Promise.resolve(2),
                    Promise.reject("error3")
                ]).then(function (value) {
                    LangTools.same(value, 1).should.be(true);
                    done();
                }, function (e) {
                    fail();
                    done();
                });
            });

            it("should process when it is mixed by Promise and Promise", function(done) {
                Promise.race([
                    Promise.resolve(1),
                    Promise.resolve(2)
                ]).then(function (values) {
                    LangTools.same(values, 1).should.be(true);
                    done();
                }, function (_) {
                    fail();
                    done();
                });
            });
        });

        describe("Promise#compute()", {
            describe("simple expr", {
                // TODO buildZero
                it("should pass when it given {}", {
                    Promise.compute({});
                });

                it("should pass it given { 1 }", function (done) {
                    Promise.compute({
                        1;
                    }).then(function (x) {
                        x.should.be(1);
                        done();
                    });
                });

                it("should pass it given { 1 + 2 }", function (done) {
                    Promise.compute({
                        1 + 2;
                    }).then(function (x) {
                        x.should.be(3);
                        done();
                    });
                });

                // it("should pass it given { var a = 1; }", function (done) {
                //     Promise.compute({
                //         var a = 1;
                //     }).then(function (_) {
                //         done();
                //     });
                // });

                it("should pass it given { var a = 1; a + 1; }", function (done) {
                    Promise.compute({
                        var a = 1;
                        a + 1;
                    }).then(function (x) {
                        x.should.be(2);
                        done();
                    });
                });

                it("should pass it given { fn() }", function (done) {
                    function fn() {
                        return 1;
                    }

                    Promise.compute({
                        fn();
                    }).then(function (x) {
                        x.should.be(1);
                        done();
                    });
                });
            });

            describe("action", {
                it("should pass when it given { @await 2 }", function (done) {
                    Promise.compute({
                        @await 2;
                    }).then(function (_) {
                        done();
                    });
                });

                it("should pass when it given { @await Promise.resolve(3) }", function (done) {
                    Promise.compute({
                        @await Promise.resolve(3);
                    }).then(function (_) {
                        done();
                    });
                });

                it("should pass when it given { @await Promise.reject('error') }", function (done) {
                    Promise.compute({
                        @await Promise.reject("error");
                    }).then(function (_) {
                        fail();
                        done();
                    }).catchError(function (e) {
                        LangTools.same(e, "error").should.be(true);
                        done();
                    });
                });

                it("should pass when it given { @await Promise.resolve(3) }", function (done) {
                    function fn() {
                        return Promise.resolve(1);
                    }

                    Promise.compute({
                        @await fn();
                    }).then(function (_) {
                        done();
                    });
                });
            });

            describe("throw", {
                it("should pass when it given { throw 'error' }", function (done) {
                    Promise.compute({
                        throw "error";
                    }).then(function (_) {
                        fail();
                        done();
                    }).catchError(function (e) {
                        done();
                    });
                });

                // it("should pass when it given { @await 1; throw 'error' }", function (done) {
                //     Promise.compute({
                //         @await 1;
                //         throw "error";
                //     }).then(function (_) {
                //         fail();
                //         done();
                //     }).catchError(function (e: Dynamic) {
                //         trace(e);
                //         trace(e.stack);
                //         Std.is(e, Error).should.be(true);
                //         (e: Error).message.should.be("error");
                //         done();
                //     });
                // });

                // it("should pass when it given { var a = @await 1; throw 'error' }", function (done) {
                //     Promise.compute({
                //         var a = @await 1;
                //         throw "error";
                //     }).then(function (_) {
                //         fail();
                //         done();
                //     }).catchError(function (e) {
                //         LangTools.same(e, "error").should.be(true);
                //         done();
                //     });
                // });

                it("should pass when it given { @await Promise.reject('rejected'); throw 'error' }", function (done) {
                    Promise.compute({
                        @await Promise.reject("rejected");
                        throw "error";
                    }).then(function (_) {
                        fail();
                        done();
                    }).catchError(function (e) {
                        LangTools.same(e, "rejected").should.be(true);
                        done();
                    });
                });
            });
        });
    }
}