package hxgnd.internal;

import extype.Tuple;
import extype.Unit;
import extype.Maybe;
import haxe.macro.Context;
import haxe.macro.Expr;
using hxgnd.ArrayTools;

class EnumeratorBuilder {
    static var defaultEnumeratorFields: Map<String, Field>;

    static function __init__() {
        defaultEnumeratorFields = new Map<String, Field>();
        for (expr in [
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
        ]) {
            toField(expr).forEach(function (f) {
                defaultEnumeratorFields.set(f.name, f);
            });
        };
    }

    static function toField(expr: Expr): Maybe<Field> {
        return switch (expr.expr) {
            case EFunction(name, fn):
                if (name == "__new__") name = "new";
                Maybe.of({
                    name: name,
                    access: [APublic],
                    kind: FFun(fn),
                    pos: expr.pos
                });
            case _:
                Maybe.empty();
        }
    }

    public static function build(): Array<Field> {
        var fields = Context.getBuildFields();

        if (Context.getLocalClass().get().superClass == null) {
            var names = fields.map(function (x) return new Tuple2(x.name, new Unit())).toStringMap();
            for (name in defaultEnumeratorFields.keys()) {
                if (!names.exists(name)) fields.push(defaultEnumeratorFields.get(name));
            }
        }

        return fields;
    }
}
