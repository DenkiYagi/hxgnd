package hxgnd.js;

import js.Promise;
import hxgnd.Maybe;
import hxgnd.Result;
import haxe.extern.EitherType;

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

        result = Maybe.of(Failed(error));

        for (f in onRejectedHanlders) f(error);
        onFulfilledHanlders = null;
        onRejectedHanlders = null;
    }

    public function then<TOut>(fulfilled: Null<PromiseCallback<T, TOut>>, 
            ?rejected: EitherType<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): PromiseLike<TOut> {
        var promise = new PromiseLike<TOut>(function (_, _) {});

        function handleFulfilled(value: T) {
            var callback: T -> Dynamic = cast fulfilled;
            try {
                promise.onFulfill(callback(value));
            } catch (e: Dynamic) {
                promise.onReject(e);
            }
        }

        function handleRejected(error: Dynamic) {
            var callback: Dynamic -> Dynamic = cast rejected;
            try {
                promise.onFulfill(callback(error));
            } catch (e: Dynamic) {
                promise.onReject(e);
            }
        }
        
        if (result.isEmpty()) {
            if (LangTools.nonNull(fulfilled)) onFulfilledHanlders.push(handleFulfilled);
            if (LangTools.nonNull(rejected)) onRejectedHanlders.push(handleRejected);
        } else {
            switch (result.getOrNull()) {
                case Success(v): handleFulfilled(v);
                case Failed(e): handleRejected(e);
            }
        }

        return promise;
    }

    public function catchError<TOut>(rejected: EitherType<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): PromiseLike<TOut> {
        return then(null, rejected);
    }

    public function toPromise(native = false): Promise<T> {
        if (native) {
            return new Promise(function (resolve, reject) {
                then(resolve, reject);
            });
        } else {
            Reflect.setField(this, "catch", catchError);
            return cast this;
        }
    }

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
