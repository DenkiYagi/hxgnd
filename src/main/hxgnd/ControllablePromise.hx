package hxgnd;

class ControllablePromise<A> extends Promise<A> {
    public function new(?canceled: Void -> Void) {
        super(function (_, _) {
            return (canceled == null) ? function() {} : canceled;
        });
    }

    override public function resolve(x: A): Void {
        super.resolve(x);
    }

    override public function reject(err: Error): Void {
        super.reject(err);
    }
}