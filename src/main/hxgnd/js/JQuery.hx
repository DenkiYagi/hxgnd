package hxgnd.js;

import js.html.Element;

@:native("jQuery")
extern class JQuery {
    static var cssHooks(default, never): Dynamic<Dynamic>;

    static var support(default, never): Dynamic<Dynamic>;

    static var fx(default, never): {
        var interval: Int;
        var off: Bool;
    };

    static function ajax(url: String, ?settings: JqAjaxSettings): JqXHR;

    static function ajaxPrefilter(?dataTypes: String, handler: JqAjaxSettings -> JqAjaxSettings -> JqXHR -> Void): Void;

    static function ajaxSetup(options: {}): Void;

    static function ajaxTransport(?dataType: String,
            handler: JqAjaxSettings -> JqAjaxSettings -> JqXHR -> JqAjaxTransport): Void;

    static function contains(container: Element, contained: Element): Bool;

    static function data(element: Element, key: String, ?value: Dynamic): Dynamic;

    static function dequeue(element: Element, ?queueName: String): Void;

    @:overload(function (url: String, ?data: {}, ?success: Dynamic -> String -> JqXHR -> Void, ?dataType: String): JqXHR{})
    static function get(url: String, ?data: String, ?success: Dynamic -> String -> JqXHR -> Void, ?dataType: String): JqXHR;

    @:overload(function (url: String, ?data: {}, ?success: Dynamic -> String -> JqXHR -> Void): JqXHR{})
    static function getJSON(url: String, ?data: String, ?success: Dynamic -> String -> JqXHR -> Void): JqXHR;

    static function getScript(url: String, ?success: String -> String -> JqXHR -> Void): JqXHR;

    static function holdReady(hold: Bool): Void;

    static function param(obj: {}, ?traditional: Bool): String;

    static function parseHTML(data: String, ?context: Element, ?keepScripts: Bool): Array<Element>;

    static function parseJSON(json: String): Dynamic;

    static function parseXML(data: String): Xml;

    @:overload(function (url: String, ?data: {}, ?success: Dynamic -> String -> JqXHR -> Void, ?dataType: String): JqXHR{})
    static function post(url: String, ?data: String, ?success: Dynamic -> String -> JqXHR -> Void, ?dataType: String): JqXHR;

    @:overload(function (elememnt: Element, queueName: String): Array<Void -> Void>{})
    @:overload(function (elememnt: Element, queueName: String, newQueue: Array<Void -> Void>): JqHtml{})
    static function queue(elememnt: Element, queueName: String, fn: Void -> Void): JqHtml;

    static function removeData(elemenmt: Element, ?name: String): JqHtml;

    static function unique(array: Array<Element>): Array<Element>;

    @:overload(function(p1: JqPromise, p2: JqPromise): JqPromise2{})
    @:overload(function(p1: JqPromise, p2: JqPromise, p3: JqPromise): JqPromise3{})
    @:overload(function(p1: JqPromise, p2: JqPromise, p3: JqPromise, p4: JqPromise): JqPromise4{})
    @:overload(function(p1: JqPromise, p2: JqPromise, p3: JqPromise, p4: JqPromise, p5: JqPromise): JqPromise5{})
    static function when(p: Dynamic): JqPromise;

    static function Deferred(): JqDeferred;

    // helper
    @:overload(function (selector: String, ?context: JqHtml): JqHtml{})
    static inline function find(selector: String, ?context: Element): JqHtml {
        return untyped __js__("jQuery")(selector, context);
    }

    @:overload(function (nodes: Array<Element>): JqHtml{})
    static inline function wrap(node: Element): JqHtml {
        return untyped __js__("jQuery")(node);
    }

    // ** unsupported **
    // each()
    // error()
    // extend()
    // fn.extend()
    // globalEval()
    // grep()
    // hasData()
    // inArray()
    // isArray()
    // isEmptyObject()
    // isFunction()
    // isNumeric()
    // isPlainObject()
    // isWindow()
    // isXMLDoc()
    // makeArray()
    // map()
    // merge()
    // noConflict()
    // noop()
    // now()
    // proxy()
    // sub()
    // trim()
    // type()
    // Callbacks();
}

typedef JqAjaxSettings = {
    ?accepts: {},
    ?async: Bool,
    ?beforeSend: JqXHR -> JqAjaxSettings -> Void,
    ?cache: Bool,
    ?complete: JqXHR -> String -> Void,
    ?contents: Dynamic<EReg>,
    ?contentType: String,
    ?context: {},
    ?converters: { },
    ?crossDomain: Bool,
    ?data: Dynamic,
    ?dataFilter: String -> String -> {},
    ?dataType: String,
    ?error: JqXHR -> String -> String -> Void,
    ?global: Bool,
    ?headers: Dynamic<String>,
    ?ifModified: Bool,
    ?isLocal: Bool,
    ?jsonp: String,
    ?jsonpCallback: Dynamic,
    ?mimeType: String,
    ?password: String,
    ?processData: Bool,
    ?scriptCharset: String,
    ?statusCode: Dynamic<Void -> Void>,
    ?success: Dynamic -> String -> JqXHR -> Void,
    ?timeout: Int,
    ?traditional: Bool,
    ?type: String,
    ?url: String,
    ?username: String,
    ?xhr: Void -> Dynamic,
    ?xhrFields: Dynamic<Dynamic>
}

typedef JqAjaxTransport = {
    function send(headers: Dynamic<String>,
                  complete: Int -> String -> ?Dynamic<Dynamic> -> ?String -> Void): Void;
    function abort(): Void;
}

typedef JqPromise2 = {
    function always(f: Void -> Void): JqPromise2;
    @:overload(function (fa: Dynamic -> Dynamic -> Void): JqPromise2{})
    function done(f: Dynamic -> Void): JqPromise2;
    function fail(f: Dynamic -> Void): JqPromise2;
    @:overload(function (fa: Dynamic -> Dynamic -> Void, ?fb: Dynamic -> Void): JqPromise2{})
    function then(fa: Dynamic -> Void, ?fb: Dynamic -> Void): JqPromise2;
    function progress(f: Dynamic -> Void): JqPromise;
    function state(): JqPromiseState;
}
typedef JqPromise3 = {
    function always(f: Void -> Void): JqPromise3;
    @:overload(function (fa: Dynamic -> Dynamic -> Dynamic -> Void): JqPromise3{})
    function done(f: Dynamic -> Void): JqPromise3;
    function fail(f: Dynamic -> Void): JqPromise3;
    @:overload(function (fa: Dynamic -> Dynamic -> Dynamic -> Void, ?fb: Dynamic -> Void): JqPromise3{})
    function then(fa: Dynamic -> Void, ?fb: Dynamic -> Void): JqPromise3;
    function progress(f: Dynamic -> Void): JqPromise;
    function state(): JqPromiseState;
}
typedef JqPromise4 = {
    function always(f: Void -> Void): JqPromise4;
    @:overload(function (fa: Dynamic -> Dynamic -> Dynamic -> Dynamic -> Void): JqPromise4{})
    function done(f: Dynamic -> Void): JqPromise4;
    function fail(f: Dynamic -> Void): JqPromise4;
    @:overload(function (fa: Dynamic -> Dynamic -> Dynamic -> Dynamic -> Void, ?fb: Dynamic -> Void): JqPromise4{})
    function then(fa: Dynamic -> Void, ?fb: Dynamic -> Void): JqPromise4;
    function progress(f: Dynamic -> Void): JqPromise;
    function state(): JqPromiseState;
}
typedef JqPromise5 = {
    function always(f: Void -> Void): JqPromise5;
    @:overload(function (fa: Dynamic -> Dynamic -> Dynamic -> Dynamic -> Dynamic -> Void): JqPromise5{})
    function done(f: Dynamic -> Void): JqPromise5;
    function fail(f: Dynamic -> Void): JqPromise5;
    @:overload(function (fa: Dynamic -> Dynamic -> Dynamic -> Dynamic -> Dynamic -> Void, ?fb: Dynamic -> Void): JqPromise5{})
    function then(fa: Dynamic -> Void, ?fb: Dynamic -> Void): JqPromise5;
    function progress(f: Dynamic -> Void): JqPromise;
    function state(): JqPromiseState;
}
