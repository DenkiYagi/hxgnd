package hxgnd.js;

import js.Boot;
import js.Error;
import js.html.XMLHttpRequest;

extern class JqXHR extends XMLHttpRequest {
    @:overload(function (f: Dynamic -> String -> Dynamic -> Void): JqXHR{})
    function always(f: Void -> Void) : JqXHR;

    @:overload(function (f: Dynamic -> String -> JqXHR -> Void): JqXHR{})
    function done(f: Dynamic -> Void): JqXHR;

    @:overload(function (f: JqXHR -> String -> Error): JqXHR{})
    function fail(f: Error -> Void): JqXHR;

    @:overload(function (fa: Dynamic -> String -> JqXHR -> Void, fb: JqXHR -> String -> Error): JqXHR{})
    function then(fa: Dynamic -> Void, ?fb: Error -> Void): JqXHR;

    function progress(f: Dynamic -> Void): JqXHR;

    function state(): JqPromiseState;
}