package hxgnd;

#if macro
import haxe.macro.Expr;

class MacroTools {
    public static function isNull(expr: Expr): Bool {
        return switch (expr.expr) {
            case ExprDef.EConst(CIdent("null")): true;
            case _: false;
        }
    }
}
#end