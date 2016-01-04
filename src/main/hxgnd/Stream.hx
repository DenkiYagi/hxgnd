package hxgnd;

import haxe.Timer;
using hxgnd.OptionUtils;

class Stream<A> {
    @:allow(hxgnd) @:noCompletion var _state: _StreamState<A>;
    @:allow(hxgnd) @:noCompletion var _updatedHandlers: Array<{f: A -> Void, ?loop: Bool}>;
    @:allow(hxgnd) @:noCompletion var _closedHandlers: Array<Void -> Void>;
    @:allow(hxgnd) @:noCompletion var _failedHandlers: Array<Error -> Void>;
    @:allow(hxgnd) @:noCompletion var _finallyHandlers: Array<Void -> Void>;
    @:allow(hxgnd) @:noCompletion var _context: StreamContext<A>;

    public var isPending(get, null): Bool;
    public var isClosed(get, null): Bool;
    public var isCanceled(default, null): Bool;

    public function new(executor: StreamContext<A> -> Void) {
        _state = Pending;
        isCanceled = false;
        _clear();
        try {
            executor(_context);
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
        _context = {
            update: update,
            close: close,
            fail: fail,
            cancel: cancel,
            onCancel: function () {}
        };
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
    function _doUpdated(value: A): Void {
        function filter() {
            var array = [];
            for (x in _updatedHandlers)
                if (x.loop) array.push(x);
            return array;
        }

        try {
            _state = Opened;
            for (handler in _updatedHandlers) handler.f(value);
            _updatedHandlers = filter();
        } catch (e: Error) {
            _doFailed(e);
        } catch (e: Dynamic) {
            _doFailed(new Error(Std.string(e)));
        }
    }

    @:allow(hxgnd) @:noCompletion
    function _doClosed(): Void {
        try {
            _state = Closed;
            for (f in _closedHandlers) f();
            _doFinally();
            _clear();
        } catch (e: Error) {
            _doFailed(e);
        } catch (e: Dynamic) {
            _doFailed(new Error(Std.string(e)));
        }
    }

    @:allow(hxgnd) @:noCompletion
    function _doFailed(error: Error): Void {
        _state = Failed(error);
        for (f in _failedHandlers) {
            try f(error) catch (e: Dynamic) trace(e); //TODO エラーダンプ
        }
        _doFinally();
        _clear();
    }

    @:allow(hxgnd) @:noCompletion
    function _doCancel(): Void {
        isCanceled = true;
        if (_context.onCancel != null) {
            try {
                _context.onCancel();
            } catch (e: Dynamic) {
                trace(e);
            }
        }
        fail(new Error("Canceled"));
    }

    @:allow(hxgnd) @:noCompletion
    inline function _doFinally(): Void {
        for (f in _finallyHandlers) {
            try f() catch (e: Dynamic) trace(e); //TODO エラーダンプ
        }
    }

    @:allow(hxgnd) @:noCompletion
    function get_isPending() {
        return switch (_state) {
            case Pending: !isCanceled;
            case _: false;
        }
    }

    @:allow(hxgnd) @:noCompletion
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
                _invokeAsync(_doUpdated.bind(value));
            default:
        }
    }

    function close(): Void {
        switch (_state) {
            case Pending, Opened:
                _state = Sealed;
                _invokeAsync(_doClosed);
            default:
        }
    }

    function fail(x: Error): Void {
        switch (_state) {
            case Pending, Opened:
                _state = Sealed;
                _invokeAsync(_doFailed.bind((x == null) ? new Error("Rejected") : x));
            default:
        }
    }

    public function cancel(): Void {
        switch (_state) {
            case Pending, Opened if (!isCanceled):
                _doCancel();
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

    public function next(): Promise<A> {
        return switch (_state) {
            case Pending, Opened, Sealed:
                new Promise(function (context) {
                    then(context.fulfill, function () context.reject(new Error("Closed")), context.reject);
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
                new Promise(function (context) {
                    then(null, context.fulfill.bind(Unit._), context.reject);
                });
            case Closed:
                Promise.fulfilled(Unit._);
            case Failed(e):
                Promise.rejected(e);
        }
    }

    public function filter(f: A -> Bool): Stream<A> {
        return new Stream(function (context) {
            this.then(function (a) {
                if (f(a)) context.update(a);
            }, context.close, context.fail);
        });
    }

    public function throttle(msec: UInt): Stream<A> {
        return if (msec == 0) {
            this;
        } else {
            new Stream(function (context) {
                var start: Float = Timer.stamp();
                var frame: Int = -1;
                this.then(function (a) {
                    var t = (Timer.stamp() - start) * 1000;
                    var f = Math.floor(t / msec);
                    if (f > frame) {
                        frame = f;
                        context.update(a);
                    }
                }, context.close, context.fail);
            });
        }
    }

    public function debounce(msec: UInt): Stream<A> {
        return if (msec == 0) {
            this;
        } else {
            new Stream(function (context) {
                var lastest: Option<A> = Option.None;

                var timer = new Timer(msec);
                timer.run = function () {
                    lastest.iter(function (a) {
                        lastest = Option.None;
                        context.update(a);
                    });
                }

                this.then(function (a) {
                    lastest = Option.Some(a);
                }, function () {
                    timer.stop();
                    context.close();
                }, function (e) {
                    timer.stop();
                    context.fail(e);
                });
            });
        }
    }

    // distinct
    // skip

    public function map<B>(f: A -> B): Stream<B> {
        return new Stream(function (context) {
            this.then(function (a) context.update(f(a)), context.close, context.fail);
            return this.cancel;
        });
    }

    public function flatMap<B>(f: A -> Promise<B>): Stream<B> {
        return new Stream(function (context) {
            var promises = [];
            this.then(function (a) {
                var p = f(a);
                promises.push(p);
                var slice = promises.copy();
                Promise.all(slice).then(function (results) {
                    var start = results.length - 1;
                    for (x in promises) {
                        if (x == p) break;
                        start--;
                    }
                    for (x in results.slice(start)) {
                        context.update(x);
                        promises.shift();
                    }
                    if (Lambda.empty(promises)) {
                        switch (this._state) {
                            case Sealed: this.then(null, context.close, context.fail);
                            case Closed: context.close();
                            case Failed(e): context.fail(e);
                            case _:
                        }
                    }
                }, function (e) {
                    context.fail(e);
                    Lambda.iter(promises, function (p) p.cancel(false));
                    promises = [];
                });
            }, function () {
                if (Lambda.empty(promises)) context.close();
            }, function (e) {
                if (Lambda.empty(promises)) context.fail(e);
            });
            context.onCancel = function () {
                Lambda.iter(promises, function (p) p.cancel(false));
                promises = [];
                this.cancel();
            }
        });
    }

    //public function flatMapFirst() : Void {
//
    //}

    public function flatMapLastest<B>(f: A -> Promise<B>): Stream<B> {
        return new Stream(function (context) {
            var promise = new Promise(function (_) { } );
            var checker = true;

            this.then(function (a) {
                promise.cancel(false);
                promise = f(a);
                promise.then(context.update, context.fail);
            }, function () {
                promise.then(function (_) context.close());
            }, function (e) {
                promise.cancel(false);
                context.fail(e);
            });

            context.onCancel = function () {
                promise.cancel(false);
                this.cancel();
            }
        });
    }

    public function zip(other: Varargs<Stream<A>>): Stream<A> {
        return if (other.length > 0) {
            var streams = [this].concat(other);
            var closed = 0;
            new Stream(function (ctx: StreamContext<A>) {
                ctx.onCancel = function () {
                    for (x in streams) {
                        x.cancel();
                    }
                }

                for (x in streams) {
                    x.then(
                        ctx.update,
                        function () { if (++closed >= streams.length) ctx.close(); },
                        ctx.fail
                    );
                }
            });
        } else {
            this;
        }
    }
}

typedef StreamContext<A> = {
    function update(value: A): Void;
    function close(): Void;
    function fail(error: Error): Void;
    function cancel(): Void;
    dynamic function onCancel(): Void;
}

private enum _StreamState<T> {
    Pending;
    Opened;
    Sealed;
    Closed;
    Failed(error: Error);
}