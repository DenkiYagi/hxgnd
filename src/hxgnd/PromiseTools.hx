package hxgnd;

import externtype.Mixed2;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;

using hxgnd.ArrayTools;
#end

class PromiseTools {
    public static macro function callAsPromise(
            fn: ExprOf<haxe.Constraints.Function>, args: Array<Expr>): Expr {
        var argTypes = getCallbackArgTypes(fn, args);
        return switch (argTypes.length) {
            case 0:
                Context.error("Invalid function is specified.", fn.pos);
            case 1:
                // new Promise(funciton (resolve, reject) {
                //     fn(function (error) {
                //         if (error) reject(error) else resolve();
                //     });
                // });
                var cb = macro function (error) {
                    if (hxgnd.LangTools.nonNull(error)) reject(error) else resolve();
                };

                macro new hxgnd.SyncPromise<Void>(function (resolve: haxe.Constraints.Function, reject) {
                    $e{ {pos: fn.pos, expr: ExprDef.ECall(fn, args.concat([cb]))} };
                });
            case 2:
                // new Promise(funciton (resolve, reject) {
                //     fn(function (error, data) {
                //         if (error) reject(error) else resolve(data);
                //     });
                // });
                var t = Context.toComplexType(argTypes[1].t);
                var cb = macro function (error, data) {
                    if (hxgnd.LangTools.nonNull(error)) reject(error) else resolve(data);
                };
                var init = macro function (resolve, reject) {
                    $e{ {pos: fn.pos, expr: ExprDef.ECall(fn, args.concat([cb]))} };
                }

                {
                    expr: ENew({ pack: ["hxgnd"], name: "SyncPromise", params: [TPType(t)] }, [init]),
                    pos: fn.pos
                };
            case _:
                // new Promise(funciton (resolve, reject) {
                //     fn(function (error, a, b, ..., z) {
                //         if (error) reject(error) else resolve({ value1: a, value2: b, valueN: z });
                //     });
                // });
                var t = TAnonymous(argTypes.slice(1).mapWithIndex(function (a, i): Field {
                    return {
                        name: 'value${i+1}',
                        kind: FProp("default", "never", Context.toComplexType(a.t), null),
                        access: [Access.APublic],
                        pos: fn.pos
                    };
                }));
                var resolve = {
                    expr: ECall(macro resolve, [{
                        expr: EObjectDecl((0...argTypes.length-1).toArray().map(function (i) {
                            return {
                                field: 'value${i+1}',
                                expr: { expr: EConst(CIdent('value$i')), pos: fn.pos }
                            }
                        })),
                        pos: fn.pos
                    }]),
                    pos: fn.pos
                };
                var cb = EFunction(null, {
                    args: [{ name: "error", type: null }].concat(argTypes.slice(1).mapWithIndex(function (a, i): FunctionArg {
                        return {
                            name: 'value$i',
                            type: Context.toComplexType(a.t)
                        };
                    })),
                    ret: null,
                    expr: macro { if (hxgnd.LangTools.nonNull(error)) reject(error) else ${resolve}; }
                });
                var init = macro function (resolve, reject) {
                    $e{ {
                        pos: fn.pos,
                        expr: ExprDef.ECall(fn, args.concat([{expr: cb, pos: fn.pos}]))
                    } };
                }

                {
                    expr: ENew({ pack: ["hxgnd"], name: "SyncPromise", params: [TPType(t)] }, [init]),
                    pos: fn.pos
                };
        }
    }

    public static macro function callAsPromiseUnsafe(
            fn: ExprOf<haxe.Constraints.Function>, args: Array<Expr>): Expr {
        var argTypes = getCallbackArgTypes(fn, args);

        return switch (argTypes.length) {
            case 0:
                Context.error("Invalid function is specified.", fn.pos);
            case 1:
                // new Promise(funciton (resolve, reject) {
                //     fn(function (error) {
                //         if (error) reject(error) else resolve();
                //     });
                // });
                var cb = macro function (error) {
                    if (hxgnd.LangTools.nonNull(error)) reject(error) else resolve();
                };

                macro new hxgnd.SyncPromise<Void>(function (resolve: haxe.Constraints.Function, reject) {
                    $e{ {pos: fn.pos, expr: ExprDef.ECall(fn, args.concat([cb]))} };
                });
            case 2:
                // new Promise(funciton (resolve, reject) {
                //     fn(function (error, data) {
                //         if (error) reject(error) else resolve(data);
                //     });
                // });
                var cb = macro function (error, data) {
                    if (hxgnd.LangTools.nonNull(error)) reject(error) else resolve(data);
                };
                var init = macro function (resolve, reject) {
                    $e{ {pos: fn.pos, expr: ExprDef.ECall(fn, args.concat([cb]))} };
                }

                {
                    expr: ENew({ pack: ["hxgnd"], name: "SyncPromise", params: [] }, [init]),
                    pos: fn.pos
                };
            case _:
                // new Promise(funciton (resolve, reject) {
                //     fn(function (error, a, b, ..., z) {
                //         if (error) reject(error) else resolve([a, b, ..., z]);
                //     });
                // });
                var resolve = {
                    expr: ECall(macro resolve, [{
                        expr: EArrayDecl((0...argTypes.length-1).toArray().map(function (i) {
                            return { expr: EConst(CIdent('value$i')), pos: fn.pos };
                        })),
                        pos: fn.pos
                    }]),
                    pos: fn.pos
                };
                var cb = EFunction(null, {
                    args: [{ name: "error", type: null }].concat(argTypes.slice(1).mapWithIndex(function (a, i): FunctionArg {
                        return {
                            name: 'value$i',
                            type: Context.toComplexType(a.t)
                        };
                    })),
                    ret: null,
                    expr: macro { if (hxgnd.LangTools.nonNull(error)) reject(error) else ${resolve}; }
                });
                macro new hxgnd.SyncPromise<Array<Dynamic>>(function (resolve, reject) {
                    $e{ {
                        expr: ExprDef.ECall(fn, args.concat([{expr: cb, pos: fn.pos}])),
                        pos: fn.pos
                    } };
                });
        }
    }

    #if (js || macro)
    public static inline macro function await<T>(expr: ExprOf<Mixed2<js.Promise<T>, IPromise<T>>>): ExprOf<T> {
        return macro untyped __js__("await {0}", ${expr});
    }

    public static macro function async<T>(body: Expr): Expr {
        var body = resolveEMetaExpr(body);

        var funcName: Null<String>;
        var funcDef: Function;
        var retType: ComplexType;
        switch (body.expr) {
            case EFunction(n, f):
                funcName = n;
                funcDef = f;
                retType = inferReturnType(body, []);
            case EBlock(_):
                funcName = null;
                funcDef = {
                    args: [],
                    ret: null,
                    expr: body
                }
                retType = inferReturnType({
                    pos: body.pos,
                    expr: EFunction(funcName, funcDef)
                }, []);
            case _:
                Context.error("body must be a expr that is Function or Block", body.pos);
                throw "";
        }

        return macro $e{ {
            pos: body.pos,
            expr: EFunction(funcName, {
                args: funcDef.args,
                ret: TPath({ pack: ["hxgnd"], name: "Promise", params: [TPType(retType)] }),
                expr: macro return ${toAsyncFuncCall(null, funcDef)}
            })
        } };
    }

    public static macro function asyncCall<T>(body: Expr, args: Array<Expr>): ExprOf<Promise<T>> {
        var body = resolveEMetaExpr(body);

        var funcName: Null<String>;
        var funcDef: Function;
        var retType: ComplexType;
        switch (body.expr) {
            case EFunction(n, f):
                funcName = n;
                funcDef = f;
                retType = inferReturnType(body, args);
            case EBlock(_):
                funcName = null;
                funcDef = {
                    args: [],
                    ret: null,
                    expr: body
                }
                retType = inferReturnType({
                    pos: body.pos,
                    expr: EFunction(funcName, funcDef)
                }, []);
            case _:
                Context.error("body must be a expr that is Function or Block", body.pos);
                throw "";
        }
        return {
            pos: body.pos,
            expr: ECall({
                pos: body.pos,
                expr: EFunction(null, {
                    args: funcDef.args,
                    ret: TPath({ pack: ["hxgnd"], name: "Promise", params: [TPType(retType)] }),
                    expr: macro return ${toAsyncFuncCall(funcName, funcDef)}
                })
            }, args)
        };
    }
    #end

    #if macro
    static function getCallbackArgTypes(fn: Expr, args: Array<Expr>): Array<{ name : String, opt : Bool, t : haxe.macro.Type }> {
        function resolve(callback: haxe.macro.Type, dict: Map<String, haxe.macro.Type>) {
            switch (callback) {
                case TFun(args, _) if (args.length > 0): //must Error -> ... -> Void
                    return args.map(function (x) {
                        return switch (x.t) {
                            case TInst(ref, _) if (dict.exists(ref.toString())):
                                { t: dict.get(ref.toString()), opt: x.opt, name: x.name };
                            case _:
                                x;
                        }
                    });
                case TType(typeRef, typeParams):
                    var type = typeRef.get();
                    return resolve(type.type, type.params.map(function (x) {
                        switch (x.t) {
                            case TInst(ref, _):
                                return ref.toString();
                            case _:
                                throw "unsupported type";
                        }
                    }).zipStringMap(typeParams.map(function (x) {
                        return switch (x) {
                            case TInst(ref, _) if (dict.exists(ref.toString())):
                                dict.get(ref.toString());
                            case _:
                                x;
                        }
                    })));
                case _:
                    Context.error("Callback function must have any arguemnts", fn.pos);
                    throw "";
            }
        }

        var bind = { expr: ECall(macro ${fn}.bind, args), pos: fn.pos };
        switch (Context.typeof(bind)) {
            case TFun(args, _) if (args.length > 0):
                var callback = args[args.length-1];
                return resolve(callback.t, new Map());
            case _:
                Context.error("Specified expr is not function.", fn.pos);
                throw "";
        }
    }

    static function inferReturnType(expr: Expr, args: Array<Expr>): ComplexType {
        switch (Context.toComplexType(Context.typeof(expr))) {
            case TFunction(fargs, fret):
                if (fargs.length == args.length) {
                    return Context.toComplexType(Context.typeof({expr: ECall(expr, args), pos: expr.pos}));
                } else if (args.length == 0 && fret != null) {
                    return fret;
                }
            case _:
        }
        Context.error("Cannot infer return type. You must set type to this function", expr.pos);
        return TPath({pack: [], name: "Dynamic", params: []});
    }

    static function resolveEMetaExpr(expr: Expr): Expr {
        return switch (expr.expr) {
            case EMeta({name: ":this"}, _):
                var posInfo = Context.getPosInfos(expr.pos);
                var content = sys.io.File.getContent(posInfo.file).substring(posInfo.min, posInfo.max);
                Context.parseInlineString(content, expr.pos);
            case _:
                expr;
        }
    }

    static function toAsyncFuncCall(name: Null<String>, func: Function): Expr {
        var n = if (name == null) "" else name;
        var js = switch (func.expr.expr) {
            case EBlock(exprs) if (exprs.length >= 2):
                '(async function ${n}() {0})()';
            case _:
                '(async function ${n}() { {0}; })()';
        }
        return macro untyped __js__($v{js}, ${func.expr});
    }
    #end
}
