package hxgnd;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hxgnd.internal.CallbackFlowComputation;
#end

class NodebackFlow {
    public static macro function compute(blockExpr: Expr): Expr {
        return CallbackFlowComputation.perform(buildCallback, blockExpr);
    }

    #if macro
    static function buildCallback(argSize: Int, fulfill: String, reject: String): Expr {
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