package hxgnd.internal;

class EmptyReactiveStreamSource<T> {
    public function new() {
    }

    public function start(): Void {
    }

    public function subscribe(fn: T -> Void): Void -> Void {
        return function unsubscribe_empty() {};
    }

    public function subscribeEnd(fn: Void -> Void): Void -> Void {
        Dispatcher.dispatch(fn);
        return function unsubscribe_empty() {};
    }

    public function subscribeError(fn: Dynamic -> Void): Void -> Void {
        return function unsubscribe_empty() {};
    }

    public function abort(): Void {
    }
}