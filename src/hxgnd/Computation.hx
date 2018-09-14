package hxgnd;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using hxgnd.ArrayTools;

class Computation {
    static inline var DEFAULT_KEYWORD = "let";

    public static function perform(builder: Builder, blockExpr: Expr): Expr {
        var exprs: Array<Expr> = switch (blockExpr.expr) {
            case EBlock(e): e;
            case _: Context.error("Invalid argument: must be a block.", blockExpr.pos);
        }

        var keyword = Maybe.ofNullable(builder.keyword).getOrElse(DEFAULT_KEYWORD);

        var builders = [];
        var cexprs = [];

        for (expr in exprs) {
            switch (expr.expr) {
                // bind
                case EVars(vars):
                    for (v in vars) {
                        switch (v.expr) {
                            case {expr: EMeta({name: keyword}, e)}:
                                builders.push(cexprs.concat);
                                cexprs = [];
                                builders.push(buildBind.bind(builder, {name: v.name, type: v.type, expr: e}));
                            case _:
                                cexprs.push({expr: EVars([v]), pos: v.expr.pos});
                        }
                    }

                // action
                case EMeta({name: keyword}, e):
                    builders.push(cexprs.concat);
                    cexprs = [];
                    builders.push(buildBind.bind(builder, {expr: e}));

                // case EIf(econd, eif, eelse):
                // case ETernary(econd, eif, eelse):
                // case ESwitch(e, cases, edef):
                // case EFor(it, expr):
                // case EWhile

                case _:
                    cexprs.push(expr);
            }
        }

        // build expr from the inside to the outside
        var newExprs = buildReturn(builder, cexprs);
        var i = builders.length;
        while (--i >= 0) {
            newExprs = builders[i](newExprs);
        }

        return if (newExprs.nonEmpty()) {
            macro (function () return $b{newExprs})();
        } else {
            MacroTools.nop();
        };
    }

    static function buildBind(builder: Builder, binded: BindedExpr, cexpr: Array<Expr>): Array<Expr> {
        return [builder.buildBind(binded.expr, {
            expr: EFunction(null, {
                args: [{
                    name: Maybe.ofNullable(binded.name).getOrElse("_"),
                    type: binded.type
                }],
                ret: null,
                expr:
                    if (cexpr.nonEmpty()) {
                        macro return $b{cexpr};
                    } else {
                        macro return;
                    }
            }),
            pos: binded.expr.pos
        })];
    }

    static function buildReturn(builder: Builder, cexpr: Array<Expr>): Array<Expr> {
        return [
            if (cexpr.nonEmpty()) {
               builder.buildReturn(macro $b{cexpr});
            } else {
                macro (function () {})();
            }
        ];
    }
}

typedef Builder = {
    @:optional var keyword: String;
    /**
     * M<T> -> (T -> M<U>) -> M<U>
     */
    var buildBind: Expr -> Expr -> Expr;
    /**
     * T -> M<T>
     */
    var buildReturn: Expr -> Expr;
}

private typedef BindedExpr = {
    @:optional var name: String;
    @:optional var type: ComplexType;
    var expr: Expr;
}
#end
