package hxgnd;

import hxgnd.Result;
import hxgnd.PromiseLike;
#if js
import hxgnd.js.JsNative.setImmediate;
#end
#if neko
import neko.vm.Thread;
#end
using hxgnd.LangTools;

class Future<T> {
    public var isActive(default, null): Bool;
    public var result(default, null): Maybe<Result<T>>;

    var context: FutureContext<T>;
    var handlers: Array<Result<T> -> Void>;

    function new(result: Maybe<Result<T>>) {
        this.result = result;
        if (result.isEmpty()) {
            isActive = true;
            handlers = [];
            context = {
                successful: _successful,
                failed: _failed,
                onAbort: null
            }
        } else {
            isActive = false;
        }
    }

    inline function invoke(executor: FutureContext<T> -> Void) {
        try {
            executor(context);
        } catch (e: Dynamic) {
            finish(Failed(e));
        }
    }

    inline function finish(x: Result<T>) {
        if (result.nonEmpty()) return;

        result = Maybe.of(x);
        isActive = false;

        for (f in handlers) f(x);

        handlers = null;
        context = null;
    }

    function _successful(value: T): Void {
        finish(Success(value));
    }

    function _failed(error: Dynamic): Void {
        finish(Failed(error));
    }

    public function then(handler: Result<T> -> Void): Void {
        if (isActive) {
            handlers.push(handler);
        } else {
            handler(result.getOrNull());
        }
    }

    // recover

    // public function map<U>(): Future<U> {
    //     return null;
    // }

    // public function flatMap<U>(): Future<U> {
    //     return null;
    // }

    public function abort(): Void {
        if (!isActive) return;

        if (context.onAbort.nonNull()) {
            context.onAbort();
        }
        finish(Failed(new AbortError("aborted")));
    }

    #if js
    public function toPromise(native = true): js.Promise<T> {
        return if (native) {
            new js.Promise(function (resolve, reject) {
                then(function (result) {
                    switch (result) {
                        case Success(v): resolve(v);
                        case Failed(e): reject(e);
                    }
                });
            });
        } else {
            new PromiseLike(function (resolve, reject) {
                then(function (result) {
                    switch (result) {
                        case Success(v): resolve(v);
                        case Failed(e): reject(e);
                    }
                });
            }).toPromise(false);
        }
    }
    #end

    public inline static function apply<T>(executor: FutureContext<T> -> Void): Future<T> {
        var future = new Future(Maybe.empty());
        #if js
        setImmediate(future.invoke.bind(executor));
        #else
        Thread.create(future.invoke.bind(executor));
        #end
        return future;
    }

    public inline static function applySync<T>(executor: FutureContext<T> -> Void): Future<T> {
        var future = new Future(Maybe.empty());
        future.invoke(executor);
        return future;
    }

    public static inline function successful<T>(?value: T): Future<T> {
        return new Future(Maybe.of(Success(value)));
    }

    public static inline function failed<T>(error: Dynamic): Future<T> {
        return new Future(Maybe.of(Failed(error)));
    }

    public static inline function processed<T>(result: Result<T>): Future<T> {
        return new Future(Maybe.of(result));
    }
}

typedef FutureContext<T> = {
    function successful(value: T): Void;
    function failed(error: Dynamic): Void;
    dynamic function onAbort(): Void;
}
