package hxgnd;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import extype.Maybe;
using hxgnd.ArrayTools;
using hxgnd.LangTools;
using haxe.macro.ExprTools;
#end

class CallbackFlow {
    public static macro function compute<T>(blockExpr: Expr): ExprOf<Promise<T>> {
        var expr = Computation.perform(
            {
                buildBind: buildBind.bind(Standard),
                buildReturn: buildReturn,
                buildZero: buildZero
            },
            blockExpr
        );
        trace(haxe.macro.ExprTools.toString(expr));
        return expr;
    }

    public static macro function computeNodeJsStyle<T>(blockExpr: Expr): ExprOf<Promise<T>> {
        var expr = Computation.perform(
            {
                buildBind: buildBind.bind(NodeJs),
                buildReturn: buildReturn,
                buildZero: buildZero
            },
            blockExpr
        );
        // trace(haxe.macro.ExprTools.toString(expr));
        return expr;
    }

    #if macro
    static function buildBind(style: CallbackStyle, cexpr: Expr, fn: Expr): Expr {
        switch (cexpr.expr) {
            case ECall(e, params):
                var placeholder = findPlaceholder(params);

                var arguments = getArguments(Context.typeof(e), e.pos);
                if (params.length > (arguments.length - (placeholder.isEmpty() ? 1 : 0))) {
                    return Context.error("Too many arguments", cexpr.pos);
                }

                var bindedArgs = getArguments(Context.typeof({expr: ECall(macro ${e}.bind, params), pos: e.pos}), e.pos);
                if (bindedArgs.length <= 0) {
                    return Context.error("Too many arguments", cexpr.pos);
                } else if (bindedArgs.length >= 2) {
                    return Context.error("Not enough arguments.", cexpr.pos);
                }

                var cbArguments = getArguments(bindedArgs[0].t, e.pos);
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
                var callback = switch (style) {
                    case Standard: starndardStyleCallback(cbArguments.length);
                    case NodeJs: nodeJsStyleCallback(cbArguments.length);
                }
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

    static function starndardStyleCallback(argSize: Int) {
        return switch (argSize) {
            case 0:
                macro function CallbackFlow_callback() fulfill(new extype.Unit());
            case 1:
                macro function CallbackFlow_callback(x) fulfill(x);
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
                        expr: macro fulfill(${newTuple}),
                    }),
                    pos: Context.currentPos()
                };
        }
    }

    static function nodeJsStyleCallback(argSize: Int) {
        return switch (argSize) {
            case 0:
                macro function CallbackFlow_callback() fulfill(new extype.Unit());
            case 1:
                macro function CallbackFlow_callback(error) {
                    if (error == null) {
                        fulfill(new extype.Unit());
                    } else {
                        reject(error);
                    }
                }
            case 2:
                macro function CallbackFlow_callback(error, value) {
                    if (error == null) {
                        fulfill(value);
                    } else {
                        reject(error);
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
                            fulfill(${newTuple});
                        } else {
                            reject(error);
                        },
                    }),
                    pos: Context.currentPos()
                };
        }
    }

    static function buildReturn(expr: Expr): Expr {
        return macro hxgnd.SyncPromise.resolve(${expr});
    }

    static function buildZero(): Expr {
        return macro hxgnd.SyncPromise.resolve(new extype.Unit());
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
    #end
}

private enum CallbackStyle {
    Standard;
    NodeJs;
}