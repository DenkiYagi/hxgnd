package hxgnd;

import externtype.Mixed2;

@:generic
abstract Promise<T>(IPromise<T>) from IPromise<T> {
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
        return DelayPromise.resolve(value);
        #end
    }

    public static inline function reject<T>(error: Dynamic): Promise<T> {
        #if js
        return js.Promise.reject(error);
        #else
        return DelayPromise.reject(error);
        #end
    }

    public static inline function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        #if js
        return cast js.Promise.all(iterable);
        #else
        return DelayPromise.all(iterable);
        #end
    }

    public static inline function race<T>(iterable: Array<Promise<T>>): Promise<T> {
        #if js
        return cast js.Promise.race(iterable);
        #else
        return DelayPromise.race(iterable);
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
    var result: Maybe<Result<T>> = Maybe.empty();
    var onFulfilledHanlders: Array<T -> Void> = [];
    var onRejectedHanlders: Array<Error -> Void> = [];

    public function new(executor: (T -> Void) -> (Dynamic -> Void) -> Void): Void {
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

    function onFulfill(value: T): Void {
        if (result.nonEmpty()) return;

        result = Maybe.of(Result.Success(value));

        for (f in onFulfilledHanlders) f(value);
        onFulfilledHanlders = null;
        onRejectedHanlders = null;
    }

    function onReject(error: Dynamic): Void {
        if (result.nonEmpty()) return;

        result = Maybe.of(Result.Failure(error));
        for (f in onRejectedHanlders) f(error);

        onFulfilledHanlders = null;
        onRejectedHanlders = null;
    }

    public function then<TOut>(fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        var promise = new DelayPromise<TOut>(function (_, _) {});

        function handleFulfilled(value: T) {
            try {
                var next = (fulfilled: T -> Dynamic)(value);
                if (#if js Std.is(next, js.Promise) #else Std.is(next, IPromise) #end) {
                    var nextPromise: Thenable<TOut> = cast next;
                    nextPromise.then(promise.onFulfill, promise.onReject);
                } else {
                    promise.onFulfill(next);
                }
            } catch (e: Error) {
                promise.onReject(e);
            } catch (e: Dynamic) {
                promise.onReject(new Error(Std.string(e)));
            }
        }

        function handleRejected(error: Dynamic) {
            try {
                var next = (rejected: Dynamic -> Dynamic)(error);
                if (#if js Std.is(next, js.Promise) #else Std.is(next, IPromise) #end) {
                    var nextPromise: Thenable<TOut> = cast next;
                    nextPromise.then(promise.onFulfill, promise.onReject);
                } else {
                    promise.onFulfill(next);
                }
            } catch (e: Error) {
                promise.onReject(e);
            } catch (e: Dynamic) {
                promise.onReject(new Error(Std.string(e)));
            }
        }

        if (result.isEmpty()) {
            if (LangTools.nonNull(fulfilled)) onFulfilledHanlders.push(handleFulfilled);
            if (LangTools.nonNull(rejected)) onRejectedHanlders.push(handleRejected);
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

    public static function resolve<T>(?value: T): Promise<T> {
        return new DelayPromise(function (f, _) {
            return f(value);
        });
    }

    public static function reject<T>(error: Dynamic): Promise<T> {
        return new DelayPromise(function (_, f) {
            return f(error);
        });
    }

    public static function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        var length = iterable.length;
        return if (length <= 0) {
            Promise.resolve([]);
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
    }

    public static function race<T>(iterable: Array<Promise<T>>): Promise<T> {
        return if (iterable.length <= 0) {
            new Promise(function (_, _) {});
        } else {
            new Promise(function (fulfill, reject) {
                for (p in iterable) {
                    p.then(fulfill, reject);
                }
            });
        }
    }
}
#end