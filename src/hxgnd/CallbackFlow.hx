package hxgnd;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import extype.Maybe;
using hxgnd.ArrayTools;
using hxgnd.LangTools;
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
        // trace(haxe.macro.ExprTools.toString(expr));
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

                var argSize = getCallbackArgSize(e, placeholder);
                var callback = switch (style) {
                    case Standard: starndardStyleCallback(argSize);
                    case NodeJs: nodeJsStyleCallback(argSize);
                }

                switch (argSize) {
                    case 0:
                        macro function CallbackFlow_callback() fulfill(new extype.Unit());
                    case 1:
                        macro function CallbackFlow_callback(x) fulfill(x);
                    case _:
                        var args = [ for (i in 0...argSize) {name: 'arg${i}', type: null} ];
                        var tuple = {
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
                                expr: macro fulfill(${tuple}),
                            }),
                            pos: Context.currentPos()
                        };
                }

                var newParams = params.copy();
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

    static function getCallbackArgSize(fn: Expr, index: Maybe<Int>): Int {
        switch (Context.typeof(fn)) {
            case TFun(args, _) if (args.length >= 1):
                return if (index.nonEmpty()) {
                    resolveArgSize(args[index.get()].t, fn.pos);
                } else {
                    resolveArgSize(args.last().get().t, fn.pos);
                }
            case _:
        }
        return Context.error("Can not get the argument size.", fn.pos);
    }

    static function resolveArgSize(type: Type, pos: Position): Int {
        while (true) {
            switch (type) {
                case TFun(args, ret):
                    return args.length;
                case TType(typeRef, typeParams):
                    type = typeRef.get().type;
                case _:
                    break;
            }
        }
        return Context.error("Can not get the argument size.", pos);
    }
    #end
}

private enum CallbackStyle {
    Standard;
    NodeJs;
}