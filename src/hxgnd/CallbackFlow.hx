package hxgnd;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hxgnd.internal.CallbackFlowComputation;

typedef CallbackBuilder = Int -> String -> String -> Expr;
#end

class CallbackFlow {
    public static macro function compute<T>(blockExpr: Expr): ExprOf<SyncPromise<T>> {
        return CallbackFlowComputation.perform(buildCallback, blockExpr);
    }

    #if macro
    static function buildCallback(argSize: Int, fulfill: String, reject: String) {
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
