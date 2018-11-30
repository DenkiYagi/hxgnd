package hxgnd;

import buddy.BuddySuite;
import buddy.CompilationShould;
using buddy.Should;

class CallbackFlowTest extends BuddySuite {
    public function new() {
        timeoutMs = 100;

        describe("CallbackFlow.compute()", {
            // describe("empty expr", {
            //     it("should pass", function (done) {
            //         CallbackFlow.compute({}).then(function (_) {
            //             done();
            //         });
            //     });
            // });

            // describe("bind", {
            //     describe("no callback", {
            //         it("should not be able to compile when it evaluates a function that has no argument", CompilationShould.failFor({
            //             function f1() return 10;

            //             CallbackFlow.compute({
            //                 @do f1();
            //             });
            //         }));

            //         it("should not be able to compile when it evaluates a function that has some arguments", CompilationShould.failFor({
            //             function f1(a: Int, b: Int) return a + b;

            //             CallbackFlow.compute({
            //                 @do f1(1, 2);
            //             });
            //         }));
            //     });

            //     describe("without placeholder", {
            //         it("should pass when it evaluates a function that has no argument", function (done) {
            //             function f1(cb: Void -> Void) cb();

            //             CallbackFlow.compute({
            //                 @do f1();
            //             }).then(function (_) {
            //                 done();
            //             });
            //         });

            //         it("should pass when it evaluates a function that has some arguments", function (done) {
            //             function f1(a: Int, b: Int, cb: Void -> Void) {
            //                 a.should.be(10);
            //                 b.should.be(20);
            //                 cb();
            //             }

            //             CallbackFlow.compute({
            //                 @do f1(10, 20);
            //             }).then(function (_) {
            //                 done();
            //             });
            //         });

            //         it("should not be able to compile when it is not enough arguments", CompilationShould.failFor({
            //             function f1(a: Int, b: Int, cb: Void -> Void) {
            //                 cb();
            //             }

            //             CallbackFlow.compute({
            //                 @do f1(10);
            //             }).then(function (_) {
            //                 fail();
            //             });
            //         }));

            //         it("should not be able to compile when it is too many arguments", CompilationShould.failFor({
            //             function f1(a: Int, b: Int, cb: Void -> Void) {
            //                 cb();
            //             }

            //             CallbackFlow.compute({
            //                 @do f1(1, 2, 3);
            //             });
            //         }));
            //     });

            //     describe("with placeholder", {
            //         it("should pass when it evaluates a function that has no argument", function (done) {
            //             function f1(cb: Void -> Void) {
            //                 cb();
            //             }

            //             CallbackFlow.compute({
            //                 @do f1(_);
            //             }).then(function (_) {
            //                 done();
            //             });
            //         });

            //         it("should pass when it evaluates a function that has some arguments", function (done) {
            //             function f1(cb: Void -> Void, a: Int, b: Int) {
            //                 a.should.be(10);
            //                 b.should.be(20);
            //                 cb();
            //             }

            //             CallbackFlow.compute({
            //                 @do f1(_, 10, 20);
            //             }).then(function (_) {
            //                 done();
            //             });
            //         });

            //         it("should not be able to compile when it is not enough arguments", CompilationShould.failFor({
            //             function f1(cb: Void -> Void, a: Int, b: Int) {
            //                 cb();
            //             }

            //             CallbackFlow.compute({
            //                 @do f1(_, 10);
            //             }).then(function (_) {
            //                 fail();
            //             });
            //         }));

            //         it("should not be able to compile when it is too many arguments", CompilationShould.failFor({
            //             function f1(cb: Void -> Void, a: Int, b: Int) {
            //                 cb();
            //             }

            //             CallbackFlow.compute({
            //                 @do f1(_, 1, 2, 3);
            //             });
            //         }));
            //     });

            //     describe("@var assign", {
            //         it("should pass when it is given (Void -> Void)", function (done) {
            //             function f1(cb: Void -> Void) {
            //                 cb();
            //             }

            //             CallbackFlow.compute({
            //                 @var a = f1();
            //                 a.should.be(new extype.Unit());
            //             }).then(function (_) {
            //                 done();
            //             });
            //         });

            //         it("should pass when it is given (Int -> Void)", function (done) {
            //             function f1(cb: Int -> Void) {
            //                 cb(10);
            //             }

            //             CallbackFlow.compute({
            //                 @var a = f1();
            //                 a.should.be(10);
            //             }).then(function (_) {
            //                 done();
            //             });
            //         });

            //         it("should pass when it is given (Int -> Int -> Void)", function (done) {
            //             function f1(cb: Int -> Int -> Void) {
            //                 cb(10, 20);
            //             }

            //             CallbackFlow.compute({
            //                 @var a = f1();
            //                 a.value1.should.be(10);
            //                 a.value2.should.be(20);
            //             }).then(function (_) {
            //                 done();
            //             });
            //         });
            //     });
            // });

            // describe("return", {
            //     it("should pass", function (done) {
            //         function f1(cb: Int -> Void) {
            //             cb(10);
            //         }

            //         CallbackFlow.compute({
            //             @var a = f1();
            //             return a * 10;
            //         }).then(function (x) {
            //             x.should.be(100);
            //             done();
            //         });
            //     });
            // });

            // describe("@return", {
            //     it("should pass", function (done) {
            //         CallbackFlow.compute({
            //             @return Promise.resolve(10);
            //         }).then(function (x) {
            //             x.should.be(10);
            //             done();
            //         });
            //     });
            // });

            describe("if", {
                it("should pass when it is given true", function (done) {
                    function f1(cb: Bool -> Void) {
                        cb(true);
                    }

                    CallbackFlow.compute({
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
            });

            // while
            // for

            // describe("mixed pattern", {
            //     it("should pass", function (done) {
            //         function f1(cb: Int -> Void) {
            //             cb(10);
            //         }

            //         function f2(cb: Int -> String -> Void) {
            //             cb(20, "hello");
            //         }

            //         CallbackFlow.compute({
            //             @var a = f1();
            //             @var b = f2();
            //             return { value: a + b.value1, message: b.value2 };
            //         }).then(function (x) {
            //             x.value.should.be(30);
            //             x.message.should.be("hello");
            //             done();
            //         });
            //     });

            //     it("should pass when it is nested pattern", function (done) {
            //         function f1(cb: Int -> Void) {
            //             cb(10);
            //         }

            //         function f2(cb: Int -> Void) {
            //             cb(20);
            //         }

            //         CallbackFlow.compute({
            //             @var a = f1();
            //             @return CallbackFlow.compute({
            //                 @var b = f2();
            //                 return a + b;
            //             });
            //         }).then(function (x) {
            //             x.should.be(30);
            //             done();
            //         });
            //     });
            // });
        });

        // describe("CallbackFlow.computeNodeJsStyle()", {
        //     describe("empty expr", {
        //         it("should pass", function (done) {
        //             CallbackFlow.computeNodeJsStyle({}).then(function (_) {
        //                 done();
        //             });
        //         });
        //     });

        //     describe("bind", {
        //         describe("no callback", {
        //             it("should not be able to compile when it evaluates a function that has no argument", CompilationShould.failFor({
        //                 function f1() return 10;

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @do f1();
        //                 });
        //             }));

        //             it("should not be able to compile when it evaluates a function that has some arguments", CompilationShould.failFor({
        //                 function f1(a: Int, b: Int) return a + b;

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @do f1(1, 2);
        //                 });
        //             }));
        //         });

        //         describe("without placeholder", {
        //             it("should pass when it evaluates a function that has no argument", function (done) {
        //                 function f1(cb: Void -> Void) cb();

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @do f1();
        //                 }).then(function (_) {
        //                     done();
        //                 });
        //             });

        //             it("should pass when it evaluates a function that has some arguments", function (done) {
        //                 function f1(a: Int, b: Int, cb: Void -> Void) {
        //                     a.should.be(10);
        //                     b.should.be(20);
        //                     cb();
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @do f1(10, 20);
        //                 }).then(function (_) {
        //                     done();
        //                 });
        //             });

        //             it("should not be able to compile when it is not enough arguments", CompilationShould.failFor({
        //                 function f1(a: Int, b: Int, cb: Void -> Void) {
        //                     cb();
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @do f1(10);
        //                 }).then(function (_) {
        //                     fail();
        //                 });
        //             }));

        //             it("should not be able to compile when it is too many arguments", CompilationShould.failFor({
        //                 function f1(a: Int, b: Int, cb: Void -> Void) {
        //                     cb();
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @do f1(1, 2, 3);
        //                 });
        //             }));
        //         });

        //         describe("with placeholder", {
        //             it("should pass when it evaluates a function that has no argument", function (done) {
        //                 function f1(cb: Void -> Void) {
        //                     cb();
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @do f1(_);
        //                 }).then(function (_) {
        //                     done();
        //                 });
        //             });

        //             it("should pass when it evaluates a function that has some arguments", function (done) {
        //                 function f1(cb: Void -> Void, a: Int, b: Int) {
        //                     a.should.be(10);
        //                     b.should.be(20);
        //                     cb();
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @do f1(_, 10, 20);
        //                 }).then(function (_) {
        //                     done();
        //                 });
        //             });

        //             it("should not be able to compile when it is not enough arguments", CompilationShould.failFor({
        //                 function f1(cb: Void -> Void, a: Int, b: Int) {
        //                     cb();
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @do f1(_, 10);
        //                 }).then(function (_) {
        //                     fail();
        //                 });
        //             }));

        //             it("should not be able to compile when it is too many arguments", CompilationShould.failFor({
        //                 function f1(cb: Void -> Void, a: Int, b: Int) {
        //                     cb();
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @do f1(_, 1, 2, 3);
        //                 });
        //             }));
        //         });

        //         describe("@var assign", {
        //             it("should pass when it is given (Void -> Void)", function (done) {
        //                 function f1(cb: Void -> Void) {
        //                     cb();
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @var a = f1();
        //                     a.should.be(new extype.Unit());
        //                 }).then(function (_) {
        //                     done();
        //                 });
        //             });

        //             it("should pass when it is given (\"error\" -> Void)", function (done) {
        //                 function f1(cb: Null<String> -> Void) {
        //                     cb("error");
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @var a = f1();
        //                 }).then(function (_) {
        //                     fail();
        //                 }, function (e) {
        //                     (e: String).should.be("error");
        //                     done();
        //                 });
        //             });

        //             it("should pass when it is given (null -> Void)", function (done) {
        //                 function f1(cb: Null<String> -> Void) {
        //                     cb(null);
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @var a = f1();
        //                     a.should.be(new extype.Unit());
        //                 }).then(function (_) {
        //                     done();
        //                 });
        //             });

        //             it("should pass when it is given (\"error\" -> Int -> Void)", function (done) {
        //                 function f1(cb: Null<String> -> Int -> Void) {
        //                     cb("error", 20);
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @var a = f1();
        //                 }).then(function (_) {
        //                     fail();
        //                 }, function (e) {
        //                     (e: String).should.be("error");
        //                     done();
        //                 });
        //             });

        //             it("should pass when it is given (null -> Int -> Void)", function (done) {
        //                 function f1(cb: Null<String> -> Int -> Void) {
        //                     cb(null, 10);
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @var a = f1();
        //                     a.should.be(10);
        //                 }).then(function (_) {
        //                     done();
        //                 });
        //             });

        //             it("should pass when it is given (\"error\" -> Int -> Int -> Void)", function (done) {
        //                 function f1(cb: Null<String> -> Int -> Int -> Void) {
        //                     cb("error", 10, 20);
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @var a = f1();
        //                 }).then(function (_) {
        //                     fail();
        //                 }, function (e) {
        //                     (e: String).should.be("error");
        //                     done();
        //                 });
        //             });

        //             it("should pass when it is given (null -> Int -> Int -> Void)", function (done) {
        //                 function f1(cb: Null<String> -> Int -> Int -> Void) {
        //                     cb(null, 10, 20);
        //                 }

        //                 CallbackFlow.computeNodeJsStyle({
        //                     @var a = f1();
        //                     a.value1.should.be(10);
        //                     a.value2.should.be(20);
        //                 }).then(function (_) {
        //                     done();
        //                 });
        //             });
        //         });
        //     });

        //     describe("return", {
        //         it("should pass", function (done) {
        //             function f1(cb: Null<String> -> Int -> Void) {
        //                 cb(null, 10);
        //             }

        //             CallbackFlow.computeNodeJsStyle({
        //                 @var a = f1();
        //                 return a * 10;
        //             }).then(function (x) {
        //                 x.should.be(100);
        //                 done();
        //             });
        //         });
        //     });

        //     describe("@return", {
        //         it("should pass", function (done) {
        //             CallbackFlow.computeNodeJsStyle({
        //                 @return Promise.resolve(10);
        //             }).then(function (x) {
        //                 x.should.be(10);
        //                 done();
        //             });
        //         });
        //     });

        //     // describe("mixed pattern", {
        //     //     it("should pass", function (done) {
        //     //         function f1(cb: Int -> Void) {
        //     //             cb(10);
        //     //         }

        //     //         function f2(cb: Int -> String -> Void) {
        //     //             cb(20, "hello");
        //     //         }

        //     //         CallbackFlow.compute({
        //     //             @var a = f1();
        //     //             @var b = f2();
        //     //             return { value: a + b.value1, message: b.value2 };
        //     //         }).then(function (x) {
        //     //             x.value.should.be(30);
        //     //             x.message.should.be("hello");
        //     //             done();
        //     //         });
        //     //     });

        //     //     it("should pass when it is nested pattern", function (done) {
        //     //         function f1(cb: Int -> Void) {
        //     //             cb(10);
        //     //         }

        //     //         function f2(cb: Int -> Void) {
        //     //             cb(20);
        //     //         }

        //     //         CallbackFlow.compute({
        //     //             @var a = f1();
        //     //             @return CallbackFlow.compute({
        //     //                 @var b = f2();
        //     //                 return a + b;
        //     //             });
        //     //         }).then(function (x) {
        //     //             x.should.be(30);
        //     //             done();
        //     //         });
        //     //     });
        //     // });
        // });
    }
}