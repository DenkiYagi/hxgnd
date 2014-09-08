package hxgnd;

import hxgnd.Promise;

class PromiseBroker<A> {
    var context: Null<PromiseContext<A>>;

    public var promise(default, null): Promise<A>;

    public function new(?onCancel: PromiseContext<A> -> Void) {
        promise = new Promise(function (ctx) {
            context = ctx;
            if (onCancel != null) context.onCancel = function () {
                onCancel(context);
            }
        }).thenFinally(function () {
            context = null;
        });
    }

    public function fulfill(value: A): Void {
        if (context != null) context.fulfill(value);
    }

    public function reject(error: Error): Void {
        if (context != null) context.reject(error);
    }

    public function cancel(): Void {
        if (context != null) context.cancel();
    }
}