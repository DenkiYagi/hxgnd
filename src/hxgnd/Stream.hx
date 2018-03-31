package hxgnd;

using hxgnd.LangTools;

class Stream<T> {
    public var isActive(default, null): Bool;

    var middleware: StreamMiddleware<T>;
    var subscribers: Array<StreamSubscriber<T>>;
    var context: StreamContext<T>;

    public function new(middleware: StreamMiddleware<T>) {
        this.middleware = middleware;
        subscribers = [];
        context = { emit: emit, onStop: null };
        isActive = true;
        
        nextTick(middleware.bind(context));
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

    inline function nextTick(fn: Void -> Void): Void {
        #if js
        hxgnd.js.JsNative.setImmediate(fn);
        #else
        haxe.Timer.delay(fn, 0);
        #end
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
