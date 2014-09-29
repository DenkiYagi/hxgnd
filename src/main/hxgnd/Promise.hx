package hxgnd;

class Promise<A> {
    @:allow(hxgnd) @:noCompletion var _state: _PromiseState<A>;
    @:allow(hxgnd) @:noCompletion var _fulfilledHandlers: Array<A -> Void>;
    @:allow(hxgnd) @:noCompletion var _rejectedHandlers: Array<Error -> Void>;
    @:allow(hxgnd) @:noCompletion var _finallyHandlers: Array<Void -> Void>;
    @:allow(hxgnd) @:noCompletion var _context: PromiseContext<A>;

    public var isPending(get, never): Bool;
    public var isCanceled(default, null): Bool;

    public function new(executor: PromiseContext<A> -> Void) {
        _clear();
        _state = Pending;
        isCanceled = false;
        try {
            executor(_context);
        } catch (e: Error) {
            _state = Rejected(e);
        } catch (e: Dynamic) {
            _state = Rejected(new Error(Std.string(e)));
        }
    }

    @:allow(hxgnd) @:noCompletion
    inline function _clear(): Void {
        _fulfilledHandlers = [];
        _rejectedHandlers = [];
        _finallyHandlers = [];
        _context = {
            fulfill: fulfill,
            reject: reject,
            cancel: function () cancel(),
            onCancel: function () {}
        }
    }

    @:allow(hxgnd) @:noCompletion
    function _invokeAsync(fn: Void -> Void): Void {
        #if js
        hxgnd.js.JsTools.setImmediate(fn);
        #else
        haxe.Timer.delay(fn, 0);
        #end
    }

    @:allow(hxgnd) @:noCompletion
    function _doFulfilled(value: A): Void {
        try {
            _state = Fulfilled(value);
            for (f in _fulfilledHandlers) f(value);
            _doFinally();
        } catch (e: Error) {
            _doRejected(e);
        } catch (e: Dynamic) {
            _doRejected(new Error(Std.string(e)));
        }
    }

    @:allow(hxgnd) @:noCompletion
    function _doRejected(?error: Error): Void {
        _state = Rejected(error);
        if (error != null) {
            for (f in _rejectedHandlers) {
                try f(error) catch (e: Dynamic) trace(e); //TODO エラーダンプ
            }
        }
        _doFinally();
    }

    @:allow(hxgnd) @:noCompletion
    inline function _doFinally(): Void {
        for (f in _finallyHandlers) {
            try f() catch (e: Dynamic) trace(e); //TODO エラーダンプ
        }
        _clear();
    }

    @:allow(hxgnd) @:noCompletion
    function get_isPending() {
        return switch (_state) {
            case Pending: true;
            case _: false;
        }
    }

    function fulfill(x: A): Void {
        if (Type.enumEq(_state, Pending)) {
            _state = Sealed;
            _invokeAsync(_doFulfilled.bind(x));
        }
    }

    function reject(?err: Error): Void {
        if (Type.enumEq(_state, Pending)) {
            _state = Sealed;
            _invokeAsync(_doRejected.bind(err));
        }
    }

    public function then(fulfilled: A -> Void, ?rejected: Error -> Void, ?finally: Void -> Void): Promise<A> {
        switch (_state) {
            case Pending, Sealed:
                if (fulfilled != null) _fulfilledHandlers.push(fulfilled);
                if (rejected != null) _rejectedHandlers.push(rejected);
                if (finally != null) _finallyHandlers.push(finally);
            case Fulfilled(v):
                _invokeAsync(function thenFulfilled() {
                    if (fulfilled != null) try fulfilled(v) catch (e: Dynamic) trace(e);
                    if (finally != null) try finally() catch (e: Dynamic) trace(e);
                });
            case Rejected(e):
                _invokeAsync(function thenRejected() {
                    if (rejected != null) try rejected(e) catch (_e: Dynamic) trace(_e);
                    if (finally != null) try finally() catch (e: Dynamic) trace(e);
                });
        }
        return this;
    }

    public function thenError(rejected: Error -> Void): Promise<A> {
        return then(null, rejected);
    }

    public function thenFinally(finally: Void -> Void): Promise<A> {
        return then(null, null, finally);
    }

    public function cancel(notifiable = true): Void {
        if (Type.enumEq(_state, Pending) && !isCanceled) {
            isCanceled = true;
            if (_context.onCancel != null) {
                try {
                    _context.onCancel();
                } catch (e: Dynamic) {
                    trace(e);
                }
            }
            reject(notifiable ? new Error("Canceled") : null);
        }
    }

    public function map<B>(fn: A -> B): Promise<B> {
        return new Promise(function mapExecutor(context) {
            then(function (a) context.fulfill(fn(a)), context.reject);
        });
    }

    public function flatMap<B>(fn: A -> Promise<B>): Promise<B> {
        return new Promise(function bindExecutor(context) {
            then(function (a) fn(a).then(context.fulfill, context.reject), context.reject);
        });
    }

    // static ---------------

    public static function fulfilled<A>(value: A): Promise<A> {
        return new Promise(function (context) {
            context.fulfill(value);
        });
    }

    public static function rejected<A>(?error: Error): Promise<A> {
        return new Promise(function (context) {
            context.reject((error == null) ? new Error("Rejected") : error);
        });
    }

    public static function all<A>(promises: Array<Promise<A>>): Promise<Array<A>> {
        return if (promises.length <= 0) {
            return Promise.fulfilled([]);
        } else {
            new Promise(function (context) {
                function cancelAll() {
                    for (p in promises) p.cancel();
                }

                var length = promises.length;
                var count = 0;
                var results = [];
                var rejectFlag = true;
                for (item in Lambda.mapi(promises, function (i, x) return { index: i, promise: x })) {
                    item.promise.then(function (x) {
                        results[item.index] = x;
                        if (++count >= length) context.fulfill(results);
                    }, function (e) {
                        if (rejectFlag) {
                            rejectFlag = false;
                            context.reject(e);
                            cancelAll();
                        }
                    });
                }
                return cancelAll;
            });
        }
    }

    //public static function when<T>(iter: Iterable<Promise<T>>): Promise<T> {
        //return null;
    //}
}

typedef PromiseContext<A> = {
    function fulfill(value: A): Void;
    function reject(error: Error): Void;
    function cancel(): Void;
    dynamic function onCancel(): Void;
}

@:noCompletion
private enum _PromiseState<A> {
    Pending;
    Sealed;
    Fulfilled(value: A);
    Rejected(error: Error);
}