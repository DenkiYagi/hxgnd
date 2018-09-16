package hxgnd;

import hxgnd.Maybe;
import hxgnd.Result;
import externtype.Mixed2;
using hxgnd.LangTools;

class SyncPromise<T> implements IPromise<T> {
    var result: Maybe<Result<T>>;
    var onFulfilledHanlders: Delegate<T>;
    var onRejectedHanlders: Delegate<Dynamic>;

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

        this.result = Maybe.empty();
        this.onFulfilledHanlders = new Delegate();
        this.onRejectedHanlders = new Delegate();

        try {
            executor(onFulfill, onReject);
        } catch (e: Dynamic) {
            onReject(e);
        }
    }

    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        var promise = new SyncPromise<TOut>(function (_, _) {});

        var handleFulfilled = if (fulfilled.nonNull()) {
            function transformValue(value: T) {
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
            }
        } else {
            function passValue(value: T) {
                promise.onFulfill(cast value);
            }
        }

        var handleRejected = if (rejected.nonNull()) {
            function transformError(error: Dynamic) {
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
            }
        } else {
            function passError(error: Dynamic) {
                try {
                    promise.onReject(error);
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

        return promise;
    }

    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return then(null, rejected);
    }

    function onFulfill(?value: T): Void {
        if (result.isEmpty()) {
            result = Maybe.of(Success(value));
            onFulfilledHanlders.invoke(value);
            removeAllHandlers();
        }
    }

    function onReject(?error: Dynamic): Void {
        if (result.isEmpty()) {
            result = Maybe.of(Failure(error));
            onRejectedHanlders.invoke(error);
            removeAllHandlers();
        }
    }

    inline function removeAllHandlers(): Void {
        onFulfilledHanlders.removeAll();
        onRejectedHanlders.removeAll();
    }

    public static function resolve<T>(?value: T): Promise<T> {
        return new SyncPromise(function (f, _) f(value));
    }

    public static function reject<T>(error: Dynamic): Promise<T> {
        return new SyncPromise(function (_, r) r(error));
    }
}
