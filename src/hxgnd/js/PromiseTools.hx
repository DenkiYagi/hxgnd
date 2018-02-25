package hxgnd.js;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import hxgnd.MacroTools;
#end

class PromiseTools {
    public static macro function callAsPromise<T>(
        fn: ExprOf<haxe.Constraints.Function>, ?params: ExprOf<Array<Dynamic>>, ?mapFn: ExprOf<Array<Dynamic> -> T>
    ): ExprOf<js.Promise<T>> {
        var args = (if (MacroTools.isNull(params)) {
            [];
        } else {
            switch (params.expr) {
                case ExprDef.EArrayDecl(exprs): exprs;
                case _: Context.error("params must be EArrayDecl", params.pos);
            }   
        }).concat([
            if (MacroTools.isNull(mapFn)) {
                macro function (error, result) {
                    if (untyped error) {
                        reject(error);
                    } else {
                        // workaround for `Error -> Void -> Void` callback.
                        resolve(untyped result);
                    }
                }
            } else {
                macro untyped function (error) {
                    if (untyped error) {
                        reject(error);
                    } else {
                        resolve((${mapFn})(hxgnd.js.JsArray.from(hxgnd.js.JsNative.nativeArguments).slice(1)));
                    }
                }
            }
        ]);

        return macro new js.Promise(function (resolve, reject) {
            $e{ {expr: ExprDef.ECall(fn, args), pos: fn.pos} };
        });
    }
}
