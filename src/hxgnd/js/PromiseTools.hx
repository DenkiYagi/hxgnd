package hxgnd.js;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;

using hxgnd.ArrayTools;
#end

class PromiseTools {
    public static macro function callAsPromise(
            fn: ExprOf<haxe.Constraints.Function>, params: Array<ExprOf<Dynamic>>): Expr {
        var argTypes = getCallbackArgTypes(fn);

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
                    $e{ {pos: fn.pos, expr: ExprDef.ECall(fn, params.concat([cb]))} };
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
                    $e{ {pos: fn.pos, expr: ExprDef.ECall(fn, params.concat([cb]))} };
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
                        expr: ExprDef.ECall(fn, params.concat([{expr: cb, pos: fn.pos}]))
                    } };
                }
                
                { 
                    expr: ENew({ pack: ["js"], name: "Promise", params: [TPType(t)] }, [init]),
                    pos: fn.pos
                };
        }
    }

    #if macro
    static function getCallbackArgTypes(fn: Expr): Array<{ name : String, opt : Bool, t : haxe.macro.Type }> {
        switch (Context.typeof(fn)) {
            case TFun(args, _):
                var cb = args[args.length-1];
                if (cb != null) {
                    switch (cb.t) {
                        case TFun(cbArgs, _) if (cbArgs.length >= 1): return cbArgs;
                        case _:
                    }
                }
            case _:
        }
        return [];
    }
    #end
}
