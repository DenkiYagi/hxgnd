package hxgnd.js;

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
                    if (untyped error) reject(error) else resolve();
                };
                
                macro new js.Promise<Void>(function (resolve: haxe.Constraints.Function, reject) {
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
                    if (untyped error) reject(error) else resolve(data);
                };
                var init = macro function (resolve, reject) {
                    $e{ {pos: fn.pos, expr: ExprDef.ECall(fn, args.concat([cb]))} };
                }
                
                { 
                    expr: ENew({ pack: ["js"], name: "Promise", params: [TPType(t)] }, [init]),
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
                    expr: macro { if (untyped error) reject(error) else ${resolve}; }
                });
                var init = macro function (resolve, reject) {
                    $e{ {
                        pos: fn.pos, 
                        expr: ExprDef.ECall(fn, args.concat([{expr: cb, pos: fn.pos}]))
                    } };
                }
                
                { 
                    expr: ENew({ pack: ["js"], name: "Promise", params: [TPType(t)] }, [init]),
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
                    if (untyped error) reject(error) else resolve();
                };
                
                macro new js.Promise<Void>(function (resolve: haxe.Constraints.Function, reject) {
                    $e{ {pos: fn.pos, expr: ExprDef.ECall(fn, args.concat([cb]))} };
                });
            case 2:
                // new Promise(funciton (resolve, reject) {
                //     fn(function (error, data) {
                //         if (error) reject(error) else resolve(data);
                //     });
                // });
                var cb = macro function (error, data) {
                    if (untyped error) reject(error) else resolve(data);
                };
                var init = macro function (resolve, reject) {
                    $e{ {pos: fn.pos, expr: ExprDef.ECall(fn, args.concat([cb]))} };
                }
                
                { 
                    expr: ENew({ pack: ["js"], name: "Promise", params: [] }, [init]),
                    pos: fn.pos
                };
            case _:
                // new Promise(funciton (resolve, reject) {
                //     fn(function (error, a, b, ..., z) {
                //         if (error) reject(error) else resolve([a, b, ..., z]);
                //     });
                // });
                var cb = macro untyped function (error) {
                    if (untyped error) {
                        reject(error);
                     } else {
                        resolve(hxgnd.js.JsArray.from(hxgnd.js.JsNative.nativeArguments).slice(1));
                     }
                };
                
                macro new js.Promise<Array<Dynamic>>(function (resolve, reject) {
                    $e{ {
                        pos: fn.pos, 
                        expr: ExprDef.ECall(fn, args.concat([cb]))
                    } };
                });
        }
    }

    public static macro function await<T>(expr: ExprOf<js.Promise<T>>): ExprOf<T> {
        var type = switch (Context.toComplexType(Context.typeof(expr))) {
            case TPath({ name: "Promise", pack: ["js"], params: params }):
                switch (params[0]) {
                    case TPType(t): t;
                    case TPExpr(e): Context.toComplexType(Context.typeof(e));
                }
            default:
                Context.error("argument must be js.Promsise<T>", expr.pos);
        };
        return {
            pos: expr.pos,
            expr: ECheckType(macro untyped __js__("(await {0})", ${expr}), type) 
        };
    }

    public static macro function async<T>(expr: ExprOf<haxe.Constraints.Function>): Expr {
        var expr = resolveEMetaExpr(expr);
        
        var funcName: Null<String>;
        var funcDef: Function;
        var retType: ComplexType;
        switch (expr.expr) {
            case EFunction(n, f):
                funcName = n;
                funcDef = f;
                retType = inferReturnType(expr, []);
            case _:
                Context.error("expr must be a function expr", expr.pos);
                throw "";
        }

        return macro $e{ {
            pos: expr.pos,
            expr: EFunction(funcName, {
                args: funcDef.args,
                ret: TPath({ pack: ["js"], name: "Promise", params: [TPType(retType)] }),
                expr: macro return ${toAsyncFuncCall(null, funcDef)}
            })
        } };
    }

    public static macro function asyncCall<T>(expr: ExprOf<haxe.Constraints.Function>, args: Array<Expr>): ExprOf<js.Promise<T>> {
        var expr = resolveEMetaExpr(expr);
        
        var retType = inferReturnType(expr, args);
        var funcName: Null<String>;
        var funcDef: Function;
        switch (expr.expr) {
            case EFunction(n, f):
                funcName = n;
                funcDef = f;
            case _:
                Context.error("expr must be a function expr", expr.pos);
                throw "";
        }
        return {
            pos: expr.pos,
            expr: ECall({
                pos: expr.pos,
                expr: EFunction(null, {
                    args: funcDef.args,
                    ret: TPath({ pack: ["js"], name: "Promise", params: [TPType(retType)] }),
                    expr: macro return ${toAsyncFuncCall(funcName, funcDef)}
                })
            }, args)
        };
    }

    #if macro
    static function getCallbackArgTypes(fn: Expr, args: Array<Expr>): Array<{ name : String, opt : Bool, t : haxe.macro.Type }> {
        function resolve(callback: haxe.macro.Type, dict: Map<String, haxe.macro.Type>) {
            // trace("-----");
            // trace(callback);
            // trace(dict);
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
                    // switch (callback.t) {
                    //     case TFun(cbArgs, _) if (cbArgs.length >= 1):
                    //         return cbArgs;
                    //     case TType(t, params):
                    //         var type = t.get();
                    //         var tmap = type.params.map(function (x) {
                    //             switch (x.t) {
                    //                 case TInst(ref, _): return ref.toString();
                    //                 case _: throw "unsupported type";
                    //             }
                    //         }).zipmap(params);
                    //         switch (type.type) {
                    //             case TFun(cbArgs, _):
                    //                 return cbArgs.map(function (x) {
                    //                     return switch (x.t) {
                    //                         case TInst(n, _) if (tmap.exists(Std.string(n))):
                    //                             { t: tmap.get(Std.string(n)), opt: x.opt, name: x.name };
                    //                         case _:
                    //                             x;
                    //                     }
                    //                 });
                    //             case _:
                    //         }
                            
                    //         trace("****");
                    //         trace(tmap);
                    //         trace("****");
                    //         trace(t.get().type);
                    //         trace(t.get().params);
                    //         trace(params);
                    //         trace("****");
                    //         // switch (t.get().type) {

                    //         // }
                    //     case _:
                    // }
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

    public static function resolveEMetaExpr(expr: Expr): Expr {
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
