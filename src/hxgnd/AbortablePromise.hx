package hxgnd;

import hxgnd.Maybe;
import hxgnd.Result;
import externtype.Mixed2;
using hxgnd.LangTools;

class AbortablePromise<T> implements IPromise<T> {
    var result: Maybe<Result<T>>;
    var onFulfilledHanlders: Delegate<T>;
    var onRejectedHanlders: Delegate<Dynamic>;
    var abortCallback: Void -> Void;

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

        Dispatcher.dispatch(function exec() {
            inline function removeAllHandlers(): Void {
                onFulfilledHanlders.removeAll();
                onRejectedHanlders.removeAll();
            }

            function fulfill(?value: T): Void {
                if (result.isEmpty()) {
                    result = Maybe.of(Result.Success(value));
                    onFulfilledHanlders.invoke(value);
                    removeAllHandlers();
                }
            }

            function reject(?error: Dynamic): Void {
                if (result.isEmpty()) {
                    result = Maybe.of(Result.Failure(error));
                    onRejectedHanlders.invoke(error);
                    removeAllHandlers();
                }
            }

            try {
                abortCallback = executor(fulfill, reject);
            } catch (e: Dynamic) {
                reject(e);
            }
        });
    }

    public function then<TOut>(
            fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut> {
        return new SyncPromise<TOut>(function (_fulfill, _reject) {
            var handleFulfilled = if (fulfilled.nonNull()) {
                function chain(value: T) {
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
                function rescue(error: Dynamic) {
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

    /**
     * Abort this task.
     */
    public function abort(): Void {
        if (result.isEmpty()) {
            abortCallback();
        }
    }
}