package hxgnd;

import hxgnd.Maybe;
import hxgnd.Result;
import externtype.Mixed;
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

        result = Maybe.empty();
        onFulfilledHanlders = new Delegate();
        onRejectedHanlders = new Delegate();

        inline function removeAllHandlers(): Void {
            onFulfilledHanlders.removeAll();
            onRejectedHanlders.removeAll();
        }

        function fulfill(?value: T): Void {
            if (result.isEmpty()) {
                result = Maybe.of(Success(value));
                onFulfilledHanlders.invoke(value);
                removeAllHandlers();
            }
        }

        function reject(?error: Dynamic): Void {
            if (result.isEmpty()) {
                result = Maybe.of(Failure(error));
                onRejectedHanlders.invoke(error);
                removeAllHandlers();
            }
        }

        try {
            executor(fulfill, reject);
        } catch (e: Dynamic) {
            reject(e);
        }
    }

    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return new SyncPromise<TOut>(function (_fulfill, _reject) {
            var handleFulfilled = if (fulfilled.nonNull()) {
                function transformValue(value: T) {
                    try {
                        var next = (fulfilled: T -> Dynamic)(value);
                        if (#if js Std.is(next, js.Promise) #else Std.is(next, IPromise) #end) {
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
                        if (#if js Std.is(next, js.Promise) #else Std.is(next, IPromise) #end) {
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

    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return then(null, rejected);
    }

    public static function resolve<T>(?value: T): SyncPromise<T> {
        return new SyncPromise(function (f, _) f(value));
    }

    public static function reject<T>(error: Dynamic): SyncPromise<T> {
        return new SyncPromise(function (_, r) r(error));
    }
}
