package hxgnd;

import haxe.Constraints.Function;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import hxgnd.internal.CallbackFlowMacro;
#end

class CallbackFlow {
    /**
     * Perform a callback-flow comutation.
     * @param expr A computation expr.
     * @return ExprOf<SyncPromise<T>>
     */
    public static macro function compute<T>(expr: Expr): ExprOf<SyncPromise<T>> {
        return CallbackFlowMacro.perform(buildCallback, expr);
    }

    /**
     * Promisify and call a callback-function.
     * @param fn A callback-function.
     * @param params Some parameters to pass as arguments.
     * @return A instance of SyncPromise that has a specified function result.
     */
    public static macro function promisifyCall<T>(fn: ExprOf<Function>, params: Array<Expr>): ExprOf<SyncPromise<T>> {
        return CallbackFlowMacro.promisifyCall(buildCallback, fn, params);
    }

    #if macro
    static function buildCallback(argSize: Int, fulfill: String, reject: String): Expr {
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
    #end
}
