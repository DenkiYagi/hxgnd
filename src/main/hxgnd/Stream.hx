package hxgnd;

class Stream<A> {
    @:allow(haxearth) @:noCompletion
    var _state: _StreamState<A>;
    @:allow(haxearth) @:noCompletion
    var _updatedHandlers: Array<{f: A -> Void, ?loop: Bool}>;
    @:allow(haxearth) @:noCompletion
    var _closedHandlers: Array<Void -> Void>;
    @:allow(haxearth) @:noCompletion
    var _failedHandlers: Array<Dynamic -> Void>;
    @:allow(haxearth) @:noCompletion
    var _abort: Void -> Void;

    public function new(executor: (A -> Void) -> (Void -> Void) -> (Dynamic -> Void) -> (Void -> Void)) {
        _state = Pending;
        _clear();
        try {
            _abort = executor(update, close, fail);
        } catch (e: Dynamic) {
            _state = Failed(e);
        }
    }

    @:allow(haxearth) @:noCompletion
    inline function _clear(): Void {
        _updatedHandlers = [];
        _closedHandlers = [];
        _failedHandlers = [];
        _abort = function () {};
    }

    @:allow(haxearth) @:noCompletion
    function _invokeUpdated(value: A): Void {
        function filter() {
            var array = [];
            for (x in _updatedHandlers)
                if (x.loop) array.push(x);
            return array;
        }

        JsTools.setImmediate(function () {
            try {
                for (handler in _updatedHandlers) handler.f(value);
                _updatedHandlers = filter();
                _state = Opened;
            } catch (e: Dynamic) {
                _invokeFailed(e);
            }
        });
    }

    @:allow(haxearth) @:noCompletion
    function _invokeClosed(): Void {
        JsTools.setImmediate(function () {
            try {
                for (f in _closedHandlers) f();
                _clear();
                _state = Closed;
            } catch (e: Dynamic) {
                _invokeFailed(e);
            }
        });
    }

    @:allow(haxearth) @:noCompletion
    function _invokeFailed(error: Dynamic): Void {
        JsTools.setImmediate(function () {
            for (f in _failedHandlers)
                try f(error) catch (e: Dynamic) trace(e); //TODO エラーダンプ
            _clear();
            _state = Failed(error);
        });
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

    function fail(x: Dynamic): Void {
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

    public function then(updated: A -> Void, ?closed: Void -> Void, ?failed: Dynamic -> Void): Stream<A> {
        switch (_state) {
            case Pending, Opened, Sealed:
                if (updated != null) _updatedHandlers.push({f: updated, loop: true});
                if (closed != null) _closedHandlers.push(closed);
                if (failed != null) _failedHandlers.push(failed);
            case Closed:
                if (closed != null) JsTools.setImmediate(closed);
            case Failed(e):
                if (failed != null) JsTools.setImmediate(failed.bind(e));
        }
        return this;
    }

    public function thenClose(closed: Void -> Void): Stream<A> {
        return then(null, closed);
    }

    public function thenError(failed: Dynamic -> Void): Stream<A> {
        return then(null, null, failed);
    }

    public function await(updated: A -> Void): Stream<A> {
        switch (_state) {
            case Pending, Opened, Sealed:
                _updatedHandlers.push({f: updated});
            default:
        }
        return this;
    }

    //public function head(): Promise<A> {
        //return switch (_state) {
            //case Pending:
                //new Promise(function (resolve, reject) {
                    //await(resolve);
                    //then(null, function () reject(new Error("Closed")), reject);
                    //return function () {};
                //});
            //case Opened:
                //Promise.rejected(new Error("Opened"));
            //case Sealed:
                //Promise.rejected(new Error("Opened"));
            //case Closed:
                //Promise.rejected(new Error("Closed"));
            //case Failed(e):
                //Promise.rejected(e);
        //}
    //}

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

    public function chain<B>(f: A -> Promise<B>, ?resume: Dynamic -> Option<B>): Stream<B> {
        return new Stream(function (update, close, fail) {
            var promise;
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
    Failed(error: Dynamic);
}