package hxgnd;

import hxgnd.Stream;

class StreamBroker<A> {
    var context: Null<StreamContext<A>>;

    public var stream(default, null): Stream<A>;
    public var onCancel(default, default): StreamContext<A> -> Void;

    public function new() {
        stream = new Stream(function (ctx) {
            context = ctx;
            ctx.onCancel = function () {
                if (onCancel != null) onCancel(context);
            }
        }).thenFinally(function () {
            context = null;
        });
    }

    public function update(value: A): Void {
        if (context != null) context.update(value);
    }

    public function close(): Void {
        if (context != null) context.close();
    }

    public function fail(error: Error): Void {
        if (context != null) context.fail(error);
    }

    public function cancel(): Void {
        if (context != null) context.cancel();
    }
}