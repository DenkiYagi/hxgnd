package hxgnd;

using hxgnd.LangTools;

class Stream<T> {
    public var isActive(default, null): Bool;
    public var end(get, never): Promise<Unit>;

    var subscribers: Array<StreamSubscriber<T>>;
    var context: StreamContext<T>;
    var _end: Maybe<Promise<Unit>>;

    function new() {
        isActive = true;
        subscribers = [];
        context = { emit: emit, onAbort: null };
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

        inline function done() {
            emit(Error(new AbortError("aborted")));
        }

        if (context.onAbort.nonNull()) {
            try {
                context.onAbort();
            } catch (e: Dynamic) {
                #if js
                js.Browser.console.error(e);
                #else
                trace(e);
                #end
            }
            done();
        } else {
            done();
        }
    }

    function get_end() {
        if (_end.isEmpty()) {
            _end = new SyncPromise(function (fulfill, reject) {
                subscribe(function (e) {
                    switch (e) {
                        case End: fulfill(new Unit());
                        case Error(x): reject(x);
                        case _:
                    }
                });
            });
        }
        return _end.get();
    }

    function emit(event: StreamEvent<T>): Void {
        if (!isActive) return;

        var _subscribers = this.subscribers;
        switch (event) {
            case End | Error(_):
                isActive = false;
                subscribers = null;
                context = null;
                _end = null;
            case _:
        }
        for (fn in _subscribers) fn(event);
    }

    public static function apply<T>(executor: StreamContext<T> -> Void): Stream<T> {
        var stream = new Stream<T>();

        Dispatcher.dispatch(function exec() {
            try {
                executor(stream.context);
            } catch (e: Dynamic) {
                stream.emit(Error(e));
            }
        });

        return stream;
    }
}

typedef StreamContext<T> = {
    function emit(event: StreamEvent<T>): Void;
    dynamic function onAbort(): Void;
}

typedef StreamSubscriber<T> = StreamEvent<T> -> Void;

enum StreamEvent<T> {
    Data(value: T);
    Error(error: Dynamic);
    End;
}
