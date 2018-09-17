package hxgnd;

import buddy.BuddySuite;
using buddy.Should;
import hxgnd.ComputationTest_Partial;

class ComputationTest extends BuddySuite {
    public function new() {
        describe("Computation#perform()", {
            describe("No transformation", {
                it("should pass when it is given { 1 } ", {
                    ComputationTest_no_transform.perform_const_eblock()
                        .should.be(1);
                });

                it("should pass when it is given { 1 + 2 }", {
                    ComputationTest_no_transform.perform_expr_eblock()
                        .should.be(3);
                });

                it("should pass when it is given { done() }", function (done) {
                    ComputationTest_no_transform.perform_done(done);
                });
            });

            describe("Zero transformation", {
                it("should pass when it is given {}", {
                    ComputationTest_zero_transform.perform_empty_eblock().should.be(0);
                });


                it("should pass when it is given { for (i in 0...0) {} }", {
                    ComputationTest_zero_transform.perform_efor().should.be(0);
                });

                it("should pass when it is given { while (false) {} }", {
                    ComputationTest_zero_transform.perform_ewhile().should.be(0);
                });

                // it("should pass when it is given { try { var a = 1; } catch (e: Dynamic) { } }", {
                // });
            });

            describe("EVars transformation", {
                describe("widthout EMeta", {
                    it("should pass when it is given { var a = 1; }", {
                        ComputationTest_EVars_transform_without_EMeta.perform_single_var().should.be(0);
                    });

                    it("should pass when it is given { var a = 1, b = 2; }", {
                        ComputationTest_EVars_transform_without_EMeta.perform_multi_var().should.be(0);
                    });

                    it("should pass when it is given { var a = 1; a; }", {
                        ComputationTest_EVars_transform_without_EMeta.perform_single_var_return()
                            .should.be(1);
                    });

                    it("should pass when it is given { var a = 1, b = 2; a + b; }", {
                        ComputationTest_EVars_transform_without_EMeta.perform_multi_var_return()
                            .should.be(3);
                    });
                });

                describe("with EMeta", {
                    it("should pass when it is given { var a = @let 1; }", {
                        ComputationTest_EVars_transform_with_EMeta.perform_single_var();
                    });

                    it("should pass when it is given { var a = @let 1, b = 2; }", function () {
                        ComputationTest_EVars_transform_with_EMeta.perform_multi_var();
                    });

                    it("should pass when it is given { var a = @let 1; a; }", {
                        ComputationTest_EVars_transform_with_EMeta.perform_single_var_return()
                            .should.be(10);
                    });

                    it("should pass when it is given { var a = @let 1, b = 2; a + b; }", {
                        ComputationTest_EVars_transform_with_EMeta.perform_multi_var_return_1()
                            .should.be(12);
                    });

                    it("should pass when it is given { var a = @let 1, b = @let 2; a + b; }", {
                        ComputationTest_EVars_transform_with_EMeta.perform_multi_var_return_2()
                            .should.be(30);
                    });

                    it("should pass when it is given { var a = @let 1; var b = @let 2; a + b; }", {
                        ComputationTest_EVars_transform_with_EMeta.perform_multi_var_return_3()
                            .should.be(30);
                    });

                    it("should pass when it is changed keyword and it is given { var a = @foo 1; a; }", {
                        ComputationTest_EVars_transform_with_EMeta.perform_single_var_return_foo().should.be(10);
                    });
                });
            });

            describe("EMeta transformation", {
                it("should pass when it is given { @let 1; }", {
                    ComputationTest_EMeta_transform.perform_single();
                });

                it("should pass when it is given { @let 1; @let2 }", {
                    ComputationTest_EMeta_transform.perform_multi();
                });

                it("should pass when it is given { @let 1; done(); }", function (done) {
                    ComputationTest_EMeta_transform.perform_done(done);
                });

                it("should pass when it is changed keyword and it is given { @foo 1; done(); }", function (done) {
                    ComputationTest_EMeta_transform.perform_done_foo(done);
                });
            });

            describe("nest", {
                it("should pass", {
                    ComputationTest_nested_transform.perform().should.be(122);
                });
            });
        });
    }
}
