package hxgnd;

import buddy.BuddySuite;
using buddy.Should;
import hxgnd.ComputationTest_Partial;
import haxe.ds.Option;

class ComputationTest extends BuddySuite {
    public function new() {
        describe("Computation#perform()", {
            describe("{| other-expr |}", {
                it("should pass when it is given {}", {
                    ComputationTest_other_expr.perform_empty_expr().should.be(0);
                });

                it("should pass when it is given { var a = 1; }", {
                    ComputationTest_other_expr.perform_single_var().should.be(0);
                });

                it("should pass when it is given { var a = 1, b = 2; }", {
                    ComputationTest_other_expr.perform_multiple_var().should.be(0);
                });

                it("should pass when it is given { 1 + 2; }", {
                    ComputationTest_other_expr.perform_op().should.be(0);
                });

                it("should pass when it is given { (function () 1 + 2)(); }", {
                    ComputationTest_other_expr.perform_call().should.be(0);
                });
            });

            describe("return", {
                it("should pass when it is given { return 1; }", {
                    ComputationTest_return.perform_value().should.equal(Some(1));
                });

                it("should pass when it is given { return; }", {
                    ComputationTest_return.perform_void().should.equal(None);
                });
            });

            describe("@return", {
                it("should pass when it is given { @return Some(1); }", {
                    ComputationTest_returnFrom.perform_some().should.equal(Some(1));
                });

                it("should pass when it is given { @return None; }", {
                    ComputationTest_returnFrom.perform_none().should.equal(None);
                });
            });

            describe("@var", {
                it("should pass when it is given { @var a = Some(1); }", {
                    ComputationTest_bind.perform().should.equal(None);
                });

                it("should pass when it is given { @var a = Some(1); @var b = Some(2); }", {
                    ComputationTest_bind.perform_multiple().should.equal(None);
                });

                describe("+ return", {
                    it("should pass when it is given { @var a = Some(1); return a; }", {
                        ComputationTest_bind.perform_return_1().should.equal(Some(1));
                    });

                    it("should pass when it is given { @var a = None; return a; }", {
                        ComputationTest_bind.perform_return_2().should.equal(None);
                    });

                    it("should pass when it is given { @var a = Some(1); @var b = Some(2); return a + b; }", {
                        ComputationTest_bind.perform_multiple_return_1().should.equal(Some(3));
                    });

                    it("should pass when it is given { @var a = Some(1); @var b = None; return a + b; }", {
                        ComputationTest_bind.perform_multiple_return_2().should.equal(None);
                    });
                });
            });

            describe("@do", {
                it("should pass when it is given { @do Some(1); }", {
                    ComputationTest_do.perform().should.equal(None);
                });

                it("should pass when it is given { @do Some(1); @do Some(2); }", {
                    ComputationTest_do.perform_multiple().should.equal(None);
                });

                describe("+ return", {
                    it("should pass when it is given { @do Some(1); return 10; }", {
                        ComputationTest_do.perform_return_1().should.equal(Some(10));
                    });

                    it("should pass when it is given { @do None; return 10; }", {
                        ComputationTest_do.perform_return_2().should.equal(None);
                    });

                    it("should pass when it is given { @do Some(1); @do Some(2); return 10; }", {
                        ComputationTest_do.perform_multiple_return_1().should.equal(Some(10));
                    });

                    it("should pass when it is given { @do Some(1); @do None; return 10; }", {
                        ComputationTest_do.perform_multiple_return_2().should.equal(None);
                    });
                });
            });

            describe("{| { cexpr } |}", {
                it("should pass when it is given { @return { return 1; } }", {
                    ComputationTest_block.perform_with_return().should.equal(Some(1));
                });

                it("should pass when it is given { @return { 1 } }", {
                    ComputationTest_block.perform_without_return().should.equal(None);
                });
            });

            describe("{| if (cond) cexpr1 |}", {
                it("should pass when it is given { var a = 0; if (a == 0) { a++; } }", {
                    ComputationTest_if.perform().should.equal(None);
                });

                describe("+ return", {
                    it("should pass when it is given { var a = true; if (a) { return 1; } }", {
                        ComputationTest_if.perform_return_true().should.equal(Some(1));
                    });

                    it("should pass when it is given { var a = false; if (a) { return 1; } }", {
                        ComputationTest_if.perform_return_false().should.equal(None);
                    });
                });

                describe("+ var + @return", {
                    it("should pass when cond = true", {
                        ComputationTest_if.perform_with_assign_true().should.equal(None);
                    });

                    it("should pass when cond = false", {
                        ComputationTest_if.perform_with_assign_false().should.equal(None);
                    });
                });

                describe("+ @var + return", {
                    it("should pass when cond = true", {
                        ComputationTest_if.perform_with_bind_true().should.equal(Some(3));
                    });

                    it("should pass when cond = false", {
                        ComputationTest_if.perform_with_bind_false().should.equal(None);
                    });

                    it("should pass when it has @var in if_expr", {
                        ComputationTest_if.perform_with_bind_nested().should.equal(Some(4));
                    });
                });
            });

            describe("{| if (cond) cexpr1 else cexpr2 |}", {
                it("should pass when it is given { var a = 0; if (a == 0) { a++; } }", {
                    ComputationTest_if_else.perform().should.equal(None);
                });

                describe("+ return", {
                    it("should pass when it is given { var a = true; if (a) { return 1; } else { return -1: } }", {
                        ComputationTest_if_else.perform_return_true().should.equal(Some(1));
                    });

                    it("should pass when it is given { var a = false; if (a) { return 1; } else { return -1: } }", {
                        ComputationTest_if_else.perform_return_false().should.equal(Some(-1));
                    });
                });

                describe("+ var + @return", {
                    it("should pass when cond = true", {
                        ComputationTest_if_else.perform_with_assign_true().should.equal(None);
                    });

                    it("should pass when cond = false", {
                        ComputationTest_if_else.perform_with_assign_false().should.equal(None);
                    });
                });

                describe("+ @var + return", {
                    it("should pass when cond = true", {
                        ComputationTest_if_else.perform_with_bind_true().should.equal(Some(3));
                    });

                    it("should pass when cond = false", {
                        ComputationTest_if_else.perform_with_bind_false().should.equal(Some(0));
                    });

                    it("should pass when it has @var in if_expr", {
                        ComputationTest_if_else.perform_with_bind_nested_true().should.equal(Some(4));
                    });

                    it("should pass when it has @var in else_expr", {
                        ComputationTest_if_else.perform_with_bind_nested_false().should.equal(Some(-1));
                    });
                });
            });

            describe("{| cond ? cexpr1 : cexpr2; |}", {
                it("should pass when it is given { var a = 0; if (a == 0) { a++; } }", {
                    ComputationTest_ternary.perform().should.equal(None);
                });

                describe("+ return", {
                    it("should pass when it is given { var a = true; if (a) { return 1; } else { return -1: } }", {
                        ComputationTest_ternary.perform_return_true().should.equal(Some(1));
                    });

                    it("should pass when it is given { var a = false; if (a) { return 1; } else { return -1: } }", {
                        ComputationTest_ternary.perform_return_false().should.equal(Some(-1));
                    });
                });

                describe("+ var + @return", {
                    it("should pass when cond = true", {
                        ComputationTest_ternary.perform_with_assign_true().should.equal(None);
                    });

                    it("should pass when cond = false", {
                        ComputationTest_ternary.perform_with_assign_false().should.equal(None);
                    });
                });

                describe("+ @var + return", {
                    it("should pass when cond = true", {
                        ComputationTest_ternary.perform_with_bind_true().should.equal(Some(2));
                    });

                    it("should pass when cond = false", {
                        ComputationTest_ternary.perform_with_bind_false().should.equal(Some(0));
                    });

                    it("should pass when it has @var in if_expr", {
                        ComputationTest_ternary.perform_with_bind_nested_true().should.equal(Some(3));
                    });

                    it("should pass when it has @var in else_expr", {
                        ComputationTest_ternary.perform_with_bind_nested_false().should.equal(Some(-2));
                    });
                });
            });

            // switch
            describe("{| switch (expr) { case pattern: cexpr } |}", {
                it("should pass when it is given { var a = Left(1); switch (a) { case Left(_): 'left'; case Right(_): 'right'; } }", {
                    ComputationTest_switch.perform().should.equal(None);
                });

                it("should pass when it is given { var a = Left(1); switch (a) { case Left(_): return 'left'; case Right(_): return 'right'; } }", {
                    ComputationTest_switch.perform_return_left().should.equal(Some("left"));
                });

                it("should pass when it is given { var a = Right(1); switch (a) { case Left(_): return 'left'; case Right(_): return 'right'; } }", {
                    ComputationTest_switch.perform_return_right().should.equal(Some("right"));
                });

                describe("+ @var + return", {
                    it("should pass when cond = Left", {
                        ComputationTest_switch.perform_with_bind_left().should.equal(Some(3));
                    });

                    it("should pass when cond = Right", {
                        ComputationTest_switch.perform_with_bind_right().should.equal(Some(-1));
                    });
                });
            });

            describe("{| switch (expr) { case pattern: cexpr; default: cexpr; } |}", {
                it("should pass when it is given { var a = 1; switch (a) { case 1: '1st'; case 2: '2nd'; default: 'default' } }", {
                    ComputationTest_switch_default.perform().should.equal(None);
                });

                it("should pass when it is given { var a = 1; switch (a) { case 1: return '1st'; case 2: 'return 2nd'; default: return 'default' } }", {
                    ComputationTest_switch_default.perform_return_1st().should.equal(Some("1st"));
                });

                it("should pass when it is given { var a = 2; switch (a) { case 1: return '1st'; case 2: 'return 2nd'; default: return 'default' } }", {
                    ComputationTest_switch_default.perform_return_2nd().should.equal(Some("2nd"));
                });

                it("should pass when it is given { var a = 2; switch (a) { case 1: return '1st'; case 2: 'return 2nd'; default: return 'default' } }", {
                    ComputationTest_switch_default.perform_return_default().should.equal(Some("default"));
                });

                describe("+ @var + return", {
                    it("should pass when cond = 1st", {
                        ComputationTest_switch_default.perform_with_bind_1st().should.equal(Some(3));
                    });

                    it("should pass when cond = 2ne", {
                        ComputationTest_switch_default.perform_with_bind_2nd().should.equal(Some(-2));
                    });

                    it("should pass when cond = default", {
                        ComputationTest_switch_default.perform_with_bind_default().should.equal(Some(0));
                    });
                });
            });

            // describe("{| while (cond) expr |}", {
            //     it("should pass", {
            //         ComputationTest_while.perform().should.equal(Some(3));
            //     });

            //     it("should not evaluate expr when it doesn't have buildWhile", {
            //         ComputationTest_while.perform_no_builder().should.equal(Some(0));
            //     });

            //     it("should pass when it has @var inside while", {
            //         ComputationTest_while.perform_inside_bind().should.equal(Some(6));
            //     });
            // });

            // describe("{| for (cond) expr |}", {
            //     it("should pass", {
            //         ComputationTest_for.perform().should.equal(Some(6));
            //     });

            //     it("should not evaluate expr when it doesn't have buildFor", {
            //         ComputationTest_for.perform_no_builder().should.equal(Some(0));
            //     });

            //     it("should pass when it has @var inside while", {
            //         ComputationTest_for.perform_inside_bind().should.equal(Some(6));
            //     });
            // });

            describe("{| try cexpr catch (e) expr |}", {
                it("should pass", {
                    ComputationTest_try.perform().should.be(0);
                });

                describe("return", {
                    it("should pass when it doesn't throw error", {
                        ComputationTest_try.perform_with_return().should.be(10);
                    });

                    it("should pass when it throws error", {
                        ComputationTest_try.perform_with_return_throw().should.be(-1);
                    });
                });

                describe("+ @var + return", {
                    it("should pass when it doesn't throw error", {
                        ComputationTest_try.perform_with_bind().should.be(11);
                    });

                    it("should pass when it throws error", {
                        ComputationTest_try.perform_with_bind_throw().should.be(-1);
                    });
                });
            });

            describe("builder.buildRun()", {
                it("should pass", {
                    ComputationTest_buildRun.perform().should.be(11);
                });

                it("should pass when it doesn't have buildRun", {
                    ComputationTest_buildRun.perform_default().should.be(1);
                });
            });

            describe("builder.delay()", {
                it("should pass", {
                    ComputationTest_buildDelay.perform().should.be(6);
                });

                it("should pass when it doesn't have buildDelay", {
                    ComputationTest_buildDelay.perform_default().should.be(1);
                });
            });

            // describe("builder.combine()", {
            //     it("should pass", {
            //         ComputationTest_buildCombine.perform().should.be(60);
            //     });

            //     it("should pass when it doesn't have buildCombine", {
            //         ComputationTest_buildCombine.perform_default().should.be(6);
            //     });

            //     it("should pass when it has post expr", {
            //         ComputationTest_buildCombine.perform_with_post_expr().should.be(3);
            //     });
            // });
        });
    }
}
