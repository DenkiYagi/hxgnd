package hxgnd;

class Promise<A> {
    @:allow(haxearth) @:noCompletion
    var _state: _PromiseState<A>;
    @:allow(haxearth) @:noCompletion
    var _resolvedHandlers: Array<A -> Void>;
    @:allow(haxearth) @:noCompletion
    var _rejectedHandlers: Array<Dynamic -> Void>;
    @:allow(haxearth) @:noCompletion
    var _finallyHandlers: Array<Void -> Void>;
    @:allow(haxearth) @:noCompletion
    var _abort: Void -> Void;

    public function new(executor: (A -> Void) -> (Dynamic -> Void) -> (Void -> Void)) {
        _clear();
        _state = Pending;

        try {
            _abort = executor(resolve, reject);
        } catch (e: Dynamic) {
            _state = Rejected(e);
        }
    }

    @:allow(haxearth) @:noCompletion
    inline function _clear(): Void {
        _resolvedHandlers = [];
        _rejectedHandlers = [];
        _finallyHandlers = [];
        _abort = function () { };
    }

    @:allow(haxearth) @:noCompletion
    function _invokeResolved(value: A): Void {
        JsTools.setImmediate(function () {
            try {
                for (f in _resolvedHandlers) f(value);
                _invokeFinally();
                _clear();
                _state = Resolved(value);
            } catch (e: Dynamic) {
                _invokeRejected(e);
            }
        });
    }

    @:allow(haxearth) @:noCompletion
    function _invokeRejected(error: Dynamic): Void {
        JsTools.setImmediate(function () {
            for (f in _rejectedHandlers) {
                try f(error) catch (e: Dynamic) trace(e); //TODO エラーダンプ
            }
            _invokeFinally();
            _clear();
            _state = Rejected(error);
        });
    }

    @:allow(haxearth) @:noCompletion
    function _invokeFinally(): Void {
        for (f in _finallyHandlers) {
            try f() catch (e: Dynamic) trace(e); //TODO エラーダンプ
        }
    }

    function resolve(x: A): Void {
        if (Type.enumEq(_state, Pending)) {
            _state = Sealed;
            _invokeResolved(x);
        }
    }

    function reject(x: Dynamic): Void {
        if (Type.enumEq(_state, Pending)) {
            _state = Sealed;
            _invokeRejected((x == null) ? new Error("Rejected") : x);
        }
    }

    public function cancel(): Promise<A> {
        if (Type.enumEq(_state, Pending)) {
            _state = Sealed;
            _abort();
            _invokeRejected(new Error("Canceled"));
        }
        return this;
    }

    public function state(): PromiseState {
        return switch (_state) {
            case Pending, Sealed: Pending;
            case Resolved(v): Resolved;
            case Rejected(e): Rejected;
        }
    }

    public function then(resolved: A -> Void, ?rejected: Dynamic -> Void, ?finally: Void -> Void): Promise<A> {
        switch (_state) {
            case Pending, Sealed:
                if (resolved != null) _resolvedHandlers.push(resolved);
                if (rejected != null) _rejectedHandlers.push(rejected);
                if (finally != null) _finallyHandlers.push(finally);
            case Resolved(v):
                JsTools.setImmediate(function () {
                    if (resolved != null) try resolved(v) catch (e: Dynamic) trace(e);
                    if (finally != null) try finally() catch (e: Dynamic) trace(e);
                });
            case Rejected(e):
                JsTools.setImmediate(function () {
                    if (rejected != null) try rejected(e) catch (_e: Dynamic) trace(_e);
                    if (finally != null) try finally() catch (e: Dynamic) trace(e);
                });
        }
        return this;
    }

    public function thenError(rejected: Dynamic -> Void): Promise<A> {
        return then(null, rejected);
    }

    public function thenFinally(finally: Void -> Void): Promise<A> {
        return then(null, null, finally);
    }

    public function map<B>(f: A -> B): Promise<B> {
        return new Promise(function mapExecutor(resolve, reject) {
            then(function (a) resolve(f(a)), reject);
            return function () { };
        });
    }

    public function bind<B>(f: A -> Promise<B>): Promise<B> {
        return new Promise(function bindExecutor(resolve, reject) {
            then(function (a) f(a).then(resolve, reject), reject);
            return function () { };
        });
    }


    public static function resolved<A>(value: A): Promise<A> {
        return new Promise(function (resolve, _) {
            resolve(value);
            return function () { };
        });
    }

    public static function rejected<A>(error: Dynamic): Promise<A> {
        return new Promise(function (_, reject) {
            reject(error);
            return function () { };
        });
    }

    public static function all<A>(promises: Array<Promise<A>>): Promise<Array<A>> {
        return new Promise(function (resolve, reject) {
            function cancelAll() {
                for (p in promises) p.cancel();
            }

            var length = promises.length;
            var results = [];
            var unrejected = true;
            for (p in promises) {
                p.then(function (x) {
                    results.push(x);
                    if (results.length >= length) resolve(results);
                }, function (e) {
                    if (!unrejected) {
                        unrejected = false;
                        reject(e);
                        cancelAll();
                    }
                });
            }

            return cancelAll;
        });

        throw new Error("not implemented");
    }

    //public static function when<T>(iter: Iterable<Promise<T>>): Promise<T> {
//
//
        //return null;
    //}
}

enum PromiseState {
    Pending;
    Resolved;
    Rejected;
}

private enum _PromiseState<T> {
    Pending;
    Sealed;
    Resolved(value: T);
    Rejected(error: Dynamic);
}