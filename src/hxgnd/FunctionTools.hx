package hxgnd;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Constraints.Function;
import hxgnd.internal.MacroTools;

class FunctionTools {
    public static macro function hold(fn: ExprOf<Function>, params: Array<Expr>): Expr {
        var args = MacroTools.getArguments(fn);
        if (args.length < params.length) {
            return Context.error("Too many arguments", fn.pos);
        }
        if (args.length == 0 || params.length == 0) {
            return fn;
        }

        var bindedArgs = MacroTools.getArguments({expr: ECall(macro ${fn}.bind, params), pos: fn.pos});
        var clsName = 'FunctionBinder${args.length}';
        var placeholders = [];
        if (bindedArgs.length > 0) {
            var unused = [];
            for (i in 0...params.length) {
                switch (params[i].expr) {
                    case EConst(CIdent("_")): placeholders.push(i);
                    case _: unused.push(i);
                }
            }
            var rest = params.length - placeholders.length;
            if (rest > 0) {
                placeholders = placeholders.concat(unused.slice(unused.length - rest));
                placeholders.sort(function (a, b) return a - b);
            }
            clsName += '_${placeholders.join("_")}';
        }


        if (Context.getType(clsName) == null) {
            Context.defineType({
                pack: [],
                name: clsName,
                pos: fn.pos,
                kind: TDClass(null, null, null),
                params: [ for (i in 0...args.length) { name: 'T$i' } ],
                fields: [
                    {
                        name: "fn",
                        access: [],
                        kind: FVar({ t: null }),
                        pos: Context.currentPos()
                    },
                    {
                        name: "new",
                        access: [APublic],
                        kind: FFun({ args: [], ret: null, expr: null }),
                        pos: Context.currentPos()
                    },
                    {
                        name: "call",
                        access: [APublic],
                        kind: FFun({ args: [], ret: null, expr: null }),
                        pos: Context.currentPos()
                    },
                ]
            });

        }

        return macro ${{expr: ENew({pack: [], name: clsName}, [fn].concat(params)), pos: fn.pos}}.call;
    }
}
