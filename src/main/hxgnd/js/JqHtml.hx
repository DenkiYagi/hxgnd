package hxgnd.js;

import hxgnd.js.JqHtml.EffectOptions;
import js.html.Element;
import js.html.Event;
import js.html.EventTarget;
import js.html.idb.Index;
import js.html.NodeList;
import js.html.XMLHttpRequest;
import hxgnd.js.JQuery.JqAjaxSettings;

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

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (nodeList: NodeList): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    @:overload(function (contents: Array<JqHtml>): JqHtml { } )
    // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
    @:overload(function (fn: Int -> String -> String): JqHtml{})
    @:overload(function (fn: Int -> String -> Element): JqHtml{})
    @:overload(function (fn: Int -> String -> JqHtml): JqHtml{})
    @:overload(function (contents: Array<String>): JqHtml{})
    function after(content: String): JqHtml;

    function ajaxComplete(fn: Event -> XMLHttpRequest -> JqAjaxSettings -> Void): JqHtml;

    function ajaxError(fn: Event -> XMLHttpRequest -> JqAjaxSettings -> String -> Void): JqHtml;

    function ajaxSend(fn: Event -> XMLHttpRequest -> JqAjaxSettings -> Void): JqHtml;

    function ajaxStart(fn: Void -> Void): JqHtml;

    function ajaxStop(fn: Void -> Void): JqHtml;

    function ajaxSuccess(fn: Event -> XMLHttpRequest -> JqAjaxSettings -> Dynamic -> Void): JqHtml;

    @:overload(function (properties: Dynamic<Dynamic>, options: EffectOptions): JqHtml{})
    @:overload(function (properties: {}, options: EffectOptions): JqHtml{})
    @:overload(function (properties: {}, ?duration: Int, ?easing: String, ?fn: Void -> Void): JqHtml{})
    function animate(properties: Dynamic<Dynamic>, ?duration: Int, ?easing: String, ?fn: Void -> Void): JqHtml;

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (nodeList: NodeList): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    @:overload(function (contents: Array<JqHtml>): JqHtml { } )
    // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
    @:overload(function (fn: Int -> String -> String): JqHtml{})
    @:overload(function (fn: Int -> String -> Element): JqHtml{})
    @:overload(function (fn: Int -> String -> JqHtml): JqHtml{})
    @:overload(function (contents: Array<String>): JqHtml{})
    function append(content: String): JqHtml;

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (contents: Array<JqHtml>): JqHtml { } )
    @:overload(function (selectors: Array<String>): JqHtml{})
    function appendTo(selector :String): JqHtml;

    @:overload(function (key: String, value: String): JqHtml{})
    @:overload(function (key: String, value: Float): JqHtml{})
    @:overload(function (key: String, value: Bool): JqHtml{})
    @:overload(function (key: String, fn: Int -> String -> String): JqHtml{})
    @:overload(function (obj: Dynamic<String>): JqHtml{})
    @:overload(function (obj: {}): JqHtml{})
    function attr(key: String): String;

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (nodeList: NodeList): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    @:overload(function (contents: Array<JqHtml>): JqHtml { } )
    // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
    @:overload(function (fn: Int -> String -> String): JqHtml{})
    @:overload(function (fn: Int -> String -> Element): JqHtml{})
    @:overload(function (fn: Int -> String -> JqHtml): JqHtml{})
    @:overload(function (contents: Array<String>): JqHtml{})
    function before(content: String): JqHtml;

    @:overload(function (?eventData: Dynamic, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function blur(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: Dynamic, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function change(fn: Event -> Void): JqHtml;

    function children(?selector: String): JqHtml;

    function clearQueue(?queueName: String): JqHtml;

    @:overload(function (?eventData: Dynamic, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function click(fn: Event -> Void): JqHtml;

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

    @:overload(function (?eventData: Dynamic, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function dblclick(fn: Event -> Void): JqHtml;

    function delay(duration: Int, ?queueName: String): JqHtml;

    @:overload(function (selector: String, eventType: String, eventData: Dynamic, handler: Event -> Void): JqHtml{})
    @:overload(function (selector: String, events: Dynamic<Event -> Void>): JqHtml{})
    function delegate(selector: String, eventType: String, handler: Event -> Void): JqHtml;

    function dequeue(?queueName: String): JqHtml;

    function detach(?selector: String): JqHtml;

    function each(fn: Int -> Element -> Void): JqHtml;

    function empty(): JqHtml;

    function end(): JqHtml;

    function eq(index: Int): JqHtml;

    @:overload(function (options: EffectOptions): JqHtml{})
    @:overload(function (?duration: Int, ?easing: String, ?fn: Void -> Void): JqHtml{})
    function fadeIn(?duration: Int, ?fn: Void -> Void): JqHtml;

    @:overload(function (options: EffectOptions): JqHtml{})
    @:overload(function (?duration: Int, ?easing: String, ?fn: Void -> Void): JqHtml{})
    function fadeOut(?duration: Int, ?fn: Void -> Void): JqHtml;

    @:overload(function (duration: Int, opacity: Float, ?easing: String, ?fn: Void -> Void): JqHtml{})
    function fadeTo(duration: Int, opacity: Float, ?fn: Void -> Void): JqHtml;

    @:overload(function (options: EffectOptions): JqHtml{})
    function fadeToggle(?duration: Int, ?easing: String, ?fn: Void -> Void): JqHtml;

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

    @:overload(function (?eventData: Dynamic, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function focus(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: Dynamic, fn: Event -> Void): JqHtml{})
    function focusin(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: Dynamic, fn: Event -> Void): JqHtml{})
    function focusout(fn: Event -> Void): JqHtml;

    @:overload(function (): Array<Element>{})
    function get(index: Int): Element;

    @:overload(function (contained: Element): JqHtml{})
    function has(selector :String): JqHtml;

    function hasClass(className: String): Bool;

    @:overload(function (value: String): JqHtml{})
    @:overload(function (value: Int): JqHtml{})
    // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
    @:overload(function (fn: Int -> Int -> String): JqHtml{})
    @:overload(function (fn: Int -> Int -> Int): JqHtml {})
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

    function hover(handlerIn: Event -> Void, handlerOut: Event -> Void): JqHtml;

    @:overload(function (): String{})
    @:overload(function (fn: Int -> String -> String): JqHtml{})
    function html(htmlString: String): JqHtml;

    @:overload(function (selector: String): Int{})
    @:overload(function (element: Element): Int{})
    @:overload(function (content: JqHtml): Int{})
    function index(): Int;

    function innerHeight(): Int;

    @:overload(function (value: Int): JqHtml{})
    @:overload(function (value: String): JqHtml{})
    @:overload(function (fn: Int -> Int -> Int): JqHtml{})
    function innerWidth(): Int;

    @:overload(function (target: Element): JqHtml{})
    @:overload(function (targets: Array<Element>): JqHtml{})
    @:overload(function (target: NodeList): JqHtml{})
    @:overload(function (target: JqHtml): JqHtml{})
    @:overload(function (targets: Array<JqHtml>): JqHtml{})
    @:overload(function (targets: Array<String>): JqHtml{})
    function insertAfter(target: String): JqHtml;

    @:overload(function (target: Element): JqHtml{})
    @:overload(function (targets: Array<Element>): JqHtml{})
    @:overload(function (target: NodeList): JqHtml{})
    @:overload(function (target: JqHtml): JqHtml{})
    @:overload(function (targets: Array<JqHtml>): JqHtml{})
    @:overload(function (targets: Array<String>): JqHtml{})
    function insertBefore(target: String): JqHtml;

    @:overload(function (element: Element): Bool{})
    @:overload(function (elements: Array<Element>): Bool{})
    @:overload(function (nodeList: NodeList): Bool{})
    @:overload(function (fn: Int -> Element -> Bool): Bool { } )
    @:overload(function (selection: JqHtml): Bool{})
    function is(selector: String): Bool;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function keydown(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function keypress(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function keyup(fn: Event -> Void): JqHtml;

    function last(): JqHtml;

    @:overload(function (url: String, ?data: Dynamic<String>, ?fn: String -> String -> XMLHttpRequest -> Void): JqHtml{})
    function load(url: String, ?data: String, ?fn: String -> String -> XMLHttpRequest -> Void): JqHtml;

    function map<T>(fn: Int -> Element -> T): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function mousedown(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function mouseenter(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function mouseleave(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function mousemove(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function mouseout(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function mouseover(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function mouseup(fn: Event -> Void): JqHtml;

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

    @:overload(function (coodinates: { top: Int, left: Int}): JqHtml{})
    @:overload(function (fn: Int -> { top: Int, left: Int} -> { top: Int, left: Int}): JqHtml{})
    function offset(): { top: Int, left: Int};

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

    function position(): { top: Int, left: Int};

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (nodeList: NodeList): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    @:overload(function (contents: Array<JqHtml>): JqHtml{})
    @:overload(function (fn: Int -> String -> String): JqHtml{})
    // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
    @:overload(function (fn: Int -> String -> Element): JqHtml{})
    @:overload(function (fn: Int -> String -> JqHtml): JqHtml{})
    @:overload(function (selectors: Array<String>): JqHtml{})
    function prepend(content: String): JqHtml;

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (nodeList: NodeList): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    @:overload(function (contents: Array<JqHtml>): JqHtml{})
    @:overload(function (selectors: Array<String>): JqHtml{})
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

    @:overload(function (?queueName: String, fn: Void -> Void): JqHtml{})
    function queue(?queueName: String, newQueue: Array<Void -> Void>): JqHtml;

    function ready(fn:  Void -> Void): JqHtml;

    function remove(?selector: String): JqHtml;

    function removeAttr(key: String): JqHtml;

    @:overload(function (fn: Int -> String -> Void): JqHtml{})
    function removeClass(className: String): JqHtml;

    @:overload(function (list: Array<String>): JqHtml{})
    function removeData(?key: String): JqHtml;

    function removeProp(key: String): JqHtml;

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (nodeList: NodeList): JqHtml{})
    @:overload(function (contents: JqHtml): JqHtml{})
    @:overload(function (contents: Array<JqHtml>): JqHtml{})
    @:overload(function (selectors: Array<String>): JqHtml{})
    function replaceAll(selector: String): JqHtml;

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (elements: Array<Element>): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    @:overload(function (contents: Array<JqHtml>): JqHtml{})
    @:overload(function (fn: Void -> Void): JqHtml{})
    @:overload(function (htmls: Array<String>): JqHtml{})
    function replaceWith(html: String): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function resize(fn: Event -> Void): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function scroll(fn: Event -> Void): JqHtml;

    @:overload(function (value: Int): JqHtml{})
    function scrollLeft(): Int;

    @:overload(function (value: Int): JqHtml{})
    function scrollTop(): Int;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function select(fn: Event -> Void): JqHtml;

    function siblings(?selector: String): JqHtml;

    function slice(start: Int, ?end: Int): JqHtml;

    @:overload(function (options: EffectOptions): JqHtml{})
    @:overload(function (?duration: Int, ?easing: String, ?fn: Void -> Void): JqHtml{})
    function slideDown(?duration: Int, ?fn: Void -> Void): JqHtml;

    @:overload(function (options: EffectOptions): JqHtml{})
    @:overload(function (?duration: Int, ?easing: String, ?fn: Void -> Void): JqHtml{})
    function slideToggle(?duration: Int, ?fn: Void -> Void): JqHtml;

    @:overload(function (options: EffectOptions): JqHtml{})
    @:overload(function (?duration: Int, ?easing: String, ?fn: Void -> Void): JqHtml{})
    function slideUp(?duration: Int, ?fn: Void -> Void): JqHtml;

    @:overload(function (?queueName: String, ?clearQueue: Bool, ?jumpToEnd: Bool): JqHtml{})
    function stop(?clearQueue: Bool, ?jumpToEnd: Bool): JqHtml;

    @:overload(function (?eventData: {}, fn: Event -> Void): JqHtml{})
    @:overload(function (): JqHtml{})
    function submit(fn: Event -> Void): JqHtml;

    @:overload(function (text: String): JqHtml{})
    @:overload(function (text: Int): JqHtml{})
    @:overload(function (text: Float): JqHtml{})
    @:overload(function (text: Bool): JqHtml{})
    @:overload(function (fn: Int -> String -> String): JqHtml{})
    function text(): String;

    function toArray(): Array<Element>;

    @:overload(function (?flag: Bool): JqHtml{})
    @:overload(function (fn: Int -> String -> Bool -> String, ?flag: Bool): JqHtml{})
    function toggleClass(className: String, ?flag: Bool): JqHtml;

    @:overload(function (event: Event, ?extraParameter: Dynamic): JqHtml{})
    function trigger(eventType: String, ?extraParameter: Dynamic): JqHtml;

    function triggerHandler(eventType: String, ?extraParameter: Dynamic): JqHtml;

    @:overload(function (namespace: String): JqHtml{})
    @:overload(function (selector: String, eventType: String): JqHtml{})
    @:overload(function (selector: String, eventType: String, handler: Event -> Void): JqHtml { } )
    @:overload(function (Selector: String, events: Dynamic<Event -> Void>): JqHtml{})
    function undelegate(): JqHtml;

    @:overload(function (?eventData: Dynamic, fn: Event -> Void): JqHtml{})
    function unload(fn: Event -> Void): JqHtml;

    function unwrap(): JqHtml;

    @:overload(function (value: Dynamic): JqHtml{})
    @:overload(function (fn: Int -> String -> String): JqHtml{})
    function val(): Dynamic;

    @:overload(function (value: String): JqHtml{})
    @:overload(function (value: Int): JqHtml{})
    // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
    @:overload(function (fn: Int -> Int -> String): JqHtml{})
    @:overload(function (fn: Int -> Int -> Int): JqHtml{})
    function width(): Int;

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
    @:overload(function (fn: Int -> String): JqHtml{})
    @:overload(function (fn: Int -> JqHtml): JqHtml{})
    function wrap(selector: String): JqHtml;

    @:overload(function (element: Element): JqHtml{})
    @:overload(function (content: JqHtml): JqHtml{})
    function wrapAll(selector: String): JqHtml;

    @:overload(function (fn: Int -> String): JqHtml{})
    function wrapInner(wrappingElement: String): JqHtml;
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