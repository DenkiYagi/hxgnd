package specs;

import hxmocha.Mocha;
import js.Browser;
import js.html.Element;
import js.html.Event;

using hxgnd.js.JqHtml;

class JqHtmlSpec {
    @:describe
    public static function add(): Void {
        Mocha.it("element", function() {
            var jq = new JqHtml(Browser.document.body);
            var div = Browser.document.createElement("div");
            jq.add(div);
        });
        Mocha.it("elements", function() {
            var jq = new JqHtml(Browser.document.body);
            var div = Browser.document.createElement("div");
            jq.add([div]);
        });
        Mocha.it("selection", function() {
            var jq = new JqHtml(Browser.document.body);
            var div = new JqHtml(Browser.document.createElement("div"));
            jq.add(div);
        });
        Mocha.it("string", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.add("div");
        });
        Mocha.it("selector, element", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.add("div", Browser.document.body);
        });
        Mocha.it("nodeList", function() {
            var jq = new JqHtml(Browser.document.body);
            var nodeList = Browser.document.getElementsByTagName("div");
            jq.add(nodeList);
        });
    }
    
    @:describe
    public static function addBack(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.next().addBack();
        });
        Mocha.it("selector", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.next().addBack("div");
        });
    }
    
    @:describe
    public static function append(): Void {
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.append(elm);
        });
        Mocha.it("elements", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.append([elm]);
        });
        Mocha.it("nodeList", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var nodeList = Browser.document.getElementsByTagName("span");
            div.append(nodeList);
        });
        Mocha.it("content", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.append("div");
        });
        Mocha.it("contents", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.append(["div"]);
        });
        Mocha.it("selection", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.append(div2);
        });
        Mocha.it("selections", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.append(div2);
        });
        Mocha.it("function string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.append(function (index: Int, value: String) { return "div"; } );
        });
        Mocha.it("function element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
             // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
            //div.append(function (index: Int, value: String) { return elm; } );
        });
        Mocha.it("function jQuery", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
             // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
            //div.append(function (index: Int, value: String) { return div2; } );
        });
    }
    
    @:describe
    public static function appendTo(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.appendTo("div");
        });
        Mocha.it("selectors", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.appendTo(["div"]);
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.appendTo(elm);
        });
        Mocha.it("elements", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.appendTo([elm]);
        });
        Mocha.it("selection", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.appendTo(div2);
        });
        Mocha.it("selections", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.appendTo([div2]);
        });
    }
    
    @:describe
    public static function blur(): Void {
        Mocha.it("call", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.blur();
        });
        Mocha.it("handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.blur(function (event: Event) { } );
        });
        Mocha.it("eventData, handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.blur( { test: 10 }, function (event: Event) { } );
        });
        Mocha.it("handler only", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.blur(function (event: Event) { } );
        });
    }
    
    @:describe
    public static function change(): Void {
        Mocha.it("call", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.change();
        });
        Mocha.it("handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.change(function (event: Event) { } );
        });
        Mocha.it("eventData, handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.change( { test: 10 }, function (event: Event) { } );
        });
        Mocha.it("handler only", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.change(function (event: Event) { } );
        });
    }
    
    @:describe
    public static function children(): Void {
        Mocha.it("call", function() {
           var jq = new JqHtml(Browser.document.body);
           jq.children();
        });
        Mocha.it("selector", function() {
           var jq = new JqHtml(Browser.document.body);
           jq.children("div");
        });
    }
    
    @:describe
    public static function clearQueue(): Void {
        Mocha.it("clearQueue", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.clearQueue();
        });
        Mocha.it("clearQueue", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.clearQueue("queueName");
        });
    }
    
    @:describe
    public static function click(): Void {
        Mocha.it("call", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.click();
        });
        Mocha.it("handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.click(function (event: Event) { } );
        });
        Mocha.it("eventData, handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.click( { test: 10 }, function (event: Event) { } );
        });
        Mocha.it("handler only", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.click(function (event: Event) { } );
        });
    }
    
    @:describe
    public static function clone(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.clone();
        });
        Mocha.it("withDataAndEvents", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.clone(true);
        });
        Mocha.it("deepWithDataAndEvents", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.clone(true, true);
        });
    }
    
    @:describe
    public static function contents(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.contents();
        });
    }
    
    @:describe
    public static function dblclick(): Void {
        Mocha.it("call", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.dblclick();
        });
        Mocha.it("handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.dblclick(function (event: Event) { } );
        });
        Mocha.it("eventData, handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.dblclick( { test: 10 }, function (event: Event) { } );
        });
        Mocha.it("handler only", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.dblclick(function (event: Event) { } );
        });
    }
    
    @:describe
    public static function delay(): Void {
        Mocha.it("duration", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.delay(100);
        });
        Mocha.it("duration queueName", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.delay(200, "queue");
        });
    }
    
    @:describe
    public static function dequeue(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.dequeue();
        });
        Mocha.it("dequeue", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.dequeue("queue");
        });
    }
    
    @:describe
    public static function detach(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.detach();
        });
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.detach("div");
        });
    }
    
    @:describe
    public static function each(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.each(function (index: Int, elm: Element) { } );
        });
    }
    
    @:describe
    public static function eq(): Void {
        Mocha.it("index", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.eq(1);
        });
        Mocha.it("indexFromEnd", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.eq(-5);
        });
    }

    @:describe
    public static function filter(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.filter("div");
        });
        Mocha.it("function", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.filter(function(i: Int, e: Element) { return true; } );
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.filter(elm);
        });
        Mocha.it("elements", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.filter([elm]);
        });
        Mocha.it("nodeList", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var nodeList = Browser.document.getElementsByTagName("div");
            div.filter(nodeList);
        });
        Mocha.it("selection", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.filter(div2);
        });
    }
    
    @:describe
    public static function finish(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.finish();
        });
        Mocha.it("queue", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.finish("queueName");
        });
    }
    
    @:describe
    public static function first(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.first();
        });
    }
    
    @:describe
    public static function focus(): Void {
        Mocha.it("call", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.click();
        });
        Mocha.it("handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.focus(function (event: Event) { } );
        });
        Mocha.it("eventData, handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.focus( { test: 10 }, function (event: Event) { } );
        });
        Mocha.it("handler only", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.focus(function (event: Event) { } );
        });
    }
    
    @:describe
    public static function focusin(): Void {
        Mocha.it("handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.focusin(function (event: Event) { } );
        });
        Mocha.it("eventData, handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.focusin( { test: 10 }, function (event: Event) { } );
        });
        Mocha.it("handler only", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.focusin(function (event: Event) { } );
        });
    }
    
    @:describe
    public static function focusout(): Void {
        Mocha.it("handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.focusout(function (event: Event) { } );
        });
        Mocha.it("eventData, handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.focusout( { test: 10 }, function (event: Event) { } );
        });
        Mocha.it("handler only", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.focusout(function (event: Event) { } );
        });
    }
    
    @:describe
    public static function has(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.has("div");
        });
        Mocha.it("contained", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.has(elm);
        });
    }
    
    @:describe
    public static function hasClass(): Void {
        Mocha.it("className", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.hasClass("className");
        });
    }
    
    @:describe
    public static function height(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.height();
        });
        Mocha.it("int value", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.height(300);
        });
        Mocha.it("string value", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.height("400");
        });
        Mocha.it("callback function int", function() {
            var jq = new JqHtml(Browser.document.body);
            // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
            //jq.height(function(i: Int, j: Int): Int { return 600; } );
        });
        Mocha.it("callback function string", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.height(function(i: Int, j: Int): String { return "800"; } );
        });
    }
    
    @:describe
    public static function hover(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.hover(function (event: Event) { }, function (event: Event) { } );
        });
    }
    
    @:describe
    public static function index(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.index();
        });
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.index("div");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.index(elm);
        });
        Mocha.it("content", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.index(div2);
        });
    }
    
    @:describe
    public static function innerHeight(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.innerHeight();
        });
    }

    @:describe
    public static function innerWidth(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.innerWidth();
        });
        Mocha.it("value int", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.innerWidth(300);
        });
        Mocha.it("value string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.innerWidth("500");
        });
        Mocha.it("function", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.innerWidth(function (index: Int, width: Int) { return 400; });
        });
    }
    
    @:describe
    public static function insertAfter(): Void {
        Mocha.it("target string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.insertAfter("div");
        });
        Mocha.it("target strings", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.insertAfter(["div"]);
        });
        Mocha.it("target element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.insertAfter(elm);
        });
        Mocha.it("target elements", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.insertAfter([elm]);
        });
        Mocha.it("target NodeList", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var nodeList = Browser.document.getElementsByTagName("div");
            div.insertAfter(nodeList);
        });
        Mocha.it("target jQuery", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.insertAfter(div2);
        });
        Mocha.it("target jQueries", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.insertAfter([div2]);
        });
    }
    
    @:describe
    public static function insertBefore(): Void {
        Mocha.it("target string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.insertBefore("div");
        });
        Mocha.it("target strings", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.insertBefore(["div"]);
        });
        Mocha.it("target element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.insertBefore(elm);
        });
        Mocha.it("target elements", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.insertBefore([elm]);
        });
        Mocha.it("target NodeList", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var nodeList = Browser.document.getElementsByTagName("div");
            div.insertBefore(nodeList);
        });
        Mocha.it("target jQuery", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.insertBefore(div2);
        });
        Mocha.it("target jQueries", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.insertBefore([div2]);
        });
    }
    
    @:describe
    public static function is(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.is("div");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.is(elm);
        });
        Mocha.it("elements", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.is([elm]);
        });
        Mocha.it("nodeList", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var nodeList = Browser.document.getElementsByTagName("div");
            div.is(nodeList);
        });
        Mocha.it("function", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.is(function (index: Int, elm: Element) { return true; } );
        });
        Mocha.it("selection", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.is(div);
        });
    }
    
    @:describe
    public static function keydown(): Void {
        Mocha.it("call", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keydown();
        });
        Mocha.it("handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keydown(function (event: Event) { } );
        });
        Mocha.it("eventData, handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keydown( { test: 10 }, function (event: Event) { } );
        });
        Mocha.it("handler only", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keydown(function (event: Event) { } );
        });
    }
    
    @:describe
    public static function keypress(): Void {
        Mocha.it("call", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keypress();
        });
        Mocha.it("handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keypress(function (event: Event) { } );
        });
        Mocha.it("eventData, handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keypress( { test: 10 }, function (event: Event) { } );
        });
        Mocha.it("handler only", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keypress(function (event: Event) { } );
        });
    }
    
    @:describe
    public static function keyup(): Void {
        Mocha.it("call", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keyup();
        });
        Mocha.it("handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keyup(function (event: Event) { } );
        });
        Mocha.it("eventData, handler", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keyup( { test: 10 }, function (event: Event) { } );
        });
        Mocha.it("handler only", function() {
           var div = new JqHtml(Browser.document.createElement("div"));
           div.keyup(function (event: Event) { } );
        });
    }
    
    @:describe
    public static function last(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.last();
        });
    }
    
    @:describe
    public static function map(): Void {
        Mocha.it("callback", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.map(function (index: Int, elm: Element) { return elm; } );
        });
    }
    
    @:describe
    public static function next(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.next();
        });
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.next("div");
        });
    }
    
    @:describe
    public static function nextAll(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.nextAll();
        });
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.nextAll("div");
        });
    }

    @:describe
    public static function nextUntil(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.nextUntil();
        });
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.nextUntil("div");
        });
        Mocha.it("selector filter", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.nextUntil("div", "div");
        });
        Mocha.it("filter only", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.nextUntil(null, "div");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.nextUntil(elm);
        });
        Mocha.it("element filter", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.nextUntil(elm, "div");
        });
    }
    
    @:describe
    public static function not(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.not("div");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.not(elm);
        });
        Mocha.it("elements", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.not([elm]);
        });
        Mocha.it("nodeList", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var nodeList = Browser.document.getElementsByTagName("div");
            div.not(nodeList);
        });
        Mocha.it("function", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.not(function (index: Int, elm: Element) { return true; } );
        });
        Mocha.it("selection", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.not(div);
        });
    }
    
    @:describe
    public static function outerHeight(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.outerHeight();
        });
        Mocha.it("includeMargin", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.outerHeight(true);
        });
    }
    
    @:describe
    public static function outerWidth(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.outerWidth();
        });
        Mocha.it("includeMargin", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.outerWidth(true);
        });
    }
    
    @:describe
    public static function parentsUntil(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.parentsUntil();
            
        });
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.parentsUntil("div");
            
        });
        Mocha.it("selector filter", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.parentsUntil("div", "span");
            
        });
        Mocha.it("filter only", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.parentsUntil(null, "span");
            
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.parentsUntil(elm);
        });
        Mocha.it("element filter", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.parentsUntil(elm, "div");
        });
    }
    
    @:describe
    public static function position(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.position();
        });
    }
    
    @:describe
    public static function prepend(): Void {
        Mocha.it("content", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prepend("div");
        });
        Mocha.it("contents", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prepend(["div"]);
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.prepend(elm);
        });
        Mocha.it("elements", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.prepend([elm]);
        });
        Mocha.it("NodeList", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var nodeList = Browser.document.getElementsByTagName("span");
            div.prepend(nodeList);
        });
        Mocha.it("selection", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.prepend(div2);
        });
        Mocha.it("selections", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.prepend([div2]);
        });
        Mocha.it("function return string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prepend(function (index: Int, html: String) { return "div"; } );
        });
        Mocha.it("function return element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
            //div.prepend(function (index: Int, html: String) { return elm; } );
        });
        Mocha.it("function return jQuery", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
            var div2 = new JqHtml(Browser.document.createElement("div"));
            //div.prepend(function (index: Int, html: String) { return div2; } );
        });
    }
    
    @:describe
    public static function prependTo(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prependTo("div");
        });
        Mocha.it("selectors", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prependTo(["div"]);
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.prependTo(elm);
        });
        Mocha.it("elements", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.prependTo([elm]);
        });
        Mocha.it("NodeList", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var nodeList = Browser.document.getElementsByTagName("span");
            div.prependTo(nodeList);
        });
        Mocha.it("selection", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.prependTo(div2);
        });
        Mocha.it("selections", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.prependTo([div2]);
        });
    }
    
    @:describe
    public static function prev(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prev();
        });
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prev("div");
        });
    }
    
    @:describe
    public static function prevAll(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prevAll();
        });
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prevAll("div");
        });
    }
    
    @:describe
    public static function prevUntil(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prevUntil();
        });
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prevUntil("div");
        });
        Mocha.it("selector filter", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prevUntil("div", "div");
        });
        Mocha.it("filter only", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prevUntil(null, "div");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.prevUntil(elm);
        });
        Mocha.it("element filter", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.prevUntil(elm, "div");
        });
    }
    
    @:describe
    public static function ready(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.ready(function () { } );
        });
    }
    
    @:describe
    public static function replaceAll(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.replaceAll("str");
        });
        Mocha.it("selectors", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.replaceAll(["str"]);
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("span");
            div.replaceAll(elm);
        });
        Mocha.it("elements", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("span");
            div.replaceAll([elm]);
        });
        Mocha.it("NodeList", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var nodeList = Browser.document.getElementsByTagName("span");
            div.replaceAll(nodeList);
        });
        Mocha.it("content", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("span"));
            div.replaceAll(div2);
        });
        Mocha.it("contents", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("span"));
            div.replaceAll([div2]);
        });
    }
    
    @:describe
    public static function scrollLeft(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.scrollLeft();
        });
        Mocha.it("value", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.scrollLeft(100);
        });
    }
    
    @:describe
    public static function scrollTop(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.scrollTop();
        });
        Mocha.it("value", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.scrollTop(300);
        });
    }
    
    @:describe
    public static function siblings(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.siblings();
        });
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.siblings("div");
        });
    }
    
    @:describe
    public static function slice(): Void {
        Mocha.it("start", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.slice(0);
        });
        Mocha.it("start end", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.slice(1, 2);
        });
    }
    
    @:describe
    public static function text(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.text();
        });
        Mocha.it("text string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.text("string");
        });
        Mocha.it("text int", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.text(10);
        });
        Mocha.it("text float", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.text(20.1);
        });
        Mocha.it("text bool", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.text(true);
        });
        Mocha.it("function", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.text(function(index: Int, text: String) { return "new text"; } );
        });
    }

    @:describe
    public static function toggleClass(): Void {
        Mocha.it("className", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.toggleClass("className");
        });
        Mocha.it("className switch", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.toggleClass("className", true);
        });
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.toggleClass();
        });
        Mocha.it("switch", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.toggleClass(true);
        });
        Mocha.it("function", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.toggleClass(function (index: Int, className: String, flag: Bool) { return "className"; } );
        });
        Mocha.it("function switch", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.toggleClass(function (index: Int, className: String, flag: Bool) { return "className"; }, true);
        });
    }
    
        
    @:describe
    public static function unwrap(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.unwrap();
        });
    }
    
    @:describe
    public static function width(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.width();
        });
        Mocha.it("value int", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.width(100);
        });
        Mocha.it("value string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.width("200");
        });
        Mocha.it("function int", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
            //div.width(function (index: Int, value: Int) { return 300; } );
        });
        Mocha.it("function string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.width(function (index: Int, value: Int) { return "400"; } );
        });
    }
    
    @:describe
    public static function wrap(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.wrap("div");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.wrap(elm);
        });
        Mocha.it("content", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.wrap(div2);
        });
        Mocha.it("function string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.wrap(function (index: Int) { return "div"; } );
        });
        Mocha.it("function jQuery", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            // TODO 戻り値が異なるfunctionのexternを利用するとコンパイルが通らない 原因不明
            //div.wrap(function (index: Int) { return div2; } );
        });
    }
    
    @:describe
    public static function wrapAll(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.wrapAll("div");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.wrapAll(elm);
        });
        Mocha.it("content", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.wrapAll(div2);
        });
    }
    
    @:describe
    public static function wrapInner(): Void {
        Mocha.it("wrappingElement", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.wrapInner("div");
        });
        Mocha.it("function", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.wrapInner(function (index: Int) { return "div"; } );
        });
    }
}