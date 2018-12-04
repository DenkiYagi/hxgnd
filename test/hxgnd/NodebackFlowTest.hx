package hxgnd;

import buddy.BuddySuite;
import buddy.CompilationShould;
using buddy.Should;

class NodebackFlowTest extends BuddySuite {
    public function new() {
        timeoutMs = 100;

        describe("NodebackFlow.compute()", {
            describe("empty expr", {
                it("should pass", function (done) {
                    NodebackFlow.compute({}).then(function (_) {
                        done();
                    });
                });
            });

            describe("bind", {
                describe("no callback", {
                    it("should not be able to compile when it evaluates a function that has no argument", CompilationShould.failFor({
                        function f1() return 10;

                        NodebackFlow.compute({
                            @do f1();
                        });
                    }));

                    it("should not be able to compile when it evaluates a function that has some arguments", CompilationShould.failFor({
                        function f1(a: Int, b: Int) return a + b;

                        NodebackFlow.compute({
                            @do f1(1, 2);
                        });
                    }));
                });

                describe("without placeholder", {
                    it("should pass when it evaluates a function that has no argument", function (done) {
                        function f1(cb: Void -> Void) cb();

                        NodebackFlow.compute({
                            @do f1();
                        }).then(function (_) {
                            done();
                        });
                    });

                    it("should pass when it evaluates a function that has some arguments", function (done) {
                        function f1(a: Int, b: Int, cb: Void -> Void) {
                            a.should.be(10);
                            b.should.be(20);
                            cb();
                        }

                        NodebackFlow.compute({
                            @do f1(10, 20);
                        }).then(function (_) {
                            done();
                        });
                    });

                    it("should not be able to compile when it is not enough arguments", CompilationShould.failFor({
                        function f1(a: Int, b: Int, cb: Void -> Void) {
                            cb();
                        }

                        NodebackFlow.compute({
                            @do f1(10);
                        }).then(function (_) {
                            fail();
                        });
                    }));

                    it("should not be able to compile when it is too many arguments", CompilationShould.failFor({
                        function f1(a: Int, b: Int, cb: Void -> Void) {
                            cb();
                        }

                        NodebackFlow.compute({
                            @do f1(1, 2, 3);
                        });
                    }));
                });

                describe("with placeholder", {
                    it("should pass when it evaluates a function that has no argument", function (done) {
                        function f1(cb: Void -> Void) {
                            cb();
                        }

                        NodebackFlow.compute({
                            @do f1(_);
                        }).then(function (_) {
                            done();
                        });
                    });

                    it("should pass when it evaluates a function that has some arguments", function (done) {
                        function f1(cb: Void -> Void, a: Int, b: Int) {
                            a.should.be(10);
                            b.should.be(20);
                            cb();
                        }

                        NodebackFlow.compute({
                            @do f1(_, 10, 20);
                        }).then(function (_) {
                            done();
                        });
                    });

                    it("should not be able to compile when it is not enough arguments", CompilationShould.failFor({
                        function f1(cb: Void -> Void, a: Int, b: Int) {
                            cb();
                        }

                        NodebackFlow.compute({
                            @do f1(_, 10);
                        }).then(function (_) {
                            fail();
                        });
                    }));

                    it("should not be able to compile when it is too many arguments", CompilationShould.failFor({
                        function f1(cb: Void -> Void, a: Int, b: Int) {
                            cb();
                        }

                        NodebackFlow.compute({
                            @do f1(_, 1, 2, 3);
                        });
                    }));
                });

                describe("@var assign", {
                    it("should pass when it is given (Void -> Void)", function (done) {
                        function f1(cb: Void -> Void) {
                            cb();
                        }

                        NodebackFlow.compute({
                            @var a = f1();
                            a.should.be(new extype.Unit());
                        }).then(function (_) {
                            done();
                        });
                    });

                    it("should pass when it is given (\"error\" -> Void)", function (done) {
                        function f1(cb: Null<String> -> Void) {
                            cb("error");
                        }

                        NodebackFlow.compute({
                            @var a = f1();
                        }).then(function (_) {
                            fail();
                        }, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should pass when it is given (null -> Void)", function (done) {
                        function f1(cb: Null<String> -> Void) {
                            cb(null);
                        }

                        NodebackFlow.compute({
                            @var a = f1();
                            a.should.be(new extype.Unit());
                        }).then(function (_) {
                            done();
                        });
                    });

                    it("should pass when it is given (\"error\" -> Int -> Void)", function (done) {
                        function f1(cb: Null<String> -> Int -> Void) {
                            cb("error", 20);
                        }

                        NodebackFlow.compute({
                            @var a = f1();
                        }).then(function (_) {
                            fail();
                        }, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should pass when it is given (null -> Int -> Void)", function (done) {
                        function f1(cb: Null<String> -> Int -> Void) {
                            cb(null, 10);
                        }

                        NodebackFlow.compute({
                            @var a = f1();
                            a.should.be(10);
                        }).then(function (_) {
                            done();
                        });
                    });

                    it("should pass when it is given (\"error\" -> Int -> Int -> Void)", function (done) {
                        function f1(cb: Null<String> -> Int -> Int -> Void) {
                            cb("error", 10, 20);
                        }

                        NodebackFlow.compute({
                            @var a = f1();
                        }).then(function (_) {
                            fail();
                        }, function (e) {
                            (e: String).should.be("error");
                            done();
                        });
                    });

                    it("should pass when it is given (null -> Int -> Int -> Void)", function (done) {
                        function f1(cb: Null<String> -> Int -> Int -> Void) {
                            cb(null, 10, 20);
                        }

                        NodebackFlow.compute({
                            @var a = f1();
                            a.value1.should.be(10);
                            a.value2.should.be(20);
                        }).then(function (_) {
                            done();
                        });
                    });
                });
            });

            describe("return", {
                it("should pass", function (done) {
                    function f1(cb: Null<String> -> Int -> Void) {
                        cb(null, 10);
                    }

                    NodebackFlow.compute({
                        @var a = f1();
                        return a * 10;
                    }).then(function (x) {
                        x.should.be(100);
                        done();
                    });
                });
            });

            describe("@return", {
                it("should pass", function (done) {
                    NodebackFlow.compute({
                        @return Promise.resolve(10);
                    }).then(function (x) {
                        x.should.be(10);
                        done();
                    });
                });
            });

            describe("if", {
                it("should pass when it is given true", function (done) {
                    function f1(cb: Null<Dynamic> -> Bool -> Void) {
                        cb(null, true);
                    }

                    NodebackFlow.compute({
                        @var a = f1();
                        var b = 0;
                        if (a) {
                            b++;
                        }
                        var c = b + 10; // after cexpr
                        return c;
                    }).then(function (x) {
                        x.should.be(11);
                        done();
                    });
                });

                it("should pass when it is given false", function (done) {
                    function f1(cb: Null<Dynamic> -> Bool -> Void) {
                        cb(null, false);
                    }

                    NodebackFlow.compute({
                        @var a = f1();
                        var b = 0;
                        if (a) {
                            b++;
                        }
                        var c = b + 10; // after cexpr
                        return c;
                    }).then(function (x) {
                        x.should.be(10);
                        done();
                    });
                });
            });

            describe("while", {
                it("should pass", function (done) {
                    function f1(a: Int, cb: Null<Dynamic> -> Int -> Void) {
                        cb(null, a);
                    }

                    NodebackFlow.compute({
                        var acc = 0;
                        var i = 0;
                        while (i < 5) {
                            @var x = f1(i++, _);
                            acc += x;
                        }
                        return acc;
                    }).then(function (x) {
                        x.should.be(10);
                        done();
                    });
                });
            });

            describe("for", {
                it("should pass", function (done) {
                    function f1(a: Int, cb: Null<Dynamic> -> Int -> Void) {
                        cb(null, a);
                    }

                    NodebackFlow.compute({
                        var acc = 0;
                        for (i in 0...4) {
                            @var x = f1(i, _);
                            acc += x;
                        }
                        return acc;
                    }).then(function (x) {
                        x.should.be(6);
                        done();
                    });
                });
            });

            describe("mixed pattern", {
                it("should pass", function (done) {
                    function f1(cb: Null<Dynamic> -> Int -> Void) {
                        cb(null, 10);
                    }

                    function f2(cb: Null<Dynamic> -> Int -> String -> Void) {
                        cb(null, 20, "hello");
                    }

                    NodebackFlow.compute({
                        @var a = f1();
                        @var b = f2();
                        return { value: a + b.value1, message: b.value2 };
                    }).then(function (x) {
                        x.value.should.be(30);
                        x.message.should.be("hello");
                        done();
                    });
                });

                it("should pass when it is nested pattern", function (done) {
                    function f1(cb: Null<Dynamic> -> Int -> Void) {
                        cb(null, 10);
                    }

                    function f2(cb: Null<Dynamic> -> Int -> Void) {
                        cb(null, 20);
                    }

                    NodebackFlow.compute({
                        @var a = f1();
                        @return NodebackFlow.compute({
                            @var b = f2();
                            return a + b;
                        });
                    }).then(function (x) {
                        x.should.be(30);
                        done();
                    });
                });
            });
        });

        describe("NodebackFlow.promisifyCall()", {
            describe("no callback", {
                it("should not be able to compile when it evaluates a function that has no argument", CompilationShould.failFor({
                    function f1() return 10;

                    NodebackFlow.promisifyCall(f1);
                }));

                it("should not be able to compile when it evaluates a function that has some arguments", CompilationShould.failFor({
                    function f1(a: Int, b: Int) return a + b;

                    NodebackFlow.promisifyCall(f1, 1, 2);
                }));
            });

            describe("without placeholder", {
                it("should pass when it evaluates a function that has no argument", function (done) {
                    function f1(cb: Void -> Void) cb();

                    NodebackFlow.promisifyCall(f1).then(function (_) {
                        done();
                    });
                });

                it("should pass when it evaluates a function that has some arguments", function (done) {
                    function f1(a: Int, b: Int, cb: Void -> Void) {
                        a.should.be(10);
                        b.should.be(20);
                        cb();
                    }

                    NodebackFlow.promisifyCall(f1, 10, 20).then(function (_) {
                        done();
                    });
                });

                it("should not be able to compile when it is not enough arguments", CompilationShould.failFor({
                    function f1(a: Int, b: Int, cb: Void -> Void) {
                        cb();
                    }

                    NodebackFlow.promisifyCall(f1, 10);
                }));

                it("should not be able to compile when it is too many arguments", CompilationShould.failFor({
                    function f1(a: Int, b: Int, cb: Void -> Void) {
                        cb();
                    }

                    NodebackFlow.promisifyCall(f1, 1, 2, 3);
                }));
            });

            describe("with placeholder", {
                it("should pass when it evaluates a function that has no argument", function (done) {
                    function f1(cb: Void -> Void) {
                        cb();
                    }

                    NodebackFlow.promisifyCall(f1, _).then(function (_) {
                        done();
                    });
                });

                it("should pass when it evaluates a function that has some arguments", function (done) {
                    function f1(cb: Void -> Void, a: Int, b: Int) {
                        a.should.be(10);
                        b.should.be(20);
                        cb();
                    }

                    NodebackFlow.promisifyCall(f1, _, 10, 20).then(function (_) {
                        done();
                    });
                });

                it("should not be able to compile when it is not enough arguments", CompilationShould.failFor({
                    function f1(cb: Void -> Void, a: Int, b: Int) {
                        cb();
                    }

                    NodebackFlow.promisifyCall(f1, _, 10).then(function (_) {
                        fail();
                    });
                }));

                it("should not be able to compile when it is too many arguments", CompilationShould.failFor({
                    function f1(cb: Void -> Void, a: Int, b: Int) {
                        cb();
                    }

                    NodebackFlow.promisifyCall(f1, _, 1, 2, 3);
                }));
            });

            describe("callback argument", {
                it("should pass when it is given (Void -> Void)", function (done) {
                    function f1(cb: Void -> Void) {
                        cb();
                    }

                    NodebackFlow.promisifyCall(f1).then(function (x) {
                        x.should.be(new extype.Unit());
                        done();
                    });
                });

                it("should pass when it is given (\"error\" -> Void)", function (done) {
                    function f1(cb: Null<String> -> Void) {
                        cb("error");
                    }

                    NodebackFlow.promisifyCall(f1)
                    .then(function (_) {
                        fail();
                    }, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should pass when it is given (null -> Void)", function (done) {
                    function f1(cb: Null<String> -> Void) {
                        cb(null);
                    }

                    NodebackFlow.promisifyCall(f1).then(function (x) {
                        x.should.be(new extype.Unit());
                        done();
                    });
                });

                it("should pass when it is given (\"error\" -> Int -> Void)", function (done) {
                    function f1(cb: Null<String> -> Int -> Void) {
                        cb("error", 20);
                    }

                    NodebackFlow.promisifyCall(f1)
                    .then(function (_) {
                        fail();
                    }, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should pass when it is given (null -> Int -> Void)", function (done) {
                    function f1(cb: Null<String> -> Int -> Void) {
                        cb(null, 10);
                    }

                    NodebackFlow.promisifyCall(f1).then(function (x) {
                        x.should.be(10);
                        done();
                    });
                });

                it("should pass when it is given (\"error\" -> Int -> Int -> Void)", function (done) {
                    function f1(cb: Null<String> -> Int -> Int -> Void) {
                        cb("error", 10, 20);
                    }

                    NodebackFlow.promisifyCall(f1)
                    .then(function (_) {
                        fail();
                    }, function (e) {
                        (e: String).should.be("error");
                        done();
                    });
                });

                it("should pass when it is given (null -> Int -> Int -> Void)", function (done) {
                    function f1(cb: Null<String> -> Int -> Int -> Void) {
                        cb(null, 10, 20);
                    }

                    NodebackFlow.promisifyCall(f1).then(function (x) {
                        x.value1.should.be(10);
                        x.value2.should.be(20);
                        done();
                    });
                });
            });

            describe("typedef", {
                it("should pass when it is given a typedef callback function", function (done) {
                    function f1(cb: Callback2<Int>) {
                        cb(null, 10);
                    }

                    NodebackFlow.promisifyCall(f1).then(function (x) {
                        x.should.be(10);
                        done();
                    });
                });

                it("should pass when it is given a typedef-alias callback function", function (done) {
                    function f1(cb: Callback3_Alias<Int, Int>) {
                        cb(null, 10, 20);
                    }

                    NodebackFlow.promisifyCall(f1).then(function (x) {
                        x.value1.should.be(10);
                        x.value2.should.be(20);
                        done();
                    });
                });
            });
        });
    }
}

private typedef Callback2<T> = extype.Error -> T -> Void;
private typedef Callback3<T1, T2> = extype.Error -> T1 -> T2 -> Void;
private typedef Callback3_Alias<T1, T2> = Callback3<T1, T2>;