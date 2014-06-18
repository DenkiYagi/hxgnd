package hxgnd.js;

typedef JqPromise = {
    function always(f: Void -> Void): JqPromise;
    function done(f: Dynamic -> Void): JqPromise;
    function fail(f: Dynamic -> Void): JqPromise;
    function then(fa: Dynamic -> Void, ?fb: Dynamic -> Void): JqPromise;
    function progress(f: Dynamic -> Void): JqPromise;
    function state(): JqPromiseState;
}
