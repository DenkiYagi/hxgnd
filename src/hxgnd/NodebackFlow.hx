package hxgnd;

import haxe.Constraints.Function;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import hxgnd.internal.CallbackFlowMacro;
#end

class NodebackFlow {
    /**
     * Perform a nodeback-flow comutation.
     * @param expr A computation expr.
     * @return ExprOf<SyncPromise<T>>
     */
    public static macro function compute<T>(expr: Expr): ExprOf<SyncPromise<T>> {
        return CallbackFlowMacro.perform(buildNodeback, expr);
    }

    /**
     * Promisify and call a nodeback-function.
     * @param fn A nodeback-function.
     * @param params Some parameters to pass as arguments.
     * @return A instance of SyncPromise that has a specified function result.
     */
    public static macro function promisifyCall<T>(fn: ExprOf<Function>, params: Array<Expr>): ExprOf<SyncPromise<T>> {
        return CallbackFlowMacro.promisifyCall(buildNodeback, fn, params);
    }

    #if macro
    static function buildNodeback(argSize: Int, fulfill: String, reject: String): Expr {
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
    #end
}
