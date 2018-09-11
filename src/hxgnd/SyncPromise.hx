package hxgnd;

import hxgnd.Maybe;
import hxgnd.Result;
import externtype.Mixed2;

class SyncPromise<T> implements IPromise<T> {
    var result: Maybe<Result<T>> = Maybe.empty();
    var onFulfilledHanlders: Array<T -> Void> = [];
    var onRejectedHanlders: Array<Error -> Void> = [];

    #if js
    static function __init__() {
        untyped __js__("{0}.prototype.__proto__ = Promise.prototype", SyncPromise);
    }
    #end

    public function new(executor: (?T -> Void) -> (?Dynamic -> Void) -> Void) {
        // compatible JS Promise
        #if js
        Reflect.setField(this, "catch", catchError);
        #end

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

    function onFulfill(?value: T): Void {
        if (result.nonEmpty()) return;

        result = Maybe.of(Success(value));

        for (f in onFulfilledHanlders) f(value);
        onFulfilledHanlders = null;
        onRejectedHanlders = null;
    }

    function onReject(?error: Dynamic): Void {
        if (result.nonEmpty()) return;

        result = Maybe.of(Failure(error));
        for (f in onRejectedHanlders) f(error);

        onFulfilledHanlders = null;
        onRejectedHanlders = null;
    }

    public function then<TOut>(fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        var promise = new SyncPromise<TOut>(function (_, _) {});

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

    public inline function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return then(null, rejected);
    }

    public static function resolve<T>(?value: T): Promise<T> {
        return new SyncPromise(function (f, _) f(value));
    }

    public static function reject<T>(error: Dynamic): Promise<T> {
        return new SyncPromise(function (_, r) r(error));
    }

    public static inline function all<T>(iterable: Array<Promise<T>>): Promise<Array<T>> {
        return Promise.all(iterable);
    }

    public static inline function race<T>(iterable: Array<Promise<T>>): Promise<T> {
        return Promise.race(iterable);
    }
}
