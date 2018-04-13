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
    #if js
    var async: Bool;
    #elseif neko
    var thread: Thread;
    #end

    public function new(executor: FutureContext<T> -> Void, async: Bool = true) {
        isActive = true;
        result = Maybe.empty();
        context = {
            fulfill: fulfill,
            reject: reject,
            onAbort: null
        };
        handlers = [];

        inline function invoke() {
            if (result.nonEmpty()) return; //when already aborted

            try {
                executor(context);
            } catch (e: Dynamic) {
                onProcessed(Failed(e));
            }
        }

        #if js
        if (async) {
            setImmediate(function () invoke());
        } else {
            invoke();
        }
        #elseif neko
        if (async) {
            thread = Thread.create(function () invoke());
        } else {
            invoke();
        }
        #else
        invoke();
        #end
    }

    function fulfill(value: T): Void {
        #if js
        if (async) {
            setImmediate(function () onProcessed(Success(value)));
        } else {
            onProcessed(Success(value));
        }
        #else
        onProcessed(Success(value));
        #end
    }

    function reject(error: Dynamic): Void {
        #if js
        if (async) {
            setImmediate(function () onProcessed(Failed(error)));
        } else {
            onProcessed(Failed(error));
        }
        #else
        onProcessed(Failed(error));
        #end
    }

    inline function onProcessed(x: Result<T>) {
        if (result.nonEmpty()) return;

        result = Maybe.of(x);
        isActive = false;

        for (f in handlers) f(x);

        handlers = null;
        context = null;
    }

    public function then(handler: Result<T> -> Void): Void {
        if (result.isEmpty()) {
            handlers.push(handler);
        } else {
            inline function dispatch() {
                handler(result.getOrNull());
            }
            #if js
            if (async) {
                setImmediate(function () dispatch());
            } else {
                dispatch();
            }
            #else
            dispatch();
            #end
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
        if (result.nonEmpty()) return;

        if (context.onAbort.nonNull()) {
            context.onAbort();
        }
        onProcessed(Failed(new AbortError("aborted")));
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
}

typedef FutureContext<T> = {
    function fulfill(value: T): Void;
    function reject(error: Dynamic): Void;
    dynamic function onAbort(): Void;
}
