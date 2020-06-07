package hxgnd;

import extype.extern.Mixed;
import hxgnd.internal.IPromise;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import hxgnd.internal.MacroTools;
#end
#if !js
import hxgnd.internal.DelayedPromise;
#end
using hxgnd.LangTools;

abstract Promise<T>(IPromise<T>) from IPromise<T> {
    public inline function new(executor: (?T -> Void) -> (?Dynamic -> Void) -> Void) {
        #if js
        // workaround for js__$Boot_HaxeError
        this = js.Syntax.code("new Promise({0})", function (fulfill, reject) {
            try {
                executor(fulfill, reject);
            } catch (e: Dynamic) {
                reject(e);
            }
        });
        #else
        this = new DelayedPromise(executor);
        #end
    }

    #if js
    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        // workaround for js__$Boot_HaxeError
        return if (Std.is(this, js.lib.Promise)) {
            this.then(
                fulfilled.nonNull() ? onFulfilled.bind(fulfilled) : null,
                rejected.nonNull() ? onRejected.bind(cast rejected) : null
            );
        } else {
            this.then(fulfilled, rejected);
        }
    }
    #else
    public inline function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return this.then(fulfilled, rejected);
    }
    #end

    #if js
    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        // workaround for js__$Boot_HaxeError
        return if (rejected.nonNull() && Std.is(this, js.lib.Promise)) {
            this.then(null, onRejected.bind(cast rejected));
        } else {
            this.catchError(rejected);
        }
    }
    #else
    public inline function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return this.catchError(rejected);
    }
    #end

    #if js
    static function onFulfilled<T, TOut>(fulfilled: T -> Dynamic, value: T): Promise<TOut> {
        try {
            return fulfilled(value);
        } catch (e: Dynamic) {
            return cast SyncPromise.reject(e);
        }
    }

    static function onRejected<TOut>(rejected: Dynamic -> Dynamic, error: Dynamic): Promise<TOut> {
        try {
            return rejected(error);
        } catch (e: Dynamic) {
            return SyncPromise.reject(e);
        }
    }
    #end

    public inline function finally(onFinally: Void -> Void): Promise<T> {
        #if js
        return then(
            function (x) { onFinally(); return x; },
            function (e) { onFinally(); return reject(e); }
        );
        #else
        return this.finally(onFinally);
        #end
    }

    public static inline function resolve<T>(?value: T): Promise<T> {
        #if js
        return js.Syntax.code("Promise.resolve({0})", value);
        #else
        return DelayedPromise.resolve(value);
        #end
    }

    public static inline function reject<T>(?error: Dynamic): Promise<T> {
        #if js
        return js.Syntax.code("Promise.reject({0})", error);
        #else
        return DelayedPromise.reject(error);
        #end
    }

    #if js
    public static inline function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        return js.Syntax.code("Promise.all({0})", iterable);
    }
    #else
    public static function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        var length = iterable.length;
        return if (length <= 0) {
            DelayedPromise.resolve([]);
        } else {
            new DelayedPromise(function (fulfill, reject) {
                var values = [for (i in 0...length) null];
                var count = 0;
                for (i in 0...length) {
                    var p = iterable[i];
                    p.then(function (v) {
                        values[i] = v;
                        if (++count >= length) fulfill(values);
                    }, reject);
                }
            });
        }
    }
    #end

    #if js
    public static inline function race<T>(iterable: Array<Promise<T>>): Promise<T> {
        return js.Syntax.code("Promise.race({0})", iterable);
    }
    #else
    public static function race<T>(iterable: Array<Promise<T>>): Promise<T> {
        return if (iterable.length <= 0) {
            new DelayedPromise(function (_, _) {});
        } else {
            new DelayedPromise(function (fulfill, reject) {
                for (p in iterable) {
                    p.then(fulfill, reject);
                }
            });
        }
    }
    #end

    #if js
    @:from @:extern
    public static inline function fromJsPromise<T>(promise: js.lib.Promise<T>): Promise<T> {
        return cast promise;
    }

    @:to @:extern
    public inline function toJsPromise(): js.lib.Promise<T> {
        return cast this;
    }
    #end

    public static macro function compute<T>(blockExpr: Expr): ExprOf<Promise<T>> {
        var expr = Computation.perform(
            {
                buildBind: buildBind,
                buildReturn: buildReturn,
                buildZero: buildZero,
                buildWhile: buildWhile,
                buildFor: buildFor,
                buildCombine: buildCombine,
            },
            blockExpr
        );
        // trace(haxe.macro.ExprTools.toString(expr));
        return expr;
    }
    #if macro
    static function buildReturn(expr: Expr): Expr {
        var promise = macro new hxgnd.SyncPromise(function (f, _) f(${expr}));
        return macro hxgnd.internal.PromiseComputationHelper.implicitCast(${promise});
    }

    static function buildZero(): Expr {
        return macro (hxgnd.SyncPromise.resolve(new extype.Unit()): hxgnd.Promise<extype.Unit>);
    }

    static function buildWhile(cond: Expr, body: Expr): Expr {
        return macro (function _while(cond: Void -> Bool, body: Void -> Promise<extype.Unit>): Promise<extype.Unit> {
            return if (cond()) {
                body().then(function (_) return _while(cond, body));
            } else {
                ${buildZero()};
            }
        })(${cond}, ${body});
    }

    static function buildFor(iter: Expr, body: Expr): Expr {
        return macro (function _for(iter, body: Int -> Promise<extype.Unit>): Promise<extype.Unit> {
            return if (iter.hasNext()) {
                body(iter.next()).then(function (_) return _for(iter, body));
            } else {
                ${buildZero()};
            }
        })(${iter}, ${body});
    }

    static function buildBind(m: Expr, fn: Expr): Expr {
        var promise = isPromise(m) ? m : macro new hxgnd.SyncPromise(function (f, _) f(${m}));
        return macro hxgnd.internal.PromiseComputationHelper.implicitCast(${promise}).then(${fn});
    }

    static function isPromise(expr: Expr): Bool {
        try {
            var type = Context.typeof(MacroTools.correctUndefinedVars(expr));
            return Context.unify(type, Context.getType("hxgnd.Promise"));
        } catch (e: Dynamic) {
            return false;
        }
    }

    static function buildCombine(expr1: Expr, expr2: Expr): Expr {
        return macro ${expr1}.then(function (_) {
            return ${expr2};
        });
    }
    #end
}
