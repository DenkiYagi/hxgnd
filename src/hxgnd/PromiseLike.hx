package hxgnd;

import hxgnd.Maybe;
import hxgnd.Result;
import externtype.Mixed2;
#if js
import externtype.Mixed3;
#end

class PromiseLike<T> {
    public var result(default, null): Maybe<Result<T>> = Maybe.empty();

    var onFulfilledHanlders: Array<T -> Void> = [];
    var onRejectedHanlders: Array<Dynamic -> Void> = [];

    public function new(executor: (T -> Void) -> (Dynamic -> Void) -> Void) {
        try {
            executor(onFulfill, onReject);
        } catch (e: Dynamic) {
            onReject(e);
        }
    }

    function onFulfill(value: T): Void {
        if (result.nonEmpty()) return;

        result = Maybe.of(Success(value));

        for (f in onFulfilledHanlders) f(value);
        onFulfilledHanlders = null;
        onRejectedHanlders = null;
    }

    function onReject(error: Dynamic): Void {
        if (result.nonEmpty()) return;

        result = Maybe.of(Failure(error));

        for (f in onRejectedHanlders) f(error);
        onFulfilledHanlders = null;
        onRejectedHanlders = null;
    }

    public function then<TOut>(fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): PromiseLike<TOut> {
        var promise = new PromiseLike<TOut>(function (_, _) {});

        function handleFulfilled(value: T) {
            var callback: T -> Dynamic = cast fulfilled;
            try {
                var next = callback(value);
                if (Std.is(next, PromiseLike) #if js || Std.is(next, js.Promise) #end) {
                    var nextPromise: Thenable<TOut> = cast next;
                    nextPromise.then(promise.onFulfill, promise.onReject);
                } else {
                    promise.onFulfill(next);
                }
            } catch (e: Dynamic) {
                promise.onReject(e);
            }
        }

        function handleRejected(error: Dynamic) {
            var callback: Dynamic -> Dynamic = cast rejected;
            try {
                var next = callback(error);
                if (Std.is(next, PromiseLike) #if js || Std.is(next, js.Promise) #end) {
                    var nextPromise: Thenable<TOut> = cast next;
                    nextPromise.then(promise.onFulfill, promise.onReject);
                } else {
                    promise.onFulfill(next);
                }
            } catch (e: Dynamic) {
                promise.onReject(e);
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

    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): PromiseLike<TOut> {
        return then(null, rejected);
    }

    #if js
    public function toPromise(native = true): js.Promise<T> {
        return if (native) {
            new js.Promise(function (resolve, reject) {
                then(resolve, reject);
            });
        } else {
            Reflect.setField(this, "catch", catchError);
            cast this;
        }
    }
    #end

    public static function resolve<T>(?value: T): PromiseLike<T> {
        return new PromiseLike(function (f, _) {
            return f(value);
        });
    }

    public static function reject(error: Dynamic): PromiseLike<Void> {
        return new PromiseLike(function (_, f) {
            return f(error);
        });
    }
}

#if js
typedef PromiseCallback<T, TOut> = Mixed3<T -> TOut, T -> PromiseLike<TOut>, T -> js.Promise<TOut>>;
#else
typedef PromiseCallback<T, TOut> = Mixed2<T -> TOut, T -> PromiseLike<TOut>>;
#end