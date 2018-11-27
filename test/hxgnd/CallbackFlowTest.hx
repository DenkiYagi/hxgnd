package hxgnd;

import buddy.BuddySuite;
import buddy.CompilationShould;
using buddy.Should;

class CallbackFlowTest extends BuddySuite {
    public function new() {
        timeoutMs = 100;

        describe("CallbackFlow.compute()", {
            describe("starndard style", {
                describe("empty expr", {
                    it("should pass", function (done) {
                        CallbackFlow.compute({}).then(function (_) {
                            done();
                        });
                    });
                });

                describe("bind", {
                    describe("no callback", {
                        it("should not be able to compile when it is given a no argument function", CompilationShould.failFor({
                            function f1() return 10;

                            CallbackFlow.compute({
                                @var a = f1();
                            });
                        }));

                        it("should not be able to compile when it is given some arguments function", CompilationShould.failFor({
                            function f1(a: Int, b: Int) return a + b;

                            CallbackFlow.compute({
                                @var a = f1(1, 2);
                            });
                        }));
                    });

                    describe("Void -> Void callback", {
                        describe("without placeholder", {
                            it("should pass", function (done) {
                                function f1(cb: Void -> Void) cb();

                                CallbackFlow.compute({
                                    @var a = f1();
                                    return a;
                                }).then(function (_) {
                                    done();
                                });
                            });

                            it("should pass", function (done) {
                                function f1(a: Int, b: Int, cb: Void -> Void) {
                                    a.should.be(10);
                                    b.should.be(20);
                                    cb();
                                }

                                CallbackFlow.compute({
                                    @do f1(10, 20);
                                }).then(function (_) {
                                    done();
                                });
                            });
                        });

                        // 引数不足

                        // 引数多い

                        describe("with placeholder", {
                            it("should pass", function (done) {
                                function f1(cb: Void -> Void) {
                                    cb();
                                }

                                CallbackFlow.compute({
                                    @do f1(_);
                                }).then(function (_) {
                                    done();
                                });
                            });

                            it("should pass", function (done) {
                                function f1(cb: Void -> Void, a: Int) {
                                    a.should.be(10);
                                    cb();
                                }

                                CallbackFlow.compute({
                                    @do f1(_, 10);
                                }).then(function (_) {
                                    done();
                                });
                            });
                        });

                    });
                });

            });

            describe("NodeJs style", {
            });
        });
    }
}