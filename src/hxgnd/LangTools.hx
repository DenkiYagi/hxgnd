package hxgnd;

import Type.ValueType;
import haxe.io.Bytes;
import haxe.Constraints.IMap;
import hxgnd.Tuple;
#if js
import hxgnd.js.JsNative;
import hxgnd.js.JsObject;
import hxgnd.js.JsArray;
#end
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;
using Lambda;
#end

class LangTools {
    public static var emptyFunction(default, null) = function empty() {};

    public static inline function eq<T>(a: Null<T>, b: Null<T>): Bool {
        #if js
        return JsNative.strictEq(a, b);
        #else
        return a == b;
        #end
    }

    public static inline function neq<T>(a: Null<T>, b: Null<T>): Bool {
        #if js
        return JsNative.strictNeq(a, b);
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
        return JsNative.strictEq(a, js.Lib.undefined);
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

    #if js
    public static function freeze(value: Dynamic): Dynamic {
        var stack = [value];
        while (stack.length > 0) {
            var current = stack.pop();
            if (nonJsObject(current)) continue;
            JsObject.freeze(current);
            if (JsArray.isArray(current)) {
                stack = stack.concat(current);
            } else {
                for (k in Reflect.fields(current)) {
                    stack.push(Reflect.field(current, k));
                }
            }
        }
        return value;
    }
    #end

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

    public static function same(value1: Dynamic, value2: Dynamic): Bool {
        #if js
        if (eq(value1, value2) || isNull(value1) && isNull(value2)) return true;
        #else
        if (eq(value1, value2)) return true;
        #end

        var stack = [new Tuple2(value1, value2)];
        var loop = 0;
        while (stack.length > 0 && loop++ < 20) {
            var tuple = stack.pop();
            var a = tuple.value1;
            var b = tuple.value2;

            #if js
            if (eq(a, b) || isNull(a) && isNull(b)) continue;
            if (nonJsObject(a) || nonJsObject(b)) return false;
            #else
            if (eq(a, b)) continue;
            if (Std.is(a, String) || Std.is(b, String)) return false;
            #end

            switch (Type.typeof(a)) {
                case TEnum(aEnum):
                    switch (Type.typeof(b)) {
                        case TEnum(bEnum) if (eq(aEnum, bEnum)):
                            if (neq(Type.enumIndex(cast a), Type.enumIndex(cast b))) return false;
                            var aParams = Type.enumParameters(cast a);
                            var bParams = Type.enumParameters(cast b);
                            var len = aParams.length;
                            if (neq(len, bParams.length)) return false;
                            for (i in 0...len) {
                                stack.push(new Tuple2(aParams[i], bParams[i]));
                            }
                            continue;
                        case _:
                            return false;
                    }
                case TObject:
                    switch (Type.typeof(b)) {
                        case TObject:
                        case _: return false;
                    }
                case TClass(aCls):
                    switch (Type.typeof(b)) {
                        case TClass(bCls) if (eq(aCls, bCls)):
                            if (Std.is(a, Array)) {
                                var aArray: Array<Dynamic> = cast a;
                                var bArray: Array<Dynamic> = cast b;
                                var len = aArray.length;
                                if (neq(len, bArray.length)) return false;
                                for (i in 0...len) {
                                    stack.push(new Tuple2(aArray[i], bArray[i]));
                                }
                                continue;
                            } else if (Std.is(a, Date)) {
                                var aDate: Date = cast a;
                                var bDate: Date = cast b;
                                if (neq(aDate.getTime(), bDate.getTime())) return false;
                                continue;
                            } else if (Std.is(a, Bytes)) {
                                var aBytes: Bytes = cast a;
                                var bBytes: Bytes = cast b;
                                if (neq(aBytes.length, bBytes.length)) return false;
                                for (i in 0...aBytes.length) {
                                    if (neq(aBytes.get(i), bBytes.get(i))) return false;
                                }
                                continue;
                            } else if (Std.is(a, IMap)) {
                                var aMap: IMap<Dynamic, Dynamic> = cast a;
                                var bMap: IMap<Dynamic, Dynamic> = cast b;
                                var keys = [for (k in aMap.keys()) k];
                                if (neq(keys.length, [for (k in bMap.keys()) k].length)) return false;
                                for (key in keys) {
                                    stack.push(new Tuple2(aMap.get(key), bMap.get(key)));
                                }
                                continue;
                            }
                            // TODO custom class comparator
                        case _:
                            return false;
                    }
                case _:
                    return false;
            }

            var keys = Reflect.fields(a);
            var ignoreKeys = [];
            if (isIterable(a)) {
                if (!isIterable(b)) return false;
                var aIt: Iterator<Dynamic> = cast a.iterator();
                var bIt: Iterator<Dynamic> = cast b.iterator();
                if (isIterator(aIt)) {
                    if (!isIterator(bIt)) return false;
                    while (aIt.hasNext()) {
                        if (!bIt.hasNext()) return false;
                        stack.push(new Tuple2(aIt.next(), bIt.next()));
                    }
                    ignoreKeys = ["iterator"];
                }
            } else if (isIterator(a)) {
                if (!isIterator(b)) return false;
                while (a.hasNext()) {
                    if (!b.hasNext()) return false;
                    stack.push(new Tuple2(a.next(), b.next()));
                }
                ignoreKeys = ["hasNext", "next"];
            }
            if (neq(keys.length, Reflect.fields(b).length)) return false;
            for (k in ignoreKeys) keys.remove(k);
            for (key in keys) {
                if (!Reflect.hasField(b, key)) return false;
                stack.push(new Tuple2(Reflect.field(a, key), Reflect.field(b, key)));
            }
        }

        return true;
    }

    public static function notSame(value1: Dynamic, value2: Dynamic): Bool {
        return !same(value1, value2);
    }

    #if js
    static inline function nonJsObject(x: Dynamic): Bool {
        return JsNative.strictEq(x, null) || JsNative.strictNeq(JsNative.typeof(x), "object");
    }
    #end

    static function isIterable(x: Dynamic): Bool {
        return Reflect.isFunction(Reflect.field(x, "iterator"));
    }

    static inline function isSameIterable(a: Iterable<Dynamic>, b: Iterable<Dynamic>): Bool {
        try {
            var aIt: Iterator<Dynamic> = cast a.iterator();
            var bIt: Iterator<Dynamic> = cast b.iterator();
            while (aIt.hasNext()) {
                if (!bIt.hasNext()) return false;
                if (neq(aIt.next(), bIt.next())) return false;
            }
            return true;
        } catch (e: Dynamic) {
            return false;
        }
    }

    static inline function isIterator(x : Dynamic) {
        return Reflect.isFunction(Reflect.field(x, "next")) && Reflect.isFunction(Reflect.field(x, "hasNext"));
    }

    static inline function isSameIterator(a: Iterator<Dynamic>, b: Iterator<Dynamic>): Bool {
        try {
            while (a.hasNext()) {
                if (!b.hasNext()) return false;
                if (neq(a.next(), b.next())) return false;
            }
            return true;
        } catch (e: Dynamic) {
            return false;
        }
    }
}
