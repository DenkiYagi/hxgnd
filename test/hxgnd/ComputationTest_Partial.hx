package hxgnd;

import hxgnd.Computation;
import haxe.macro.Expr;

class ComputationTest_no_transform {
    public static macro function perform_empty_eblock(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {});
    }

    public static macro function perform_const_eblock(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            1;
        });
    }

    public static macro function perform_expr_eblock(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            1 + 2;
        });
    }

    public static macro function perform_done(done: Expr): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) {
                return macro haxe.Timer.delay(function () {
                    ${fn}(${expr} * 10);
                }, 0);
            },
            buildReturn: function (expr: Expr) return expr
        }, macro {
            ${done}();
        });
    }
}

class ComputationTest_EVars_transform_without_EMeta {
    public static macro function perform_single_var(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var a = 1;
        });
    }

    public static macro function perform_multi_var(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var a = 1, b = 2;
        });
    }

    public static macro function perform_single_var_return(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var a = 1;
            a;
        });
    }

    public static macro function perform_multi_var_return(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var a = 1, b = 2;
            return a + b;
        });
    }
}

class ComputationTest_EVars_transform_with_EMeta {
    public static macro function perform_single_var(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var a = @let 1;
        });
    }

    public static macro function perform_multi_var(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var a = @let 1, b = 2;
        });
    }

    public static macro function perform_single_var_return(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var a = @let 1;
            a;
        });
    }

    public static macro function perform_multi_var_return_1(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var a = @let 1, b = 2;
            return a + b;
        });
    }

    public static macro function perform_multi_var_return_2(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var a = @let 1, b = @let 2;
            return a + b;
        });
    }

    public static macro function perform_multi_var_return_3(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var a = @let 1;
            var b = @let 2;
            return a + b;
        });
    }

    public static macro function perform_single_var_return_foo(): Expr {
        return Computation.perform({
            keyword: "foo",
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr
        }, macro {
            var  a = @let 1;
            a;
        });
    }
}

class ComputationTest_EMeta_transform {
    public static macro function perform_single(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return macro function (fn) fn(${expr})
        }, macro {
            @let 1;
        });
    }

    public static macro function perform_multi(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return macro function (fn) fn(${expr})
        }, macro {
            @let 1;
            @let 2;
        });
    }

    public static macro function perform_done(done: Expr): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) {
                return macro haxe.Timer.delay(function () {
                    ${fn}(${expr} * 10);
                }, 0);
            },
            buildReturn: function (expr: Expr) return expr
        }, macro {
            @let 1;
            ${done}();
        });
    }

    public static macro function perform_done_foo(done: Expr): Expr {
        return Computation.perform({
            keyword: "foo",
            buildBind: function (expr: Expr, fn: Expr) {
                return macro haxe.Timer.delay(function () {
                    ${fn}(${expr} * 10);
                }, 0);
            },
            buildReturn: function (expr: Expr) return expr
        }, macro {
            @foo 1;
            ${done}();
        });
    }
}
