package hxgnd;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;
using Lambda;
#end

class LangTools {
    public static inline function eq<T>(a: Null<T>, b: Null<T>): Bool {
        #if js
        return untyped __strict_eq__(a, b);
        #else
        return a == b;
        #end
    }

    public static inline function neq<T>(a: Null<T>, b: Null<T>): Bool {
        #if js
        return untyped __strict_neq__(a, b);
        #else
        return a != b;
        #end
    }

    public static inline function isNull<T>(a: Null<T>): Bool {
        return a == null;
    }

    public static inline function nonNull<T>(a: Null<T>): Bool {
        return a != null;
    }

    #if js
    public static inline function isUndefined<T>(a: Null<T>): Bool {
        return eq(a, js.Lib.undefined);
    }
    #end

    public static inline function toMaybe<T>(a: Null<T>): Maybe<T> {
        return a;
    }

    public static inline function isEmpty(x: Null<String>): Bool {
        return isNull(x) || eq(x, "");
    }

    public static inline function nonEmpty(x: Null<String>): Bool {
        return nonNull(x) && neq(x, "");
    }

    // It's compatible with .NET's String.isNullOrBlack().
    #if js
    static var BLANK = ~/^[\x09-\x0D\x85\x20\xA0\u1680\u2000-\u200A\u202F\u205F\u3000\u2028\u2029]*$/u;
    #else
    static var BLANK = ~/^[\x09-\x0D\x85\x20\xA0\x{1680}\x{2000}-\x{200A}\x{202F}\x{205F}\x{3000}\x{2028}\x{2029}]*$/u;
    #end

    public static inline function isBlank(x: Null<String>): Bool {
        return isNull(x) || BLANK.match(x);
    }

    public static inline function nonBlank(x: Null<String>): Bool {
        return !isBlank(x);
    }

    #if macro
    static var sequence = 1;
    #end
    public static macro function combine(rest: Array<ExprOf<{}>>): Expr {
        if (rest.length <= 0) return Context.error("Not enough arguments", Context.currentPos());
        if (rest.length == 1) return rest[0];
        
        var block = [];
        var map = new Map<String, {field: String, expr: Expr}>();
        for (rx in rest) {
            var type = Context.typeof(rx);
            switch (type.follow()) {
                case TAnonymous(_.get() => tr):
                    var name = "__hxgnd_tmp_struct_" + sequence++;
                    block.push(macro var $name = $rx);
                    var extVar = macro $i{name};
                    for (field in tr.fields) {
                        var fname = field.name;
                        map.set(fname, { field: fname, expr: macro $extVar.$fname } );
                    }
                default:
                    return Context.error("Object type expected instead of " + type.toString(), rx.pos);
            }
        }
        block.push(macro ${ {expr: EObjectDecl(map.array()), pos: Context.currentPos()} });
        return macro $b{block};
    }
}