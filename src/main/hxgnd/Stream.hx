package hxgnd;

class Stream<A> {
    @:allow(hxgnd) @:noCompletion var _state: _StreamState<A>;
    @:allow(hxgnd) @:noCompletion var _updatedHandlers: Array<{f: A -> Void, ?loop: Bool}>;
    @:allow(hxgnd) @:noCompletion var _closedHandlers: Array<Void -> Void>;
    @:allow(hxgnd) @:noCompletion var _failedHandlers: Array<Error -> Void>;
    @:allow(hxgnd) @:noCompletion var _finallyHandlers: Array<Void -> Void>;
    @:allow(hxgnd) @:noCompletion var _abort: Void -> Void;

    public var isPending(get, null): Bool;
    public var isClosed(get, null): Bool;

    public function new(executor: (A -> Void) -> (Void -> Void) -> (Error -> Void) -> (Void -> Void)) {
        _state = Pending;
        _clear();
        try {
            _abort = executor(update, close, fail);
        } catch (e: Error) {
            _state = Failed(e);
        } catch (e: Dynamic) {
            _state = Failed(new Error(Std.string(e)));
        }
    }

    @:allow(hxgnd) @:noCompletion
    inline function _clear(): Void {
        _updatedHandlers = [];
        _closedHandlers = [];
        _failedHandlers = [];
        _finallyHandlers = [];
        _abort = function () {};
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
    function _invokeUpdated(value: A): Void {
        function filter() {
            var array = [];
            for (x in _updatedHandlers)
                if (x.loop) array.push(x);
            return array;
        }

        _invokeAsync(function () {
            try {
                for (handler in _updatedHandlers) handler.f(value);
                _updatedHandlers = filter();
                _state = Opened;
            } catch (e: Error) {
                _invokeFailed(e);
            } catch (e: Dynamic) {
                _invokeFailed(new Error(Std.string(e)));
            }
        });
    }

    @:allow(hxgnd) @:noCompletion
    function _invokeClosed(): Void {
        _invokeAsync(function () {
            try {
                for (f in _closedHandlers) f();
                _invokeFinally();
                _clear();
                _state = Closed;
            } catch (e: Error) {
                _invokeFailed(e);
            } catch (e: Dynamic) {
                _invokeFailed(new Error(Std.string(e)));
            }
        });
    }

    @:allow(hxgnd) @:noCompletion
    function _invokeFailed(error: Error): Void {
        _invokeAsync(function () {
            for (f in _failedHandlers) {
                try f(error) catch (e: Dynamic) trace(e); //TODO エラーダンプ
            }
            _invokeFinally();
            _clear();
            _state = Failed(error);
        });
    }

    @:allow(hxgnd) @:noCompletion
    inline function _invokeFinally(): Void {
        for (f in _finallyHandlers) {
            try f() catch (e: Dynamic) trace(e); //TODO エラーダンプ
        }
    }

    function get_isPending() {
        return switch (_state) {
            case Pending: true;
            case _: false;
        }
    }

    function get_isClosed() {
        return switch (_state) {
            case Closed, Failed(_): true;
            case _: false;
        }
    }

    function update(value: A): Void {
        switch (_state) {
            case Pending, Opened:
                _state = Opened;
                _invokeUpdated(value);
            default:
        }
    }

    function close(): Void {
        switch (_state) {
            case Pending, Opened:
                _state = Sealed;
                _invokeClosed();
            default:
        }
    }

    function fail(x: Error): Void {
        switch (_state) {
            case Pending, Opened:
                _state = Sealed;
                _invokeFailed((x == null) ? new Error("Rejected") : x);
            default:
        }
    }

    public function cancel(): Void {
        switch (_state) {
            case Pending, Opened:
                _state = Sealed;
                _abort();
                _invokeFailed(new Error("Canceled"));
            default:
        }
    }

    public function then(updated: A -> Void, ?closed: Void -> Void, ?failed: Error -> Void, ?finally: Void -> Void): Stream<A> {
        switch (_state) {
            case Pending, Opened, Sealed:
                if (updated != null) _updatedHandlers.push({f: updated, loop: true});
                if (closed != null) _closedHandlers.push(closed);
                if (failed != null) _failedHandlers.push(failed);
                if (finally != null) _finallyHandlers.push(finally);
            case Closed:
                if (closed != null) _invokeAsync(closed);
                if (finally != null) _invokeAsync(finally);
            case Failed(e):
                if (failed != null) _invokeAsync(failed.bind(e));
                if (finally != null) _invokeAsync(finally);
        }
        return this;
    }

    public function thenClosed(closed: Void -> Void): Stream<A> {
        return then(null, closed);
    }

    public function thenError(failed: Error -> Void): Stream<A> {
        return then(null, null, failed);
    }

    public function thenFinally(finally: Void -> Void): Stream<A> {
        return then(null, null, null, finally);
    }

    public function await(updated: A -> Void): Stream<A> {
        switch (_state) {
            case Pending, Opened, Sealed:
                _updatedHandlers.push({f: updated});
            default:
        }
        return this;
    }

    public function next(): Promise<A> {
        return switch (_state) {
            case Pending, Opened:
                new Promise(function (resolve, reject) {
                    await(resolve);
                    then(null, function () reject(new Error("Closed")), reject);
                    return function () {};
                });
            case Sealed:
                new Promise(function (resolve, reject) {
                    then(null, function () reject(new Error("Closed")), reject);
                    return function () {};
                });
            case Closed:
                Promise.rejected(new Error("Closed"));
            case Failed(e):
                Promise.rejected(e);
        }
    }

    public function tail(): Promise<Unit> {
        return switch (_state) {
            case Pending, Opened, Sealed:
                new Promise(function (resolve, reject) {
                    then(null, function () resolve(Unit._), reject);
                    return function () {};
                });
            case Closed:
                Promise.resolved(Unit._);
            case Failed(e):
                Promise.rejected(e);
        }
    }

    public function map<B>(f: A -> B): Stream<B> {
        return new Stream(function (update, close, fail) {
            this.then(function (a) update(f(a)), close, fail);
            return this.cancel;
        });
    }

    public function chain<B>(f: A -> Promise<B>, ?resume: Error -> Option<B>): Stream<B> {
        return new Stream(function (update, close, fail) {
            var promise = null;
            this.then(function (a) {
                promise = if (resume == null) {
                    f(a).then(function (b) update(b), fail);
                } else {
                    f(a).then(update, function (e) {
                        switch (resume(e)) {
                            case Some(b): update(b);
                            case None:
                        }
                    });
                }
            }, close, fail);
            return function () {
                if (promise != null) promise.cancel();
                this.cancel();
            }
        });
    }
}

private enum _StreamState<T> {
    Pending;
    Opened;
    Sealed;
    Closed;
    Failed(error: Error);
}