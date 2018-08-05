package hxgnd;

import externtype.Mixed2;

@:generic
abstract Promise<T>(IPromise<T>) from IPromise<T> to IPromise<T> {
    public function new(executor: (T -> Void) -> (Dynamic -> Void) -> Void): Void {
        #if js
        this = cast new js.Promise(executor);
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
        return js.Promise.resolve(value);
        #else
        return new SyncPromise(function (f, _) {
            return f(value);
        });
        #end
    }

    public static inline function reject<T>(error: Dynamic): Promise<T> {
        #if js
        return js.Promise.reject(error);
        #else
        return new SyncPromise(function (_, f) {
            return f(error);
        });
        #end
    }

    public static function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        #if js
        return cast js.Promise.all(iterable);
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
        return cast js.Promise.race(iterable);
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
}

#if !js
class DelayPromise<T> implements IPromise<T> {
    var result: Maybe<Result<T>>;
    var onFulfilledHanlders: Delegate<T>;
    var onRejectedHanlders: Delegate<Dynamic>;

    public function new(executor: (T -> Void) -> (Dynamic -> Void) -> Void): Void {
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
                var nextValue = (fulfilled: T -> Dynamic)(value);
                if (#if js Std.is(nextValue, js.Promise) #else Std.is(nextValue, IPromise) #end) {
                    var nextPromise: Thenable<TOut> = cast nextValue;
                    nextPromise.then(promise.onFulfill, promise.onReject);
                } else {
                    promise.onFulfill(nextValue);
                }
            } catch (e: Error) {
                promise.onReject(e);
            } catch (e: Dynamic) {
                promise.onReject(new Error(Std.string(e)));
            }
        }

        function handleRejected(error: Dynamic) {
            try {
                var nextValue = (rejected: Dynamic -> Dynamic)(error);
                if (#if js Std.is(nextValue, js.Promise) #else Std.is(nextValue, IPromise) #end) {
                    var nextPromise: Thenable<TOut> = cast nextValue;
                    nextPromise.then(promise.onFulfill, promise.onReject);
                } else {
                    promise.onFulfill(nextValue);
                }
            } catch (e: Error) {
                promise.onReject(e);
            } catch (e: Dynamic) {
                promise.onReject(new Error(Std.string(e)));
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

    function onFulfill(value: T): Void {
        if (result.nonEmpty()) return;

        result = Maybe.of(Result.Success(value));
        onFulfilledHanlders.invoke(value);
        removeAllHandlers();
    }

    function onReject(error: Dynamic): Void {
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

    public static inline function reject<T>(error: Dynamic): Promise<T> {
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