package hxgnd;

import hxgnd.Result;
import hxgnd.PromiseLike;
#if js
import hxgnd.js.JsNative.setImmediate;
#end

class Future<T> {
    public var result(default, null): Maybe<Result<T>> = Maybe.empty();

    var cancellFunc: Maybe<Void -> Thenable<#if js Void #else Unit #end>> = Maybe.empty();
    var handlers: Array<Result<T> -> Void> = [];
    var async: Bool;

    public function new(executor: Executor<T> #if js, async: Bool = true #end) {
        #if js
        this.async = async;
        #else
        this.async = false;
        #end

        inline function invoke() {
            try {
                cancellFunc = executor(onComplete, onAbort);
            } catch (e: Dynamic) {
                onProcess(Failed(e));
            }
        }

        if (async) {
            #if js
            setImmediate(function () invoke());
            #else
            throw "not implemented";
            #end
        } else {
            invoke();
        }
    }

    function onComplete(value: T): Void {
        if (async) {
            #if js
            setImmediate(function () onProcess(Success(value)));
            #else
            throw "not implemented";
            #end
        } else {
            onProcess(Success(value));
        }
    }

    function onAbort(error: Dynamic): Void {
        if (async) {
            #if js
            setImmediate(function () onProcess(Failed(error)));
            #else
            throw "not implemented";
            #end
        } else {
            onProcess(Failed(error));
        }
    }

    inline function onProcess(x: Result<T>) {
        if (result.nonEmpty()) return;

        result = Maybe.of(x);
        for (f in handlers) f(x);
        handlers = null;
        cancellFunc = Maybe.empty();
    }

    public function then(handler: Result<T> -> Void): Void {
        if (result.isEmpty()) {
            handlers.push(handler);
        } else {
            inline function dispatch() {
                handler(result.getOrNull());
            }
            if (async) {
                #if js
                setImmediate(function () dispatch());
                #else
                throw "not implemented";
                #end
            } else {
                dispatch();
            }
        }
    }

    // recover

    // public function map<U>(): Future<U> {
    //     return null;
    // }

    // public function flatMap<U>(): Future<U> {
    //     return null;
    // }

    public function cancel(): Thenable<#if js Void #else Unit #end> {
        #if js
        return if (cancellFunc.nonEmpty()) {
            cancellFunc.getOrNull()();
        } else {
            PromiseLike.resolve();
        }
        #else 
        return if (cancellFunc.nonEmpty()) {
            cancellFunc.getOrNull()();
        } else {
            PromiseLike.resolve(new Unit());
        }
        #end
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

typedef Executor<T> = (T -> Void) -> (Dynamic -> Void) -> (Void -> Thenable<#if js Void #else Unit #end>);
