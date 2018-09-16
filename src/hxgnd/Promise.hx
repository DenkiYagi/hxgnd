package hxgnd;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end
import externtype.Mixed2;
using hxgnd.LangTools;

@:generic
abstract Promise<T>(IPromise<T>) from IPromise<T> to IPromise<T> {
    public function new(executor: (?T -> Void) -> (?Dynamic -> Void) -> Void): Void {
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
        this = new DelayPromise(executor);
        #end
    }

    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        // workaround for js__$Boot_HaxeError
        return this.then(
            if (fulfilled.nonNull()) {
                function (value) {
                    try {
                        return (fulfilled: T -> Dynamic)(value);
                    } catch (e: Dynamic) {
                        return SyncPromise.reject(e);
                    }
                }
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
    }

    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        // workaround for js__$Boot_HaxeError
        return this.then(null, if (rejected.nonNull()) {
            function (error) {
                try {
                    return (rejected: Dynamic -> Dynamic)(error);
                } catch (e: Dynamic) {
                    return SyncPromise.reject(e);
                }
            }
        } else {
            null;
        });
    }

    public static inline function resolve<T>(?value: T): Promise<T> {
        #if js
        return untyped __js__("Promise.resolve({0})", value);
        #else
        return new Promise(function (f, _) {
            return f(value);
        });
        #end
    }

    public static inline function reject<T>(?error: Dynamic): Promise<T> {
        #if js
        return untyped __js__("Promise.reject({0})", error);
        #else
        return new Promise(function (_, f) {
            return f(error);
        });
        #end
    }

    public static function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        #if js
        return untyped __js__("Promise.all({0})", iterable);
        #else
        var length = iterable.length;
        return if (length <= 0) {
            SyncPromise.resolve([]);
        } else {
            new SyncPromise(function (fulfill, reject) {
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
        #end
    }

    public static function race<T>(iterable: Array<Promise<T>>): Promise<T> {
        #if js
        return untyped __js__("Promise.race({0})", iterable);
        #else
        return if (iterable.length <= 0) {
            new SyncPromise(function (_, _) {});
        } else {
            new SyncPromise(function (fulfill, reject) {
                for (p in iterable) {
                    p.then(fulfill, reject);
                }
            });
        }
        #end
    }

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

    public static macro function compute(blockExpr: Expr): Expr {
        return Computation.perform(
            {
                keyword: "await",
                buildBind: buildBind,
                buildReturn: buildReturn
            },
            blockExpr
        );
    }

    #if macro
    static function buildBind(expr: Expr, fn: Expr): Expr {
        return if (isUnifiable(expr)) {
            macro ${expr}.then(${fn});
        } else {
            macro SyncPromise.resolve(${expr}).then(${fn});
        }
    }

    static function buildReturn(expr: Expr): Expr {
        return if (isUnifiable(expr)) {
            expr;
        } else {
            macro new SyncPromise(function (f, _) {
                f(${expr});
            });
        }
    }

    static function isUnifiable(expr: Expr): Bool {
        var type = Context.typeof(expr);
        return switch (type) {
            case TMono(_): false;  // workaround for Promise.compute({ throw xxx; })
            case _: Context.unify(type, Context.getType("hxgnd.Promise"));
        }
    }
    #end
}

#if !js
class DelayPromise<T> implements IPromise<T> {
    var result: Maybe<Result<T>>;
    var onFulfilledHanlders: Delegate<T>;
    var onRejectedHanlders: Delegate<Dynamic>;

    public function new(executor: (?T -> Void) -> (?Dynamic -> Void) -> Void): Void {
        this.result = Maybe.empty();
        this.onFulfilledHanlders = new Delegate();
        this.onRejectedHanlders = new Delegate();

        Dispatcher.dispatch(function exec() {
            try {
                executor(onFulfill, onReject);
            } catch (e: Dynamic) {
                onReject(e);
            }
        });
    }

    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        var promise = new DelayPromise<TOut>(function (_, _) {});

        var handleFulfilled = if (fulfilled.nonNull()) {
            function transformValue(value: T) {
                Dispatcher.dispatch(function () {
                    try {
                        var next = (fulfilled: T -> Dynamic)(value);
                        if (#if js Std.is(next, js.Promise) #else Std.is(next, IPromise) #end) {
                            var nextPromise: Promise<TOut> = cast next;
                            nextPromise.then(promise.onFulfill, promise.onReject);
                        } else {
                            promise.onFulfill(next);
                        }
                    } catch (e: Dynamic) {
                        promise.onReject(e);
                    }
                });
            }
        } else {
            function passValue(value: T) {
                Dispatcher.dispatch(function () {
                    promise.onFulfill(cast value);
                });
            }
        }

        var handleRejected = if (rejected.nonNull()) {
            function transformError(error: Dynamic) {
                Dispatcher.dispatch(function () {
                    try {
                        var next = (rejected: Dynamic -> Dynamic)(error);
                        if (#if js Std.is(next, js.Promise) #else Std.is(next, IPromise) #end) {
                            var nextPromise: Promise<TOut> = cast next;
                            nextPromise.then(promise.onFulfill, promise.onReject);
                        } else {
                            promise.onFulfill(next);
                        }
                    } catch (e: Dynamic) {
                        promise.onReject(e);
                    }
                });
            }
        } else {
            function passError(error: Dynamic) {
                Dispatcher.dispatch(function () {
                    try {
                        promise.onReject(error);
                    } catch (e: Dynamic) {
                        trace(e);
                    }
                });
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

        return promise;
    }

    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return then(null, rejected);
    }

    function onFulfill(?value: T): Void {
        if (result.nonEmpty()) return;

        result = Maybe.of(Result.Success(value));
        onFulfilledHanlders.invoke(value);
        removeAllHandlers();
    }

    function onReject(?error: Dynamic): Void {
        if (result.nonEmpty()) return;

        result = Maybe.of(Result.Failure(error));
        onRejectedHanlders.invoke(error);
        removeAllHandlers();
    }

    inline function removeAllHandlers(): Void {
        onFulfilledHanlders.removeAll();
        onRejectedHanlders.removeAll();
    }

    public static inline function resolve<T>(?value: T): Promise<T> {
        return Promise.resolve(value);
    }

    public static inline function reject<T>(?error: Dynamic): Promise<T> {
        return Promise.reject(error);
    }

    public static inline function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        return Promise.all(iterable);
    }

    public static inline function race<T>(iterable: Array<Promise<T>>): Promise<T> {
        return Promise.race(iterable);
    }
}
#end