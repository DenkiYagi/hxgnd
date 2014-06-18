package hxgnd.js;

typedef JqDeferred = {
    function always(f: Dynamic -> Void): JqDeferred;

    function done(f: Dynamic -> Void): JqDeferred;

    function fail(f: Dynamic -> Void): JqDeferred;

    function then(fa: Dynamic -> Void, fb: Dynamic -> Void): JqDeferred;

    function notify(args: Dynamic): JqDeferred;

    // unsupported
    // function notifyWith(): Void;

    function progress(f: Dynamic -> Void): JqDeferred;

    function promise(): JqPromise;

    function reject(args: Dynamic): JqDeferred;

    // unsupported
    // function rejectWith(): Void;

    function resolve(args: Dynamic): JqDeferred;

    // unsupported
    // function resolveWith(): Void;

    function state(): JqPromiseState;
}