package hxgnd;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end
import extype.Maybe;
import extype.Result;
import extype.extern.Mixed;
import hxgnd.internal.IPromise;
using hxgnd.LangTools;

abstract Promise<T>(IPromise<T>) from IPromise<T> {
    public inline function new(executor: (?T -> Void) -> (?Dynamic -> Void) -> Void) {
        #if js
        // workaround for js__$Boot_HaxeError
        this = untyped __js__("new Promise({0})", function (fulfill, reject) {
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

    public inline function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        #if js
        return if (Std.is(this, js.Promise)) {
            // workaround for js__$Boot_HaxeError
            this.then(
                if (fulfilled.nonNull()) {
                    (function (value) {
                        try {
                            return (fulfilled: T -> Dynamic)(value);
                        } catch (e: Dynamic) {
                            return cast SyncPromise.reject(e);
                        }
                    }: PromiseCallback<T, TOut>);
                } else {
                    null;
                },
                if (rejected.nonNull()) {
                    function (error) {
                        try {
                            return (rejected: Dynamic -> Dynamic)(error);
                        } catch (e: Dynamic) {
                            return SyncPromise.reject(e);
                        }
                    }
                } else {
                    null;
                }
            );
        } else {
            this.then(fulfilled, rejected);
        }
        #else
        return this.then(fulfilled, rejected);
        #end
    }

    public inline function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        #if js
        return if (Std.is(this, js.Promise)) {
            // workaround for js__$Boot_HaxeError
            this.then(null, if (rejected.nonNull()) {
                cast function (error) {
                    try {
                        return (rejected: Dynamic -> Dynamic)(error);
                    } catch (e: Dynamic) {
                        return SyncPromise.reject(e);
                    }
                };
            } else {
                null;
            });
        } else {
            this.catchError(rejected);
        }
        #else
        return this.catchError(rejected);
        #end
    }

    public function finally(onFinally: Void -> Void): Promise<T> {
        return then(
            function (x) { onFinally(); return x; },
            function (e) { onFinally(); return reject(e); }
        );
    }

    public static inline function resolve<T>(?value: T): Promise<T> {
        #if js
        return untyped __js__("Promise.resolve({0})", value);
        #else
        return DelayedPromise.resolve(value);
        #end
    }

    public static inline function reject<T>(?error: Dynamic): Promise<T> {
        #if js
        return untyped __js__("Promise.reject({0})", error);
        #else
        return DelayedPromise.reject(error);
        #end
    }

    #if js
    public static inline function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        return untyped __js__("Promise.all({0})", iterable);
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
        return untyped __js__("Promise.race({0})", iterable);
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
    @:from
    public static inline function fromJsPromise<T>(promise: js.Promise<T>): Promise<T> {
        return cast promise;
    }

    @:to
    public inline function toJsPromise(): js.Promise<T> {
        return cast this;
    }
    #end

    public static macro function compute<T>(blockExpr: Expr): ExprOf<Promise<T>> {
        return Computation.perform(
            {
                keyword: "await",
                buildBind: buildBind,
                buildReturn: buildReturn,
                buildZero: buildZero
            },
            blockExpr
        );
    }

    #if macro
    static function buildBind(expr: Expr, fn: Expr): Expr {
        return if (isPromise(expr)) {
            macro hxgnd.internal.PromiseComputationHelper.implicitCast(${expr}).then(${fn});
        } else {
            macro new hxgnd.SyncPromise(function (f, _) {
                f(${expr});
            }).then(${fn});
        }
    }

    static function buildReturn(expr: Expr): Expr {
        return macro new hxgnd.SyncPromise(function (f, _) {
            f(${expr});
        });
    }

    static function buildZero(): Expr {
        return macro hxgnd.SyncPromise.resolve();
    }

    static function isPromise(expr: Expr): Bool {
        try {
            var type = Context.typeof(expr);
            return switch (type) {
                case TMono(_): false;  // workaround for Promise.compute({ throw xxx; })
                case _: Context.unify(type, Context.getType("hxgnd.Promise"));
            }
        } catch (e: Dynamic) {
            return false;
        }
    }
    #end
}

#if !js
class DelayedPromise<T> implements IPromise<T> {
    var result: Maybe<Result<T>>;
    var onFulfilledHanlders: Delegate<T>;
    var onRejectedHanlders: Delegate<Dynamic>;

    public function new(executor: (?T -> Void) -> (?Dynamic -> Void) -> Void) {
        result = Maybe.empty();
        onFulfilledHanlders = new Delegate();
        onRejectedHanlders = new Delegate();

        try {
            executor(onFulfilled, onRejected);
        } catch (e: Dynamic) {
            onRejected(e);
        }
    }

    function onFulfilled(?value: T): Void {
        if (result.isEmpty()) {
            result = Maybe.of(Success(value));
            onFulfilledHanlders.invokeAsync(value);
            removeAllHandlers();
        }
    }

    function onRejected(?error: Dynamic): Void {
        if (result.isEmpty()) {
            result = Maybe.of(Failure(error));
            onRejectedHanlders.invokeAsync(error);
            removeAllHandlers();
        }
    }

    inline function removeAllHandlers(): Void {
        onFulfilledHanlders.removeAll();
        onRejectedHanlders.removeAll();
    }

    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): DelayedPromise<TOut> {
        return new DelayedPromise<TOut>(function (_fulfill, _reject) {
            var handleFulfilled = if (fulfilled.nonNull()) {
                function transformValue(value: T) {
                    try {
                        var next = (fulfilled: T -> Dynamic)(value);
                        if (Std.is(next, IPromise)) {
                            var nextPromise: Promise<TOut> = cast next;
                            nextPromise.then(_fulfill, _reject);
                        } else {
                            _fulfill(next);
                        }
                    } catch (e: Dynamic) {
                        _reject(e);
                    }
                }
            } else {
                function passValue(value: T) {
                    _fulfill(cast value);
                }
            }

            var handleRejected = if (rejected.nonNull()) {
                function transformError(error: Dynamic) {
                    try {
                        var next = (rejected: Dynamic -> Dynamic)(error);
                        if (Std.is(next, IPromise)) {
                            var nextPromise: Promise<TOut> = cast next;
                            nextPromise.then(_fulfill, _reject);
                        } else {
                            _fulfill(next);
                        }
                    } catch (e: Dynamic) {
                        _reject(e);
                    }
                }
            } else {
                function passError(error: Dynamic) {
                    try {
                        _reject(error);
                    } catch (e: Dynamic) {
                        trace(e);
                    }
                }
            }

            if (result.isEmpty()) {
                onFulfilledHanlders.add(handleFulfilled);
                onRejectedHanlders.add(handleRejected);
            } else {
                switch (result.get()) {
                    case Success(v): handleFulfilled(v);
                    case Failure(e): handleRejected(e);
                }
            }
        });
    }

    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): DelayedPromise<TOut> {
        return then(null, rejected);
    }

    public function finally(onFinally: Void -> Void): DelayedPromise<T> {
        return then(
            function (x) { onFinally(); return x; },
            function (e) { onFinally(); return reject(e); }
        );
    }

    public static function resolve<T>(?value: T): DelayedPromise<T> {
        return new DelayedPromise(function (f, _) f(value));
    }

    public static function reject<T>(error: Dynamic): DelayedPromise<T> {
        return new DelayedPromise(function (_, r) r(error));
    }
}
#end