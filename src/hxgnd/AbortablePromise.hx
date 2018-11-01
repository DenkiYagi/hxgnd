package hxgnd;

import hxgnd.internal.IPromise;
import extype.Maybe;
import extype.Result;
import extype.extern.Mixed;
#if js
import hxgnd.js.JsObject;
import hxgnd.js.JsNative;
#end
using hxgnd.LangTools;

class AbortablePromise<T> implements IPromise<T> {
    var result: Maybe<Result<T>>;
    var onFulfilledHanlders: Delegate<T>;
    var onRejectedHanlders: Delegate<Dynamic>;
    var abortCallback: Maybe<Void -> Void>;

    #if js
    static function __init__() {
        // Make this class compatible with js.Promise
        var prototype = JsObject.create(untyped js.Promise.prototype);
        var orignal = untyped AbortablePromise.prototype;
        for (k in JsObject.getOwnPropertyNames(orignal)) {
            Reflect.setField(prototype, k, Reflect.field(orignal, k));
        }
        prototype.constructor = AbortablePromise;
        Reflect.setField(prototype, "catch", prototype.catchError);
        untyped AbortablePromise.prototype = prototype;
    }
    #end

    public function new(executor: (?T -> Void) -> (?Dynamic -> Void) -> (Void ->Void)) {
        result = Maybe.empty();
        onFulfilledHanlders = new Delegate();
        onRejectedHanlders = new Delegate();
        abortCallback = Maybe.empty();

        execute(executor);
    }

    function execute(executor: (?T -> Void) -> (?Dynamic -> Void) -> (Void ->Void)): Void {
        if (result.isEmpty()) {
            try {
                abortCallback = Maybe.ofNullable(executor(onFulfilled, onRejected));
            } catch (e: Dynamic) {
                onRejected(e);
            }
        }
    }

    function onFulfilled(?value: T): Void {
        if (result.isEmpty()) {
            result = Maybe.of(Result.Success(value));
            onFulfilledHanlders.invokeAsync(value);
            removeAllHandlers();
        }
    }

    function onRejected(?error: Dynamic): Void {
        if (result.isEmpty()) {
            result = Maybe.of(Result.Failure(error));
            onRejectedHanlders.invokeAsync(error);
            removeAllHandlers();
        }
    }

    inline function removeAllHandlers(): Void {
        onFulfilledHanlders.removeAll();
        onRejectedHanlders.removeAll();
    }

    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): AbortablePromise<TOut> {
        return new AbortablePromise<TOut>(function (_fulfill, _reject) {
            var handleFulfilled = if (fulfilled.nonNull()) {
                function chain(value: T) {
                    try {
                        var next = (fulfilled: T -> Dynamic)(value);
                        if (#if js JsNative.instanceof(next, js.Promise) || #end Std.is(next, IPromise)) {
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
                function rescue(error: Dynamic) {
                    try {
                        var next = (rejected: Dynamic -> Dynamic)(error);
                        if (#if js JsNative.instanceof(next, js.Promise) || #end Std.is(next, IPromise)) {
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
                    case Success(v): Dispatcher.dispatch(handleFulfilled.bind(v));
                    case Failure(e): Dispatcher.dispatch(handleRejected.bind(e));
                }
            }
            return abort;
        });
    }

    public function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): AbortablePromise<TOut> {
        return then(null, rejected);
    }

    public function finally(onFinally: Void -> Void): AbortablePromise<T> {
        return then(
            function (x) { onFinally(); return x; },
            function (e) { onFinally(); return reject(e); }
        );
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
            onRejected(new AbortedError("aborted"));
        }
    }

    public static function resolve<T>(?value: T): AbortablePromise<T> {
        return new AbortablePromise(function (f, _) {
            f(value);
            return null;
        });
    }

    public static function reject<T>(error: Dynamic): AbortablePromise<T> {
        return new AbortablePromise(function (_, r) {
            r(error);
            return null;
        });
    }
}
