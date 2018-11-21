package hxgnd;

import hxgnd.Computation;
import haxe.macro.Expr;
import haxe.ds.Option;
import haxe.ds.Either;
using hxgnd.OptionTools;
using haxe.macro.ExprTools;

/**
 * {| other-expr |}
 */
class ComputationTest_other_expr {
    public static macro function perform_empty_expr(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro fn(${m} + 10),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0
        }, macro {});
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_single_var(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro fn(${m} + 10),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0
        }, macro {
            var a = 1;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_multiple_var(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro fn(${m} + 10),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0
        }, macro {
            var a = 1, b = 2;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_op(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro fn(${m} + 10),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0
        }, macro {
            1 + 2;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_call(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro fn(${m} + 10),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0
        }, macro {
            (function () 1 + 2)();
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * {| return expr |}
 */
class ComputationTest_return {
    public static macro function perform_value(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            return 1;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_void(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            return;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * {| @return expr |}
 */
class ComputationTest_returnFrom {
    public static macro function perform_some(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @return Some(1);
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_none(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @return None;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * {| @var ident = expr_in_cexpr |}
 */
class ComputationTest_bind {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_multiple(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = Some(2);
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_1(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            return a;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_2(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = None;
            return a;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_multiple_return_1(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = Some(2);
            return a + b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_multiple_return_2(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = None;
            return a + b;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * {| @do expr_in_cexpr |}
 */
class ComputationTest_do {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @do Some(1);
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_multiple(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @do Some(1);
            @do Some(2);
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_1(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @do Some(1);
            return 10;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_2(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @do None;
            return 10;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_multiple_return_1(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @do Some(1);
            @do Some(2);
            return 10;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_multiple_return_2(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @do Some(1);
            @do None;
            return 10;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * {| if (expr) cexpr1 |}"
 */
class ComputationTest_if {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 0;
            if (a == 0) {
                a++;
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = true;
            if (a) return 1;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = false;
            if (a) return 1;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_assign_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 1;
            var b = if (a > 0) {
                a = a + 1;
                // b.Zero();
            }
            @return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_assign_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 0;
            var b = if (a > 0) {
                a = a + 1;
            }
            @return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = if (a > 0) {
                return a + 1;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = if (a <= 0) {
                return a + 1;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_nested(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = if (a > 0) {
                @var x = Some(2);
                return a + x;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * {| if (expr) cexpr1 else cexpr2 |}
 */
class ComputationTest_if_else {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 0;
            if (a == 0) {
                a++;
            } else {
                -1;
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = true;
            if (a) {
                return 1;
            } else {
                return -1;
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = false;
            if (a) {
                return 1;
            } else {
                return -1;
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_assign_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 1;
            var b = if (a > 0) {
                a + 1;
            } else {
                a - 1;
            }
            @return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_assign_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 0;
            var b = if (a > 0) {
                a + 1;
            } else {
                a - 1;
            }
            @return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = if (a > 0) {
                return a + 1;
            } else {
                return a - 1;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = if (a > 10) {
                return a + 1;
            } else {
                return a - 1;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_nested_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = if (a > 0) {
                @var x = Some(2);
                return a + x;
            } else {
                @var x = Some(3);
                return a - x;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_nested_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = if (a > 10) {
                @var x = Some(2);
                return a + x;
            } else {
                @var x = Some(3);
                return a - x;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * {| (expr) ? cexpr1 : cexpr2 |}
 */
class ComputationTest_ternary {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 0;
            (a == 0) ? a++ : -1;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = true;
            (a) ? return 1 : return -1;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = false;
            (a) ? return 1 : return -1;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_assign_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 1;
            var b = (a > 0)
                ? a + 1
                : a - 1;
            @return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_assign_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 0;
            var b = (a > 0)
                ? a + 1
                : a - 1;
            @return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = (a > 0)
                ? return a + 1
                : return a - 1;
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = (a > 10)
                ? return a + 1
                : return a - 1;
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_nested_true(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = (a > 0)
                ? {
                    @var x = Some(2);
                    return a + x;
                }
                : {
                    @var x = Some(3);
                    return a - x;
                };
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_nested_false(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = (a > 10)
                ? {
                    @var x = Some(2);
                    return a + x;
                }
                : {
                    @var x = Some(3);
                    return a - x;
                };
            return b;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * switch (expr) { case pattern: cexpr }
 */
class ComputationTest_switch {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = haxe.ds.Either.Left(1);
            switch (a) {
                case haxe.ds.Either.Left(_): "left";
                case haxe.ds.Either.Right(_): "right";
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_left(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = haxe.ds.Either.Left(1);
            switch (a) {
                case haxe.ds.Either.Left(_): return "left";
                case haxe.ds.Either.Right(_): return "right";
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_right(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = haxe.ds.Either.Right(1);
            switch (a) {
                case haxe.ds.Either.Left(_): return "left";
                case haxe.ds.Either.Right(_): return "right";
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_left(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(haxe.ds.Either.Left(1));
            @var b = switch (a) {
                case haxe.ds.Either.Left(i):
                    @var x = Some(2);
                    return i + x;
                case haxe.ds.Either.Right(_):
                    return -1;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_right(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(haxe.ds.Either.Right(1));
            @var b = switch (a) {
                case haxe.ds.Either.Left(i):
                    @var x = Some(2);
                    return i + x;
                case haxe.ds.Either.Right(_):
                    return -1;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * switch (expr) { case pattern: cexpr; default: cexpr; }
 */
class ComputationTest_switch_default {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 1;
            switch (a) {
                case 1: "1st";
                case 2: "2nd";
                default: "default";
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_1st(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 1;
            switch (a) {
                case 1: return "1st";
                case 2: return "2nd";
                default: return "default";
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_2nd(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = 2;
            switch (a) {
                case 1: return "1st";
                case 2: return "2nd";
                default: return "default";
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_return_default(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            var a = -1;
            switch (a) {
                case 1: return "1st";
                case 2: return "2nd";
                default: return "default";
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_1st(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(1);
            @var b = switch (a) {
                case 1:
                    @var x = Some(2);
                    return a + x;
                case 2:
                    return -2;
                default:
                    return 0;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_2nd(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(2);
            @var b = switch (a) {
                case 1:
                    @var x = Some(2);
                    return a + x;
                case 2:
                    return -2;
                default:
                    return 0;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_default(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro OptionTools.flatMap(${m}, ${fn}),
            buildReturn: function (value) return macro Some(${value}),
            buildZero: function () return macro None
        }, macro {
            @var a = Some(3);
            @var b = switch (a) {
                case 1:
                    @var x = Some(2);
                    return a + x;
                case 2:
                    return -2;
                default:
                    return 0;
            }
            return b;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * {| while (cond) cepr |}
 */
class ComputationTest_while {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
            buildWhile: function (cond, body) {
                return macro function _while(cond, body) {
                    return if (cond()) {
                        var x = body();
                        _while(cond, body);
                        x;
                    } else {
                        0;
                    }
                }(${cond}, ${body});
            },
        }, macro {
            var i = 0;
            while (i < 3) {
                i++;
            }
            return i;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_no_builder(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro fn(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
        }, macro {
            var i = 0;
            while (i < 3) { //remove expr
                i++;
            }
            return i;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * {| for (cond) expr |}
 */
class ComputationTest_for {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
            buildFor: function (iter, body) {
                return macro function _for(iter, body) {
                    return if (iter.hasNext()) {
                        var x = body(iter.next());
                        _for(iter, body);
                        x;
                    } else {
                        0;
                    }
                }(${iter}, ${body});
            },
        }, macro {
            var x = 0;
            for (i in 0...4) {
                x += i;
            }
            return x;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_no_builder(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
        }, macro {
            var x = 0;
            for (i in 0...3) {
                x += i;
            }
            return x;
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * {| try cexpr catch (e) expr |}
 */
class ComputationTest_try {
    public static macro function perform(): Expr {
        var _bind = function (m, fn) return macro ${fn}(${m});
        var expr = Computation.perform({
            buildBind: _bind,
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
        }, macro {
            try {
            } catch (e: Dynamic) {
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_return(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
        }, macro {
            try {
                return 10;
            } catch (e: Dynamic) {
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_return_throw(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
        }, macro {
            try {
                throw "error";
            } catch (e: Dynamic) {
                return -1;
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
        }, macro {
            try {
                @var a = 1;
                return a + 10;
            } catch (e: Dynamic) {
            }
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_with_bind_throw(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
        }, macro {
            function throwError(): Int {
                throw "error";
            }

            try {
                @var a = 1;
                return throwError();
            } catch (e: Dynamic) {
                return -1;
            }
        });
        // trace(expr.toString());
        return expr;
    }
}

/**
 * builder.buildRun()
 */
class ComputationTest_buildRun {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
            buildRun: function (fn) return macro ${fn}() + 10,
        }, macro {
            return 1;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_default(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
        }, macro {
            return 1;
        });
        // trace(expr.toString());
        return expr;
    }
}

class ComputationTest_buildDelay {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
            buildDelay: function (fn) return macro function () return ${fn}() + 5,
        }, macro {
            return 1;
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_default(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
        }, macro {
            return 1;
        });
        // trace(expr.toString());
        return expr;
    }
}


class ComputationTest_buildCombine {
    public static macro function perform(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
            buildWhile: function (cond, body) {
                return macro function sum(acc, cond, body) {
                    return if (cond()) {
                        var x = acc + body();
                        sum(x, cond, body);
                    } else {
                        acc;
                    }
                }(0, ${cond}, ${body});
            },
            buildCombine: function (expr1, expr2) return macro ${expr1} * ${expr2},
        }, macro {
            return {
                var i = 0;
                var j = 0;
                @return {
                    while (i < 5) { //10
                        return i++;
                    }
                    while (j < 4) { //6
                        return j++;
                    }
                }
            };
        });
        // trace(expr.toString());
        return expr;
    }

    public static macro function perform_default(): Expr {
        var expr = Computation.perform({
            buildBind: function (m, fn) return macro ${fn}(${m}),
            buildReturn: function (value) return value,
            buildZero: function () return macro 0,
            buildWhile: function (cond, body) {
                return macro function sum(acc, cond, body) {
                    return if (cond()) {
                        var x = acc + body();
                        sum(x, cond, body);
                    } else {
                        acc;
                    }
                }(0, ${cond}, ${body});
            },
        }, macro {
            return {
                var i = 0;
                var j = 0;
                @return {
                    while (i < 5) { //10
                        return i++;
                    }
                    while (j < 4) { //6
                        return j++;
                    }
                }
            };
        });
        // trace(expr.toString());
        return expr;
    }
}
