package hxgnd;

using hxgnd.LangTools;
#if neko
using neko.vm.Lock;
using neko.vm.Thread;
#end

class Stream<T> {
    public var isActive(default, null): Bool;

    var middleware: StreamMiddleware<T>;
    var subscribers: Array<StreamSubscriber<T>>;
    var context: StreamContext<T>;
    #if neko
    var lock = new Lock();
    var thread: Thread;
    #end

    public function new(middleware: StreamMiddleware<T>) {
        this.middleware = middleware;
        subscribers = [];
        context = { emit: emit, onStop: null };
        isActive = true;
        
        #if js
        hxgnd.js.JsNative.setImmediate(middleware.bind(context));
        #else
        thread = Thread.create(function () {
            lock.wait();
            middleware(context);
        });
        lock.release();
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

    public function stop(): Void {
        if (!isActive) return;
        
        var stopped = emit.bind(End);
        if (context.onStop.nonNull()) {
            context.onStop(stopped);
        } else {
            stopped();
        }
    }

    function emit(value: StreamEvent<T>): Void {
        if (!isActive) return;

        var _subscribers = this.subscribers;
        switch (value) {
            case End: 
                isActive = false;
                middleware = null;
                subscribers = null;
                context = null;
            case _:
        }
        for (fn in _subscribers) fn(value);
    }
}

typedef StreamContext<T> = {
    function emit(value: StreamEvent<T>): Void;
    dynamic function onStop(done: Void -> Void): Void; 
}

typedef StreamMiddleware<T> = StreamContext<T> -> Void;
typedef StreamSubscriber<T> = StreamEvent<T> -> Void;

enum StreamEvent<T> {
    Data(x: T);
    End;
}
