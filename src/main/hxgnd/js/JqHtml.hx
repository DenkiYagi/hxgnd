package hxgnd.js;

import js.html.Element;
import js.html.Event;
import js.html.EventTarget;

@:native("jQuery")
extern class JqHtml implements ArrayAccess<Element> {
    var length(default, never): Int;

    @:overload(function (element: EventTarget): Void{})
    @:overload(function (elements: Array<Element>): Void{})
    function new(element: Element);

    //function add(): JqHtml;
    //function addBack(): JqHtml;

    @:overload(function (f: Int -> String -> String): JqHtml{})
    function addClass(className: String): JqHtml;

    //function after(): JqHtml;
    //function ajaxComplete(): JqHtml;
    //function ajaxError(): JqHtml;
    //function ajaxSend(): JqHtml;
    //function ajaxStart(): JqHtml;
    //function ajaxStop(): JqHtml;
    //function ajaxSuccess(): JqHtml;
    //function animate(): JqHtml;

    @:overload(function (content: Element): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    @:overload(function (f: Int -> String -> String): JqHtml{})
    @:overload(function (f: Int -> String -> Element): JqHtml{})
    @:overload(function (f: Int -> String -> JqHtml): JqHtml{})
    function append(content: String): JqHtml;

    //function appendTo(): JqHtml;
    //function attr(): JqHtml;

    @:overload(function (key: String, value: String): JqHtml{})
    @:overload(function (key: String, value: Float): JqHtml{})
    @:overload(function (key: String, value: Bool): JqHtml{})
    @:overload(function (key: String, f: Int -> String -> String): JqHtml{})
    @:overload(function (obj: Dynamic<String>): JqHtml{})
    @:overload(function (obj: {}): JqHtml{})
    function attr(key: String): String;

    //function before(): JqHtml;
    //function blur(): JqHtml;
    //function change(): JqHtml;
    //function children(): JqHtml;
    //function clearQueue(): JqHtml;
    //function click(): JqHtml;
    //function clone(): JqHtml;

    @:overload(function (selection: JqHtml): JqHtml{})
    @:overload(function (context: Element): JqHtml{})
    function closest(selector: String, ?context: Element): JqHtml;

    //function contents(): JqHtml;

    @:overload(function (key: Array<String>): Array<String>{})
    @:overload(function (key: String, value: String): JqHtml{})
    @:overload(function (key: String, f: Int -> String -> String): JqHtml{})
    @:overload(function (obj: Dynamic<String>): JqHtml{})
    function css(key: String): String;

    @:overload(function (key: String, value: Dynamic): JqHtml{})
    @:overload(function (obj: Dynamic<Dynamic>): JqHtml{})
    @:overload(function (obj: {}): JqHtml{})
    function data(?key: String): Dynamic;

    //function dblclick(): JqHtml;
    //function delay(): JqHtml;
    //function delegate(): JqHtml;
    //function dequeue(): JqHtml;
    //function detach(): JqHtml;
    //function each(): JqHtml;

    function empty(): JqHtml;

    function end(): JqHtml;

    //function eq(): JqHtml;
    //function fadeIn(): JqHtml;
    //function fadeOut(): JqHtml;
    //function fadeTo(): JqHtml;
    //function fadeToggle(): JqHtml;
    //function filter(): JqHtml;

    @:overload(function (jqhtml: JqHtml): JqHtml{})
    @:overload(function (element: Element): JqHtml{})
    function find(selector: String): JqHtml;

    //function finish(): JqHtml;
    //function first(): JqHtml;
    //function focus(): JqHtml;
    //function focusin(): JqHtml;
    //function focusout(): JqHtml;

    @:overload(function (): Array<Element>{})
    function get(index: Int): Element;

    //function has(): JqHtml;
    //function hasClass(): JqHtml;
    //function height(): JqHtml;

    @:overload(function (?duration: Int, ?easing: String, hander: Void -> Void): JqHtml{})
    @:overload(function (options: EffectOptions): JqHtml{})
    function show(): JqHtml;

    @:overload(function (?duration: Int, ?easing: String, hander: Void -> Void): JqHtml{})
    @:overload(function (options: EffectOptions): JqHtml{})
    function hide(): JqHtml;

    @:overload(function (?duration: Int, ?easing: String, hander: Void -> Void): JqHtml{})
    @:overload(function (options: EffectOptions): JqHtml{})
    function toggle(): JqHtml;

    //function hover(): JqHtml;

    @:overload(function (): String{})
    @:overload(function (f: Int -> String -> String): JqHtml{})
    function html(htmlString: String): JqHtml;

    //function index(): JqHtml;
    //function innerHeight(): JqHtml;
    //function innerWidth(): JqHtml;
    //function insertAfter(): JqHtml;
    //function insertBefore(): JqHtml;
    //function is(): JqHtml;
    //function keydown(): JqHtml;
    //function keypress(): JqHtml;
    //function keyup(): JqHtml;
    //function last(): JqHtml;
    //function load(): JqHtml;
    //function map(): JqHtml;
    //function mousedown(): JqHtml;
    //function mouseenter(): JqHtml;
    //function mouseleave(): JqHtml;
    //function mousemove(): JqHtml;
    //function mouseout(): JqHtml;
    //function mouseover(): JqHtml;
    //function mouseup(): JqHtml;
    //function next(): JqHtml;
    //function nextAll(): JqHtml;
    //function nextUntil(): JqHtml;
    //function not(): JqHtml;
    //function offset(): JqHtml;

    function offsetParent(): JqHtml;

    @:overload(function (events: String, selector: String, data: Dynamic, handler: Event -> Void): JqHtml{})
    function one(events: String, ?selector: String, handler: Event -> Void): JqHtml;

    @:overload(function (events: String, selector: String, data: Dynamic, handler: Event -> Void): JqHtml{})
    function on(events: String, ?selector: String, handler: Event -> Void): JqHtml;

    @:overload(function (): JqHtml{})
    function off(eventType: String, ?selector: String, ?handler: Event -> Void): JqHtml;

    @:overload(function (events: String, selector: String, data: Dynamic, handler: Event -> Void): JqHtml{})
    function bind(events: String, ?selector: String, handler: Event -> Void): JqHtml;

    @:overload(function (): JqHtml{})
    function unbind(eventType: String, ?selector: String, ?handler: Event -> Void): JqHtml;

    //function outerHeight(): JqHtml;
    //function outerWidth(): JqHtml;

    function parent(?selector: String): JqHtml;

    function parents(?selector: String): JqHtml;

    //function parentsUntil(): JqHtml;
    //function position(): JqHtml;
    //function prepend(): JqHtml;
    //function prependTo(): JqHtml;
    //function prev(): JqHtml;
    //function prevAll(): JqHtml;
    //function prevUntil(): JqHtml;

    @:overload(function (key: String, f: Int -> String -> Dynamic): JqHtml{})
    @:overload(function (key: String, value: Dynamic): JqHtml{})
    @:overload(function (obj: Dynamic<Dynamic>): JqHtml{})
    @:overload(function (obj: {}): JqHtml{})
    function prop(key: String): Dynamic;

    //function queue(): JqHtml;
    //function ready(): JqHtml;

    function remove(?selector: String): JqHtml;

    function removeAttr(key: String): JqHtml;

    @:overload(function (f: Int -> String -> Void): JqHtml{})
    function removeClass(className: String): JqHtml;

    @:overload(function (list: Array<String>): JqHtml{})
    function removeData(?key: String): JqHtml;

    function removeProp(key: String): JqHtml;

    //function replaceAll(): JqHtml;
    //function replaceWith(): JqHtml;
    //function resize(): JqHtml;
    //function scroll(): JqHtml;
    //function scrollLeft(): JqHtml;
    //function scrollTop(): JqHtml;
    //function select(): JqHtml;
    //function siblings(): JqHtml;
    //function size(): JqHtml;
    //function slice(): JqHtml;
    //function slideDown(): JqHtml;
    //function slideToggle(): JqHtml;
    //function slideUp(): JqHtml;
    //function stop(): JqHtml;
    //function submit(): JqHtml;
    //function text(): JqHtml;

    function toArray(): Array<Element>;

    //function toggleClass(): JqHtml;

    @:overload(function (event: Event, ?extraParameter: Dynamic): JqHtml{})
    function trigger(eventType: String, ?extraParameter: Dynamic): JqHtml;

    function triggerHandler(eventType: String, ?extraParameter: Dynamic): JqHtml;

    //function undelegate(): JqHtml;
    //function unload(): JqHtml;
    //function unwrap(): JqHtml;

    //function val(): JqHtml;
    @:overload(function (value: Dynamic): JqHtml{})
    @:overload(function (f: Int -> String -> String): JqHtml{})
    function val(): Dynamic;

    //function width(): JqHtml;
    //function wrap(): JqHtml;
    //function wrapAll(): JqHtml;
    //function wrapInner(): JqHtml;
}

typedef EffectOptions = {
    ?duration: Int,
    ?easing: String,
    ?queue: Dynamic,
    ?specialEasing: Dynamic,
    ?step: Int -> Dynamic -> Void,
    ?progress: JqPromise -> Int -> Int -> Void,
    ?complete: Void -> Void,
    ?start: JqPromise -> Void,
    ?done: JqPromise -> Bool -> Void,
    ?fail: JqPromise -> Bool -> Void,
    ?always: JqPromise -> Bool -> Void
}