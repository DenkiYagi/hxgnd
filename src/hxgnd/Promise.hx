package hxgnd;

import externtype.Mixed2;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

@:generic
abstract Promise<T>(IPromise<T>) from IPromise<T> to IPromise<T> {
    public function new(executor: (?T -> Void) -> (?Dynamic -> Void) -> Void): Void {
        #if js
        this = untyped __js__("new Promise({0})", executor);
        #else
        this = new DelayPromise(executor);
        #end
    }

    public inline function then<TOut>(fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return this.then(fulfilled, rejected);
    }

    public inline function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return this.then(null, rejected);
    }

    public static inline function resolve<T>(?value: T): Promise<T> {
        #if js
        return untyped __js__("Promise.resolve({0})", value);
        #else
        return new SyncPromise(function (f, _) {
            return f(value);
        });
        #end
    }

    public static inline function reject<T>(?error: Dynamic): Promise<T> {
        #if js
        return untyped __js__("Promise.reject({0})", error);
        #else
        return new SyncPromise(function (_, f) {
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
            new Promise(function (fulfill, reject) {
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
            new Promise(function (_, _) {});
        } else {
            new Promise(function (fulfill, reject) {
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
                buildBind: buildBind,
                buildReturn: buildReturn
            },
            blockExpr
        );
    }

    #if macro
    static function buildBind(expr: Expr, fn: Expr): Expr {
        return if (unifyPromise(expr)) {
            macro ${expr}.then(${fn});
        } else {
            macro SyncPromise.resolve(${expr}).then(${fn});
        }
    }

    static function buildReturn(expr: Expr): Expr {
        return expr;
    }

    static function unifyPromise(expr: Expr): Bool {
        return Context.unify(Context.typeof(expr), Context.getType("hxgnd.Promise"));
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

        function invoke() {
            try {
                executor(onFulfill, onReject);
            } catch (e: Error) {
                onReject(e);
            } catch (e: Dynamic) {
                #if js
                onReject(new Error(Std.string(e)));
                #else
                onReject(Error.create(e));
                #end
            }
        }

        #if neko
        neko.vm.Thread.create(invoke);
        #else
        haxe.Timer.delay(invoke, 0);
        #end
    }

    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return _then(fulfilled, rejected);
    }

    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return _then(null, rejected);
    }

    inline function _then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        var promise = new DelayPromise<TOut>(function (_, _) {});

        function handleFulfilled(value: T) {
            try {
                var next: Dynamic = (fulfilled: T -> Dynamic)(value);
                if (#if js Std.is(next, js.Promise) #else Std.is(next, IPromise) #end) {
                    next.then(promise.onFulfill, promise.onReject);
                } else {
                    promise.onFulfill(next);
                }
            } catch (e: Error) {
                promise.onReject(e);
            } catch (e: Dynamic) {
                #if js
                promise.onReject(new Error(Std.string(e)));
                #else
                promise.onReject(Error.create(e));
                #end
            }
        }

        function handleRejected(error: Dynamic) {
            try {
                var next: Dynamic = (rejected: Dynamic -> Dynamic)(error);
                if (#if js Std.is(next, js.Promise) #else Std.is(next, IPromise) #end) {
                    next.then(promise.onFulfill, promise.onReject);
                } else {
                    promise.onFulfill(next);
                }
            } catch (e: Error) {
                promise.onReject(e);
            } catch (e: Dynamic) {
                #if js
                promise.onReject(new Error(Std.string(e)));
                #else
                promise.onReject(Error.create(e));
                #end
            }
        }

        if (result.isEmpty()) {
            if (LangTools.nonNull(fulfilled)) onFulfilledHanlders.add(handleFulfilled);
            if (LangTools.nonNull(rejected)) onRejectedHanlders.add(handleRejected);
        } else {
            switch (result.get()) {
                case Success(v): handleFulfilled(v);
                case Failure(e): handleRejected(e);
            }
        }

        return promise;
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