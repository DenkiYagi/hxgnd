package hxgnd.internal;

import extype.Tuple;
import haxe.macro.Context;
import haxe.macro.Expr;
using hxgnd.ArrayTools;

class EnumeratorBuilder {
    static var defaultFields: Map<String, Field>;

    static function __init__() {
        defaultFields = toFieldMap([
            macro function forEach(fn: T -> Void): Void {
                source.forEach(fn);
            },

            macro function forEachWhile(fn: T -> Bool): Void {
                source.forEachWhile(fn);
            },

            macro function map<U>(fn: T -> U): Enumerable<U> {
                return new MapEnumerator(this, Pipeline.from(fn));
            },

            macro function flatMap<U>(fn: T -> Enumerable<U>): Enumerable<U> {
                return new FlattenEnumerator(new MapEnumerator(this, Pipeline.from(fn)), Pipeline.empty());
            },

            macro function filter(fn: T -> Bool): Enumerable<T> {
                return new FilterEnumerator(this, [fn]);
            },

            macro function take(count: Int): Enumerable<T> {
                return new TaskEnumerator(this, count);
            },

            macro function takeWhile(fn: T -> Bool): Enumerable<T> {
                return new TaskWhileEnumerator(this, fn);
            },

            macro function skip(count: Int): Enumerable<T> {
                return new SkipEnumerator(this, count);
            },

            macro function skipWhile(fn: T -> Bool): Enumerable<T> {
                return new SkipWhileEnumerator(this, fn);
            },





            macro function toArray(): Array<T> {
                var array = [];
                this.forEach(array.push);
                return array;
            }
        ]);
    }

    static function toFieldMap(exprs: Array<Expr>): Map<String, Field> {
        var map = new Map<String, Field>();

        for (expr in exprs) {
            switch (expr.expr) {
                case EFunction(name, fn):
                    map.set(name, {
                        name: name,
                        access: [APublic],
                        kind: FFun(fn),
                        pos: expr.pos
                    });
                case _:
            }
        }

        return map;
    }

    public static function build(): Array<Field> {
        var fields = Context.getBuildFields();

        if (Context.getLocalClass().get().superClass == null) {
            var names = fields.map(function (x) return new Tuple2(x.name, new extype.Unit())).toStringMap();
            for (name in defaultFields.keys()) {
                if (!names.exists(name)) fields.push(defaultFields.get(name));
            }
        }

        return fields;
    }
}
