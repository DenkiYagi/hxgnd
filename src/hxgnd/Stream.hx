package hxgnd;

class Stream<T> {
    var middleware: StreamMiddleware<T>;
    var subscribers: Array<StreamSubscriber<T>>;

    public function new(middleware: StreamMiddleware<T>) {
        this.middleware = middleware;
        this.subscribers = [];
        middleware(handle);
    }

    public function subscribe(fn: StreamSubscriber<T>): Void {
        if (LangTools.isNull(subscribers)) return;
        subscribers.push(fn);
    }

    public function unsubscribe(fn: StreamSubscriber<T>): Void {
        if (LangTools.isNull(subscribers)) return;
        subscribers.remove(fn);
    }

    function handle(value: StreamValue<T>): Void {
        if (LangTools.isNull(subscribers)) return;
        for (fn in subscribers) fn(value);
        switch (value) {
            case End: close();
            case _:
        }
    }

    function close(): Void {
        middleware = null;
        subscribers = null;
    }
}

typedef StreamMiddleware<T> = (StreamValue<T> -> Void) -> Void;
typedef StreamSubscriber<T> = StreamValue<T> -> Void;

enum StreamValue<T> {
    Some(x: T);
    End;
}
