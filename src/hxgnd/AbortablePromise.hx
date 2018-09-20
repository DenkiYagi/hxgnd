package hxgnd;

import hxgnd.Maybe;
import hxgnd.Result;
import externtype.Mixed2;
using hxgnd.LangTools;

class AbortablePromise<T> implements IPromise<T> {
    var result: Maybe<Result<T>>;
    var onFulfilledHanlders: Delegate<T>;
    var onRejectedHanlders: Delegate<Dynamic>;
    var abortCallback: Maybe<Void -> Void>;

    #if js
    static function __init__() {
        untyped __js__("{0}.prototype.__proto__ = Promise.prototype", AbortablePromise);
    }
    #end

    public function new(executor: (?T -> Void) -> (?Dynamic -> Void) -> (Void ->Void)) {
        // compatible JS Promise
        #if js
        Reflect.setField(this, "catch", catchError);
        #end

        result = Maybe.empty();
        onFulfilledHanlders = new Delegate();
        onRejectedHanlders = new Delegate();
        abortCallback = Maybe.empty();

        Dispatcher.dispatch(function exec() {
            try {
                abortCallback = Maybe.ofNullable(executor(onFulfilled, onRejected));
            } catch (e: Dynamic) {
                onRejected(e);
            }
        });
    }

    function onFulfilled(?value: T): Void {
        if (result.isEmpty()) {
            result = Maybe.of(Result.Success(value));
            onFulfilledHanlders.invoke(value);
            removeAllHandlers();
        }
    }

    function onRejected(?error: Dynamic): Void {
        if (result.isEmpty()) {
            result = Maybe.of(Result.Failure(error));
            onRejectedHanlders.invoke(error);
            removeAllHandlers();
        }
    }

    inline function removeAllHandlers(): Void {
        onFulfilledHanlders.removeAll();
        onRejectedHanlders.removeAll();
    }

    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return new SyncPromise<TOut>(function (_fulfill, _reject) {
            var handleFulfilled = if (fulfilled.nonNull()) {
                function chain(value: T) {
                    Dispatcher.dispatch(function () {
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
                    });
                }
            } else {
                function passValue(value: T) {
                    Dispatcher.dispatch(function () {
                        _fulfill(cast value);
                    });
                }
            }

            var handleRejected = if (rejected.nonNull()) {
                function rescue(error: Dynamic) {
                    Dispatcher.dispatch(function () {
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
                    });
                }
            } else {
                function passError(error: Dynamic) {
                    Dispatcher.dispatch(function () {
                        try {
                            _reject(error);
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
        });
    }

    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return then(null, rejected);
    }

    /**
     * Abort this promise.
     */
    public function abort(): Void {
        if (result.isEmpty()) {
            if (abortCallback.nonEmpty()) {
                var fn = abortCallback.get();
                abortCallback = Maybe.empty();
                fn();
            }
            onRejected(new AbortError("aborted"));
        }
    }

    public static function resolve<T>(?value: T): AbortablePromise<T> {
        return new AbortablePromise(function (f, _) {
            f(value);
            return LangTools.emptyFunction;
        });
    }

    public static function reject<T>(error: Dynamic): AbortablePromise<T> {
        return new AbortablePromise(function (_, r) {
            r(error);
            return LangTools.emptyFunction;
        });
    }
}