package hxgnd;

class ReactiveStream<T> {
    var source: ReactiveStreamSource<T>;

    public function new(source: ReactiveStreamSource<T>) {
        this.source = source;
    }

    public function start(): Void {
        source.start();
    }

    public function subscribe(onValue: T -> Void): Void -> Void {
        return source.subscribe(onValue);
    }

    public function subscribeEnd(onEnd: Void -> Void): Void -> Void {
        return source.subscribeEnd(onEnd);
    }

    public function subscribeError(onError: Dynamic -> Void): Void -> Void {
        return source.subscribeError(onError);
    }

    public function abort(): Void {
        source.abort();
    }

    public function pull(): Promise<T> {
        return new SyncPromise(function (fulfill, reject) {
            var unsubscribes: Array<Void -> Void> = [];
            unsubscribes.push(source.subscribe(function next_onvalue(x) {
                for (f in unsubscribes) f();
                fulfill(x);
            }));
            unsubscribes.push(source.subscribeEnd(function next_onend() {
                for (f in unsubscribes) f();
                reject(new StreamClosedError());
            }));
            unsubscribes.push(source.subscribeError(function next_onerror(e) {
                for (f in unsubscribes) f();
                reject(e);
            }));
        });
    }

    public function catchError(fn: Dynamic -> ReactiveStream<T>): ReactiveStream<T> {
        var stream = ReactiveStream.create(function (emitValue, emitEnd, emitError) {
            var abort = this.abort;
            source.subscribe(emitValue);
            source.subscribeEnd(emitEnd);
            source.subscribeError(function onError(error) {
                try {
                    var alt = fn(error);
                    alt.subscribe(emitValue);
                    alt.subscribeEnd(emitEnd);
                    alt.subscribeError(emitError);
                    abort = alt.abort;
                } catch (e: Dynamic) {
                    emitError(e);
                }
            });
            return function () { abort(); }
        });
        stream.start();
        return stream;
    }

    public function finally(fn: Void -> Void): ReactiveStream<T> {
        // TODO wrap stream
        source.subscribeEnd(fn);
        source.subscribeError(function (_) fn());
        return this;
    }

    public function forEach(fn: T -> Void): Void {
        subscribe(fn);
    }

    // public function map<U>(fn: T -> U): Reactable<U> {
    //     return ReactableHelper.map(this, fn);
    // }

    // public function flatMap<U>(fn: T -> Reactable<U>): Reactable<U> {
    //     return ReactableHelper.flatMap(this, fn);
    // }

    // public function filter(fn: T -> Bool): Reactable<T> {
    //     return ReactableHelper.filter(this, fn);
    // }

    // public function reduce(fn: T -> T -> T): Reactable<T> {
    //     return ReactableHelper.reduce(this, fn);
    // }

    // public function fold<U>(init: U, fn: U -> T -> U): Reactable<U> {
    //     return ReactableHelper.fold(this, init, fn);
    // }

    // public function skip(count: Int): Reactable<T> {
    //     return ReactableHelper.skip(this, count);
    // }

    // public function throttle(msec: Int): Reactable<T> {
    //     return ReactableHelper.throttle(this, msec);
    // }

    // public function debounce(msec: Int): Reactable<T> {
    //     return ReactableHelper.debounce(this, msec);
    // }

    public static function create<T>(middleware: (T -> Void) -> (Void -> Void) -> (Dynamic -> Void) -> (Void -> Void)): ReactiveStream<T> {
        return new ReactiveStream(new hxgnd.internal.DefaultReactiveStreamSource(middleware));
    }

    public static function empty<T>(): ReactiveStream<T> {
        return new ReactiveStream(new hxgnd.internal.EmptyReactiveStreamSource());
    }
}

typedef ReactiveStreamSource<T> = {
    function start(): Void;
    function subscribe(fn: T -> Void): Void -> Void;
    function subscribeEnd(fn: Void -> Void): Void -> Void;
    function subscribeError(fn: Dynamic -> Void): Void -> Void;
    function abort(): Void;
}
