package hxgnd.internal;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using hxgnd.ArrayTools;

class MacroTools {
    public static function correctUndefinedVars(inExpr: Expr): Expr {
        var outExprs = [];

        var stack = [inExpr];
        var map = new haxe.ds.StringMap();
        map.set("_", true);
        while (stack.length > 0) {
            var expr = stack.pop();
            switch (expr.expr) {
                case EConst(CIdent(x)) if (!map.exists(x)):
                    try {
                        Context.typeof(expr);
                    } catch (_: Dynamic) {
                        outExprs.push({expr: EVars([{name: x, type: null, expr: null}]), pos: Context.currentPos()});
                    }
                    map.set(x, true);
                case EArray(e1, e2):
                    stack.push(e1);
                    stack.push(e2);
                case EBinop(_, e1, e2):
                    stack.push(e1);
                    stack.push(e2);
                case EField(e, _):
                    stack.push(e);
                case EParenthesis(e):
                    stack.push(e);
                case EObjectDecl(fields):
                    stack = stack.concat(fields.map(function (x) return x.expr));
                case EArrayDecl(values):
                    stack = stack.concat(values);
                case ECall(e, params):
                    stack.push(e);
                    stack = stack.concat(params);
                case ENew(_, params):
                    stack = stack.concat(params);
                case EUnop(_, _, e):
                    stack.push(e);
                case EBlock(exprs):
                    stack = stack.concat(exprs);
                case EIf(econd, e, eelse):
                    stack.push(econd);
                    stack.push(e);
                    if (eelse != null) stack.push(eelse);
                case ESwitch(e, cases, edef):
                    stack.push(e);
                    stack = stack.concat(cases.map(function (x) {
                        var acc = x.values.copy();
                        if (x.expr != null) acc.push(x.expr);
                        if (x.guard != null) acc.push(x.guard);
                        return acc;
                    }).flatten());
                    stack.push(edef);
                case EUntyped(e):
                    stack.push(e);
                case ECast(e, _):
                    stack.push(e);
                case ETernary(econd, eif, eelse):
                    stack.push(econd);
                    stack.push(eif);
                    stack.push(eelse);
                case ECheckType(e, _):
                    stack.push(e);
                case EMeta(_, e):
                    stack.push(e);
                case _:
            }
        }

        outExprs.push(inExpr);
        return macro $b{outExprs};
    }

    public static function getArguments(expr: Expr): Array<{name: String, opt: Bool, t: Type}> {
        return _getArguments(Context.typeof(expr), expr.pos);
    }

    public static function getCallbackArguments(fn: Expr, params: Array<Expr>, pos: Position): Array<{name: String, opt: Bool, t: Type}> {
        var bindExpr = correctUndefinedVars({expr: ECall(macro ${fn}.bind, params), pos: fn.pos});

        var bindedArgs = _getArguments(Context.typeof(macro ${bindExpr}), fn.pos);
        if (bindedArgs.length <= 0) {
            return Context.error("Too many arguments", pos);
        } else if (bindedArgs.length >= 2) {
            return Context.error("Not enough arguments.", pos);
        }

        return _getArguments(bindedArgs[0].t, fn.pos);
    }

    static function _getArguments(type: Type, pos: Position): Array<{name: String, opt: Bool, t: Type}> {
        while (true) {
            switch (type) {
                case TFun(args, ret):
                    return args;
                case TType(typeRef, typeParams):
                    type = typeRef.get().type;
                case _:
                    break;
            }
        }
        return Context.error('${type.getName()} is not a function', pos);
    }
}