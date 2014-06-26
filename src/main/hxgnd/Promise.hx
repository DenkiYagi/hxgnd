package hxgnd;

class Promise<A> {
    @:allow(hxgnd) @:noCompletion var _state: _PromiseState<A>;
    @:allow(hxgnd) @:noCompletion var _resolvedHandlers: Array<A -> Void>;
    @:allow(hxgnd) @:noCompletion var _rejectedHandlers: Array<Error -> Void>;
    @:allow(hxgnd) @:noCompletion var _finallyHandlers: Array<Void -> Void>;
    @:allow(hxgnd) @:noCompletion var _abort: Void -> Void;

    public var isPending(get, never): Bool;

    public function new(executor: (A -> Void) -> (Error -> Void) -> (Void -> Void)) {
        _clear();
        _state = Pending;
        try {
            _abort = executor(resolve, reject);
        } catch (e: Error) {
            _state = Rejected(e);
        } catch (e: Dynamic) {
            _state = Rejected(new Error(Std.string(e)));
        }
    }

    @:allow(hxgnd) @:noCompletion
    inline function _clear(): Void {
        _resolvedHandlers = [];
        _rejectedHandlers = [];
        _finallyHandlers = [];
        _abort = function () { };
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
    function _invokeResolved(value: A): Void {
        _invokeAsync(function () {
            try {
                _state = Resolved(value);
                for (f in _resolvedHandlers) f(value);
                _invokeFinally();
                _clear();
            } catch (e: Error) {
                _invokeRejected(e);
            } catch (e: Dynamic) {
                _invokeRejected(new Error(Std.string(e)));
            }
        });
    }

    @:allow(hxgnd) @:noCompletion
    function _invokeRejected(error: Error): Void {
        _invokeAsync(function () {
            _state = Rejected(error);
            for (f in _rejectedHandlers) {
                try f(error) catch (e: Dynamic) trace(e); //TODO エラーダンプ
            }
            _invokeFinally();
            _clear();
        });
    }

    @:allow(hxgnd) @:noCompletion
    inline function _invokeFinally(): Void {
        for (f in _finallyHandlers) {
            try f() catch (e: Dynamic) trace(e); //TODO エラーダンプ
        }
    }

    @:allow(hxgnd) @:noCompletion
    function get_isPending() {
        return switch (_state) {
            case Pending: true;
            case _: false;
        }
    }

    function resolve(x: A): Void {
        if (Type.enumEq(_state, Pending)) {
            _state = Sealed;
            _invokeResolved(x);
        }
    }

    function reject(?x: Error): Void {
        if (Type.enumEq(_state, Pending)) {
            _state = Sealed;
            _invokeRejected((x == null) ? new Error("Rejected") : x);
        }
    }

    public function then(resolved: A -> Void, ?rejected: Error -> Void, ?finally: Void -> Void): Promise<A> {
        switch (_state) {
            case Pending, Sealed:
                if (resolved != null) _resolvedHandlers.push(resolved);
                if (rejected != null) _rejectedHandlers.push(rejected);
                if (finally != null) _finallyHandlers.push(finally);
            case Resolved(v):
                _invokeAsync(function thenResolved() {
                    if (resolved != null) try resolved(v) catch (e: Dynamic) trace(e);
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

    public function cancel(): Promise<A> {
        if (Type.enumEq(_state, Pending)) {
            _state = Sealed;
            _abort();
            _invokeRejected(new Error("Canceled"));
        }
        return this;
    }

    public function map<B>(fn: A -> B): Promise<B> {
        return new Promise(function mapExecutor(resolve, reject) {
            then(function (a) resolve(fn(a)), reject);
            return function () { };
        });
    }

    public function flatMap<B>(fn: A -> Promise<B>): Promise<B> {
        return new Promise(function bindExecutor(resolve, reject) {
            then(function (a) fn(a).then(resolve, reject), reject);
            return function () { };
        });
    }

    // static ---------------

    public static function resolved<A>(value: A): Promise<A> {
        return new Promise(function (resolve, _) {
            resolve(value);
            return function () { };
        });
    }

    public static function rejected<A>(?error: Error): Promise<A> {
        return new Promise(function (_, reject) {
            reject(error);
            return function () { };
        });
    }

    public static function all<A>(promises: Array<Promise<A>>): Promise<Array<A>> {
        return if (promises.length <= 0) {
            return Promise.resolved([]);
        } else {
            new Promise(function (resolve, reject) {
                function cancelAll() {
                    for (p in promises) p.cancel();
                }

                var length = promises.length;
                var results = [];
                var rejectFlag = true;
                for (p in promises) {
                    p.then(function (x) {
                        results.push(x);
                        if (results.length >= length) resolve(results);
                    }, function (e) {
                        if (rejectFlag) {
                            rejectFlag = false;
                            reject(e);
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

@:noCompletion
private enum _PromiseState<T> {
    Pending;
    Sealed;
    Resolved(value: T);
    Rejected(error: Error);
}