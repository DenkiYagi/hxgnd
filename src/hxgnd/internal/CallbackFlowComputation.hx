package hxgnd.internal;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import extype.Maybe;
import hxgnd.Computation;
using hxgnd.ArrayTools;
using hxgnd.LangTools;
using haxe.macro.ExprTools;

typedef CallbackBuilder = Int -> String -> String -> Expr;
#end

class CallbackFlowComputation {
    #if macro
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

    static function buildReturn(expr: Expr): Expr {
        return macro hxgnd.SyncPromise.resolve(${expr});
    }

    static function buildZero(): Expr {
        return macro hxgnd.SyncPromise.resolve(new extype.Unit());
    }

    static function buildWhile(cond: Expr, body: Expr): Expr {
        return macro function _while(cond: Void -> Bool, body: Void -> hxgnd.SyncPromise<extype.Unit>): hxgnd.SyncPromise<extype.Unit> {
            return if (cond()) {
                body().then(function (_) return _while(cond, body));
            } else {
                ${buildZero()};
            }
        }(${cond}, ${body});
    }

    static function buildFor(iter: Expr, body: Expr): Expr {
        return macro function _for(iter, body: Int -> hxgnd.SyncPromise<extype.Unit>): hxgnd.SyncPromise<extype.Unit> {
            return if (iter.hasNext()) {
                body(iter.next()).then(function (_) return _for(iter, body));
            } else {
                ${buildZero()};
            }
        }(${iter}, ${body});
    }

    static function buildCombine(expr1: Expr, expr2: Expr): Expr {
        return macro ${expr1}.then(function (_) return ${expr2});
    }

    static function buildBind(builder: CallbackBuilder, cexpr: Expr, fn: Expr): Expr {
        switch (cexpr.expr) {
            case ECall(e, params):
                var placeholder = findPlaceholder(params);

                var arguments = getArguments(Context.typeof(e), e.pos);
                if (params.length > (arguments.length - (placeholder.isEmpty() ? 1 : 0))) {
                    return Context.error("Too many arguments", cexpr.pos);
                }

                var cbArguments = getCallbackArguments(e, params, cexpr.pos);
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
                    ${{expr: ECall(macro ${e}, newParams), pos: cexpr.pos}};
                }).then(${fn});
            case _:
                return cexpr;
        }
    }

    static function starndardStyleCallback(argSize: Int, fulfill: String, reject: String) {
        return switch (argSize) {
            case 0:
                macro function CallbackFlow_callback() $i{fulfill}(new extype.Unit());
            case 1:
                macro function CallbackFlow_callback(x) $i{fulfill}(x);
            case _:
                var args = [ for (i in 0...argSize) {name: 'arg${i}', type: null} ];
                var newTuple = {
                    expr: ENew(
                        {
                            pack: ["extype"],
                            name: "Tuple",
                            sub: 'Tuple${argSize}',
                            params: [],
                        },
                        [ for (i in 0...argSize) macro $i{'arg${i}'} ]
                    ),
                    pos: Context.currentPos()
                };

                {
                    expr: EFunction("CallbackFlow_callback", {
                        args: args,
                        ret: null,
                        expr: macro $i{fulfill}(${newTuple}),
                    }),
                    pos: Context.currentPos()
                };
        }
    }

    static function nodeJsStyleCallback(argSize: Int, fulfill: String, reject: String): Expr {
        return switch (argSize) {
            case 0:
                macro function CallbackFlow_callback() fulfill(new extype.Unit());
            case 1:
                macro function CallbackFlow_callback(error) {
                    if (error == null) {
                        $i{fulfill}(new extype.Unit());
                    } else {
                        $i{reject}(error);
                    }
                }
            case 2:
                macro function CallbackFlow_callback(error, value) {
                    if (error == null) {
                        $i{fulfill}(value);
                    } else {
                        $i{reject}(error);
                    }
                }
            case _:
                var args = [{name: "error", type: null}].concat([ for (i in 0...argSize-1) {name: 'arg${i}', type: null} ]);
                var newTuple = {
                    expr: ENew(
                        {
                            pack: ["extype"],
                            name: "Tuple",
                            sub: 'Tuple${argSize-1}',
                            params: [],
                        },
                        [ for (i in 0...argSize-1) macro $i{'arg${i}'} ]
                    ),
                    pos: Context.currentPos()
                };

                {
                    expr: EFunction("CallbackFlow_callback", {
                        args: args,
                        ret: null,
                        expr: macro if (error == null) {
                            $i{fulfill}(${newTuple});
                        } else {
                            $i{reject}(error);
                        },
                    }),
                    pos: Context.currentPos()
                };
        }
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

    static function getArguments(type: Type, pos: Position): Array<{name: String, opt: Bool, t: Type}> {
        while (true) {
            switch (type) {
                case TFun(args, ret):
                    return args;
                case TType(typeRef, typeParams):
                    type = typeRef.get().type;
                case _:
                    break;
            }
        }
        return Context.error('${type.getName()} is not a function', pos);
    }

    static function getCallbackArguments(fn: Expr, params: Array<Expr>, pos: Position): Array<{name: String, opt: Bool, t: Type}> {
        var bindExpr = [];

        var stack = params.copy();
        var map = new haxe.ds.StringMap();
        map.set("_", true);
        while (stack.length > 0) {
            var expr = stack.pop();
            switch (expr.expr) {
                case EConst(CIdent(x)) if (!map.exists(x)):
                    try {
                        Context.typeof(expr);
                    } catch (_: Dynamic) {
                        bindExpr.push({expr: EVars([{name: x, type: null, expr: null}]), pos: Context.currentPos()});
                    }
                    map.set(x, true);
                case EArray(e1, e2):
                    stack.push(e1);
                    stack.push(e2);
                case EBinop(_, e1, e2):
                    stack.push(e1);
                    stack.push(e2);
                case EField(e, _):
                    stack.push(e);
                case EParenthesis(e):
                    stack.push(e);
                case EObjectDecl(fields):
                    stack = stack.concat(fields.map(function (x) return x.expr));
                case EArrayDecl(values):
                    stack = stack.concat(values);
                case ECall(e, params):
                    stack.push(e);
                    stack = stack.concat(params);
                case ENew(_, params):
                    stack = stack.concat(params);
                case EUnop(_, _, e):
                    stack.push(e);
                case EBlock(exprs):
                    stack = stack.concat(exprs);
                case EIf(econd, e, eelse):
                    stack.push(econd);
                    stack.push(e);
                    if (eelse != null) stack.push(eelse);
                case ESwitch(e, cases, edef):
                    stack.push(e);
                    stack = stack.concat(cases.map(function (x) {
                        var acc = x.values.copy();
                        if (x.expr != null) acc.push(x.expr);
                        if (x.guard != null) acc.push(x.guard);
                        return acc;
                    }).flatten());
                    stack.push(edef);
                case EUntyped(e):
                    stack.push(e);
                case ECast(e, _):
                    stack.push(e);
                case ETernary(econd, eif, eelse):
                    stack.push(econd);
                    stack.push(eif);
                    stack.push(eelse);
                case ECheckType(e, _):
                    stack.push(e);
                case EMeta(_, e):
                    stack.push(e);
                case _:
            }
        }
        bindExpr.push({expr: ECall(macro ${fn}.bind, params), pos: fn.pos});

        var bindedArgs = getArguments(Context.typeof(macro $b{bindExpr}), fn.pos);
        if (bindedArgs.length <= 0) {
            return Context.error("Too many arguments", pos);
        } else if (bindedArgs.length >= 2) {
            return Context.error("Not enough arguments.", pos);
        }

        return getArguments(bindedArgs[0].t, fn.pos);
    }
    #end
}