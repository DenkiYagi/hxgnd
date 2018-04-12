package hxgnd;

using hxgnd.LangTools;
#if neko
using neko.vm.Thread;
#end

class Stream<T> {
    public var isActive(default, null): Bool;

    var executor: StreamContext<T> -> Void;
    var subscribers: Array<StreamSubscriber<T>>;
    var context: StreamContext<T>;
    #if neko
    var thread: Thread;
    #end

    public function new(executor: StreamContext<T> -> Void) {
        this.executor = executor;
        subscribers = [];
        context = { emit: emit, onAbort: null };
        isActive = true;

        inline function invoke() {
            try {
                executor(context);
            } catch (e: Dynamic) {
                emit(Error(e));
            }
        }

        #if js
        hxgnd.js.JsNative.setImmediate(function () invoke());
        #else
        thread = Thread.create(function () invoke());
        #end
    }

    public function subscribe(fn: StreamSubscriber<T>): Void {
        if (!isActive) return;
        subscribers.push(fn);
    }

    public function unsubscribe(fn: StreamSubscriber<T>): Void {
        if (!isActive) return;
        subscribers.remove(fn);
    }

    public function abort(): Void {
        if (!isActive) return;

        var done = emit.bind(End);
        if (context.onAbort.nonNull()) {
            context.onAbort(done);
        } else {
            done();
        }
    }

    function emit(event: StreamEvent<T>): Void {
        if (!isActive) return;

        inline function cleanup() {
            isActive = false;
            executor = null;
            subscribers = null;
            context = null;
        }

        var _subscribers = this.subscribers;
        switch (event) {
            case End:
                cleanup();
            case Error(e):
                cleanup();
            case _:
        }
        for (fn in _subscribers) fn(event);
    }
}

typedef StreamContext<T> = {
    function emit(event: StreamEvent<T>): Void;
    dynamic function onAbort(done: Void -> Void): Void;
}

typedef StreamSubscriber<T> = StreamEvent<T> -> Void;

enum StreamEvent<T> {
    Data(value: T);
    Error(error: Dynamic);
    End;
}
