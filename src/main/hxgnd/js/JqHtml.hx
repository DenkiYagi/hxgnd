package hxgnd.js;

import js.html.Element;
import js.html.Event;
import js.html.EventTarget;
import js.html.idb.Index;
import js.html.NodeList;

@:native("jQuery")
extern class JqHtml implements ArrayAccess<Element> {
    var length(default, never): Int;

    @:overload(function (element: EventTarget): Void{})
    @:overload(function (elements: Array<Element>): Void{})
    function new(element: Element);
    
    @:overload(function (element: Element): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (selection: JqHtml): JqHtml{})
    @:overload(function (selector: String, element: Element): JqHtml { } )
    @:overload(function (nodeList: NodeList): JqHtml{})
    function add(selector: String): JqHtml;

    function addBack(?selector: String): JqHtml;

    @:overload(function (fn: Int -> String -> String): JqHtml{})
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
    @:overload(function (fn: Int -> String -> String): JqHtml{})
    @:overload(function (fn: Int -> String -> Element): JqHtml{})
    @:overload(function (fn: Int -> String -> JqHtml): JqHtml{})
    function append(content: String): JqHtml;

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    function appendTo(selector :String): JqHtml;

    //function attr(): JqHtml;

    @:overload(function (key: String, value: String): JqHtml{})
    @:overload(function (key: String, value: Float): JqHtml{})
    @:overload(function (key: String, value: Bool): JqHtml{})
    @:overload(function (key: String, fn: Int -> String -> String): JqHtml{})
    @:overload(function (obj: Dynamic<String>): JqHtml{})
    @:overload(function (obj: {}): JqHtml{})
    function attr(key: String): String;

    //function before(): JqHtml;
    //function blur(): JqHtml;
    //function change(): JqHtml;
    
    function children(?selector: String): JqHtml;
    
    function clearQueue(?queueName: String): JqHtml;
    
    //function click(): JqHtml;
    
    @:overload(function (?withDataAndEvents: Bool): JqHtml{})
    function clone(?withDataAndEvents: Bool, ?deepWithDataAndEvents: Bool): JqHtml;

    @:overload(function (selection: JqHtml): JqHtml{})
    @:overload(function (context: Element): JqHtml{})
    function closest(selector: String, ?context: Element): JqHtml;  
    function contents(): JqHtml;

    @:overload(function (key: Array<String>): Array<String>{})
    @:overload(function (key: String, value: String): JqHtml{})
    @:overload(function (key: String, fn: Int -> String -> String): JqHtml{})
    @:overload(function (obj: Dynamic<String>): JqHtml{})
    function css(key: String): String;

    @:overload(function (key: String, value: Dynamic): JqHtml{})
    @:overload(function (obj: Dynamic<Dynamic>): JqHtml{})
    @:overload(function (obj: {}): JqHtml{})
    function data(?key: String): Dynamic;

    //function dblclick(): JqHtml;
    
    function delay(duration: Int, ?queueName: String): JqHtml;

    //function delegate(): JqHtml;
    
    function dequeue(?queueName: String): JqHtml;
    function detach(?selector: String): JqHtml;
    
    //function each(): JqHtml;

    function empty(): JqHtml;

    function end(): JqHtml;

    //function eq(): JqHtml;
    //function fadeIn(): JqHtml;
    //function fadeOut(): JqHtml;
    //function fadeTo(): JqHtml;
    //function fadeToggle(): JqHtml;
    
    @:overload(function (fn: Int -> Element -> Bool): JqHtml{})
    @:overload(function (element: Element): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (nodeList: NodeList): JqHtml{})
    @:overload(function (selection: JqHtml): JqHtml{})
    function filter(selector :String): JqHtml;

    @:overload(function (jqhtml: JqHtml): JqHtml{})
    @:overload(function (element: Element): JqHtml{})
    function find(selector: String): JqHtml;

    function finish(?queue: String): JqHtml;
    
    function first(): JqHtml;
    
    //function focus(): JqHtml;
    //function focusin(): JqHtml;
    //function focusout(): JqHtml;

    @:overload(function (): Array<Element>{})
    function get(index: Int): Element;

    @:overload(function (contained: Element): JqHtml{})
    function has(selector :String): JqHtml;
    
    function hasClass(className: String): Bool;
    
    // FIXME return string & number
    @:overload(function (value: String): JqHtml{})
    @:overload(function (value: Int): JqHtml{})
    @:overload(function (value: Float): JqHtml{})
    @:overload(function (fn: Int -> Int -> Dynamic): JqHtml {})
    function height(): Int;

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
    @:overload(function (fn: Int -> String -> String): JqHtml{})
    function html(htmlString: String): JqHtml;

    // FIXME return Number
    @:overload(function (selector: String): Int{})
    @:overload(function (element: Element): Int{})
    @:overload(function (content: JqHtml): Int{})
    function index(): Int;
    
    // FIXME return Number
    function innerHeight(): Int;
    
    // FIXME function extern あっているか不明(動きはする)
    @:overload(function (value: Int): JqHtml{})
    @:overload(function (value: Float): JqHtml{})
    @:overload(function (value: String): JqHtml{})
    @:overload(function (fn: Int -> Int -> Int): JqHtml{})
    function innerWidth(): Int;
    
    @:overload(function (target: Element): JqHtml{})
    @:overload(function (target: JqHtml): JqHtml{})
    function insertAfter(target: String): JqHtml;
    
    @:overload(function (target: Element): JqHtml{})
    @:overload(function (target: JqHtml): JqHtml{})
    function insertBefore(target: String): JqHtml;

    @:overload(function (element: Element): Bool{})
    @:overload(function (elements: Array<Element>): Bool{})
    @:overload(function (nodeList: NodeList): Bool{})
    @:overload(function (fn: Int -> Element -> Bool): Bool { } )
    @:overload(function (selection: JqHtml): Bool{})
    function is(selector: String): Bool;
    
    //function keydown(): JqHtml;
    //function keypress(): JqHtml;
    //function keyup(): JqHtml;

    function last(): JqHtml;
    
    //function load(): JqHtml;
    
    function map(fn: Int -> Element -> Dynamic): JqHtml;
    
    //function mousedown(): JqHtml;
    //function mouseenter(): JqHtml;
    //function mouseleave(): JqHtml;
    //function mousemove(): JqHtml;
    //function mouseout(): JqHtml;
    //function mouseover(): JqHtml;
    //function mouseup(): JqHtml;
    
    function next(?selector: String): JqHtml;
    
    function nextAll(?selector: String): JqHtml;
    
    @:overload(function (?element: Element, ?filter: String): JqHtml{})
    @:overload(function (?content: JqHtml, ?filter: String): JqHtml{})
    function nextUntil(?selector: String, ?filter: String): JqHtml;
    
    @:overload(function (element: Element): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (nodeList: NodeList): JqHtml{})
    @:overload(function (fn: Int -> Element -> Bool): JqHtml{})
    @:overload(function (selection: JqHtml): JqHtml{})
    function not(?selector: String): JqHtml;
    
    //function offset(): Dynamic;

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

    function outerHeight(?includeMargin: Bool): Int;
    
    function outerWidth(?includeMargin: Bool): Int;

    function parent(?selector: String): JqHtml;

    function parents(?selector: String): JqHtml;

    @:overload(function (?element: Element, ?filter: String): JqHtml{})
    @:overload(function (?content: JqHtml, ?filter: String): JqHtml{})
    function parentsUntil(?selector: String, ?filter: String): JqHtml;
    
    function position(): Dynamic;
    
    // FIXME 第2引数以降の指定方法について確認(appendも同様)
    @:overload(function (element: Element): JqHtml{})
    @:overload(function (selection: JqHtml): JqHtml{})
    @:overload(function (fn: Int -> String -> String): JqHtml{})
    @:overload(function (fn: Int -> String -> Element): JqHtml{})
    @:overload(function (fn: Int -> String -> JqHtml): JqHtml{})
    function prepend(content: String): JqHtml;
    
    @:overload(function (element: Element): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    function prependTo(selector: String): JqHtml;
    
    function prev(?selector: String): JqHtml;
    
    function prevAll(?selector: String): JqHtml;
    
    @:overload(function (?element: Element, ?filter: String): JqHtml{})
    @:overload(function (?content: JqHtml, ?filter: String): JqHtml{})
    function prevUntil(?selector: String, ?filter: String): JqHtml;

    @:overload(function (key: String, fn: Int -> String -> Dynamic): JqHtml{})
    @:overload(function (key: String, value: Dynamic): JqHtml{})
    @:overload(function (obj: Dynamic<Dynamic>): JqHtml{})
    @:overload(function (obj: {}): JqHtml{})
    function prop(key: String): Dynamic;

    //function queue(): JqHtml;
    //function ready(): JqHtml;

    function remove(?selector: String): JqHtml;

    function removeAttr(key: String): JqHtml;

    @:overload(function (fn: Int -> String -> Void): JqHtml{})
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
    @:overload(function (fn: Int -> String -> String): JqHtml{})
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