package hxgnd;

import hxgnd.Computation;
import haxe.macro.Expr;

class ComputationTest_no_transform {
    public static macro function perform_const_eblock(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            1;
        });
    }

    public static macro function perform_expr_eblock(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            1 + 2;
        });
    }

    public static macro function perform_done(done: Expr): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) {
                return macro Dispatcher.dispatch(function () {
                    ${fn}(${expr} * 10);
                }, 0);
            },
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            ${done}();
        });
    }
}

class ComputationTest_zero_transform {
    public static macro function perform_empty_eblock(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {});
    }

    public static macro function perform_efor(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            for (i in 0...0) { }
        });
    }

    public static macro function perform_ewhile(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            while (false) { }
        });
    }
}

class ComputationTest_EVars_transform_without_EMeta {
    public static macro function perform_single_var(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            var a = 1;
        });
    }

    public static macro function perform_multi_var(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            var a = 1, b = 2;
        });
    }

    public static macro function perform_single_var_return(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            var a = 1;
            a;
        });
    }

    public static macro function perform_multi_var_return(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            var a = 1, b = 2;
            a + b;
        });
    }
}

class ComputationTest_EVars_transform_with_EMeta {
    public static macro function perform_single_var(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            var a = @let 1;
        });
    }

    public static macro function perform_multi_var(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            var a = @let 1, b = 2;
        });
    }

    public static macro function perform_single_var_return(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            var a = @let 1;
            a;
        });
    }

    public static macro function perform_multi_var_return_1(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            var a = @let 1, b = 2;
            a + b;
        });
    }

    public static macro function perform_multi_var_return_2(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            var a = @let 1, b = @let 2;
            a + b;
        });
    }

    public static macro function perform_multi_var_return_3(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            var a = @let 1;
            var b = @let 2;
            a + b;
        });
    }

    public static macro function perform_single_var_return_foo(): Expr {
        return Computation.perform({
            keyword: "foo",
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
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
            buildReturn: function (expr: Expr) return macro function (fn) fn(${expr}),
            buildZero: function () return macro 0
        }, macro {
            @let 1;
        });
    }

    public static macro function perform_multi(): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return macro function (fn) fn(${expr}),
            buildZero: function () return macro 0
        }, macro {
            @let 1;
            @let 2;
        });
    }

    public static macro function perform_done(done: Expr): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) {
                return macro Dispatcher.dispatch(function () {
                    ${fn}(${expr} * 10);
                });
            },
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            @let 1;
            ${done}();
        });
    }

    public static macro function perform_done_foo(done: Expr): Expr {
        return Computation.perform({
            keyword: "foo",
            buildBind: function (expr: Expr, fn: Expr) {
                return macro Dispatcher.dispatch(function () {
                    ${fn}(${expr} * 10);
                });
            },
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, macro {
            @foo 1;
            ${done}();
        });
    }
}

class ComputationTest_nested_transform {
    public static function perform() {
        return perform_outer({
            var a = @let 10;                // a = 11
            var b = @let 5;                 // b = 6
            var c = @let perform_inner({    // +1
                var x = @let 5;             // x = 50
                var y = @let b;             // y = b * 10
                x + y;
            });
            a + c;
        });
    }

    static macro function perform_outer(expr: Expr): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} + 1),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, expr);
    }

    static macro function perform_inner(expr: Expr): Expr {
        return Computation.perform({
            buildBind: function (expr: Expr, fn: Expr) return macro ${fn}(${expr} * 10),
            buildReturn: function (expr: Expr) return expr,
            buildZero: function () return macro 0
        }, expr);
    }
}