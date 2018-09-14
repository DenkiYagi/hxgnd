package hxgnd;

import TestTools.wait;
import hxgnd.Computation;
import buddy.BuddySuite;
import buddy.CompilationShould;
using buddy.Should;
import haxe.macro.Expr;
import hxgnd.ComputationTest_Partial;

class ComputationTest extends BuddySuite {
    public function new() {
        describe("No transformation", {
            it("should pass when it is given {}", {
                ComputationTest_no_transform.perform_empty_eblock();
            });

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

        describe("EVars transformation", {
            describe("widthout EMeta", {
                it("should pass when it is given { var a = 1; }", {
                    ComputationTest_EVars_transform_without_EMeta.perform_single_var();
                });

                it("should pass when it is given { var a = 1, b = 2; }", {
                    ComputationTest_EVars_transform_without_EMeta.perform_multi_var();
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

                // it("should pass when it is given { var a = 1; expr; }", function (done) {
                //     ComputationTest_EVars_transform_with_EMeta.perform_expr({
                //         var a = 1;
                //         a.should.be(1);
                //         done();
                //     });
                // });
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

            // meta action
            // { @await 1 + @await 2 } が変換できるけど、特に何も起きない
        });
    }
}
