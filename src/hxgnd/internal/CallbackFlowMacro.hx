package hxgnd.internal;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import extype.Maybe;
import hxgnd.Computation;
import hxgnd.internal.MacroTools;
using haxe.macro.ExprTools;
using hxgnd.ArrayTools;
using hxgnd.LangTools;

class CallbackFlowMacro {
    /**
     * Perform a "Callback Flow" computation.
     * @param builder
     * @param blockExpr
     * @return ExprOf<SyncPromise<T>>
     */
    public static function perform<T>(builder: CallbackBuilder, blockExpr: Expr): ExprOf<SyncPromise<T>> {
        var expr = Computation.perform(
            {
                buildBind: buildBind.bind(builder),
                buildReturn: buildReturn,
                buildZero: buildZero,
                buildWhile: buildWhile,
                buildFor: buildFor,
                buildCombine: buildCombine
            },
            blockExpr
        );
        // trace(haxe.macro.ExprTools.toString(expr));
        return expr;
    }

    static function buildBind(builder: CallbackBuilder, cexpr: Expr, fn: Expr): Expr {
        switch (cexpr.expr) {
            case ECall(e, params):
                return macro ${promisifyCall(builder, e, params)}.then(${fn});
            case _:
                return cexpr;
        }
    }

    static function buildReturn(expr: Expr): Expr {
        return macro hxgnd.SyncPromise.resolve(${expr});
    }

    static function buildZero(): Expr {
        return macro hxgnd.SyncPromise.resolve(new extype.Unit());
    }

    static function buildWhile(cond: Expr, body: Expr): Expr {
        return macro (function _while(cond: Void -> Bool, body: Void -> hxgnd.SyncPromise<extype.Unit>): hxgnd.SyncPromise<extype.Unit> {
            return if (cond()) {
                body().then(function (_) return _while(cond, body));
            } else {
                ${buildZero()};
            }
        })(${cond}, ${body});
    }

    static function buildFor(iter: Expr, body: Expr): Expr {
        return macro (function _for(iter, body: Int -> hxgnd.SyncPromise<extype.Unit>): hxgnd.SyncPromise<extype.Unit> {
            return if (iter.hasNext()) {
                body(iter.next()).then(function (_) return _for(iter, body));
            } else {
                ${buildZero()};
            }
        })(${iter}, ${body});
    }

    static function buildCombine(expr1: Expr, expr2: Expr): Expr {
        return macro ${expr1}.then(function (_) return ${expr2});
    }

    /**
     * Promisify and call a function.
     * @param builder
     * @param fn
     * @param params
     * @return ExprOf<SyncPromise<T>>
     */
    public static function promisifyCall<T>(builder: CallbackBuilder,
            fn: ExprOf<haxe.Constraints.Function>, params: Array<Expr>): ExprOf<hxgnd.SyncPromise<T>> {
        var placeholder = findPlaceholder(params);

        var arguments = MacroTools.getArguments(fn);
        if (arguments.length <= 0) {
            return Context.error('${fn.toString()} does not have a callback argument.' , fn.pos);
        }
        if (params.length > (arguments.length - (placeholder.isEmpty() ? 1 : 0))) {
            return Context.error("Too many arguments", fn.pos);
        }

        var cbArguments = MacroTools.getCallbackArguments(fn, params, fn.pos);
        switch (cbArguments.length) {
            case 0:
                macro function CallbackFlow_callback() fulfill(new extype.Unit());
            case 1:
                macro function CallbackFlow_callback(x) fulfill(x);
            case _:
                var args = [ for (i in 0...cbArguments.length) {name: 'arg${i}', type: null} ];
                var tuple = {
                    expr: ENew(
                        {
                            pack: ["extype"],
                            name: "Tuple",
                            sub: 'Tuple${arguments.length}',
                            params: [],
                        },
                        [ for (i in 0...cbArguments.length) macro $i{'arg${i}'} ]
                    ),
                    pos: Context.currentPos()
                };

                {
                    expr: EFunction("CallbackFlow_callback", {
                        args: args,
                        ret: null,
                        expr: macro fulfill(${tuple}),
                    }),
                    pos: Context.currentPos()
                };
        }

        var newParams = params.copy();
        var callback = builder(cbArguments.length, "fulfill", "reject");
        if (placeholder.nonEmpty()) {
            newParams[placeholder.get()] = callback;
        } else {
            newParams.push(callback);
        }

        return macro new hxgnd.SyncPromise(function (fulfill, reject) {
            ${{expr: ECall(macro ${fn}, newParams), pos: fn.pos}};
        });
    }

    static function findPlaceholder(params: Array<Expr>): Maybe<Int> {
        var indexes = [for (i in 0...params.length) i].filter(function (i) {
            return switch (params[i].expr) {
                case EConst(CIdent("_")): true;
                case _: false;
            }
        });

        return switch (indexes.length) {
            case 0: Maybe.empty();
            case 1: Maybe.of(indexes[0]);
            case _: Context.error("Many \"_\" found", params[1].pos);
        }
    }
}

typedef CallbackBuilder = Int -> String -> String -> Expr;
