package specs;

import hxmocha.Mocha;
import js.Browser;
import js.html.Element;

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
        Mocha.it("selector", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.next().addBack();
            jq.next().addBack("div");
        });
    }
    
    @:describe
    public static function appendTo(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.appendTo("div");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.appendTo(elm);
        });
        Mocha.it("selection", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.appendTo(div2);
        });
    }
    
    @:describe
    public static function children(): Void {
        Mocha.it("selector", function() {
           var jq = new JqHtml(Browser.document.body);
           jq.children();
           jq.children("div");
        });
    }
    
    @:describe
    public static function clearQueue(): Void {
        Mocha.it("clearQueue", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.clearQueue();
            div.clearQueue("queueName");
        });
    }
    
    @:describe
    public static function clone(): Void {
        Mocha.it("withDataAndEvents", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.clone();
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
    public static function delay(): Void {
        Mocha.it("duration", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.delay(100);
            jq.delay(200, "queue");
        });
    }
    
    @:describe
    public static function dequeue(): Void {
        Mocha.it("dequeue", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.dequeue();
            jq.dequeue("queue");
        });
    }
    
    @:describe
    public static function detach(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.detach();
            div.detach("div");
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
        Mocha.it("queue", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.finish();
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
        var div = new JqHtml(Browser.document.createElement("div"));
        Mocha.it("className", function() {
            div.hasClass("className");
        });
    }
    
    @:describe
    public static function height(): Void {
        var jq = new JqHtml(Browser.document.body);
        Mocha.it("call", function() {
            jq.height();
        });
        Mocha.it("int value", function() {
            jq.height(300);
        });
        Mocha.it("string value", function() {
            jq.height("400");
        });
        Mocha.it("float value", function() {
            jq.height(500.0);
        });
        Mocha.it("callback function", function() {
            //jq.height(function(i: Int, j: Int) { return 600; } );
            //jq.height(function(i: Int, j: Int) { return 700.00; } );
            jq.height(function(i: Int, j: Int) { return "800"; } );
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
    
    // FIXME function externのテスト あっているか不明(今のところ動きはする)
    @:describe
    public static function innerWidth(): Void {
        Mocha.it("call", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.innerWidth();
        });
        Mocha.it("value", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.innerWidth(300);
            div.innerWidth(400.0);
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
        Mocha.it("target element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.insertAfter(elm);
        });
        Mocha.it("target jQuery", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.insertAfter(div2);
        });
    }
    
    @:describe
    public static function insertBefore(): Void {
        Mocha.it("target string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.insertBefore("div");
        });
        Mocha.it("target element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.insertBefore(elm);
        });
        Mocha.it("target jQuery", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.insertBefore(div2);
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
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.next();
            div.next("div");
        });
    }
    
    @:describe
    public static function nextAll(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.nextAll();
            div.nextAll("div");
        });
    }

    @:describe
    public static function nextUntil(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.nextUntil();
            div.nextUntil("div");
            div.nextUntil("div", "span");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.nextUntil(elm);
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
        Mocha.it("includeMargin", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.outerHeight();
            jq.outerHeight(true);
        });
    }
    
    @:describe
    public static function outerWidth(): Void {
        Mocha.it("includeMargin", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.outerWidth();
            jq.outerWidth(true);
        });
    }
    
    @:describe
    public static function parentsUntil(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.parentsUntil();
            div.parentsUntil("div");
            div.parentsUntil("div", "span");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.parentsUntil(elm);
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
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.prepend(elm);
        });
        Mocha.it("selection", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.prepend(div2);
        });
        Mocha.it("function return string", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prepend(function (index: Int, html: String) { return "div"; } );
        });
        Mocha.it("function return element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            // FIXME テストの書き方
        });
        Mocha.it("function return jQuery", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            // FIXME テストの書き方
        });
    }
    
    @:describe
    public static function prependTo(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prependTo("div");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.prependTo(elm);
        });
        Mocha.it("selection", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("div"));
            div.prependTo(div2);
        });
    }
    
    @:describe
    public static function prev(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prev();
            div.prev("div");
        });
    }
    
    @:describe
    public static function prevAll(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prevAll();
            div.prevAll("div");
        });
    }
    
    @:describe
    public static function prevUntil(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.prevUntil();
            div.prevUntil("div");
            div.prevUntil("div", "span");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("div");
            div.prevUntil(elm);
            div.prevUntil(elm, "div");
        });
    }
    
    @:describe
    public static function replaceAll(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.replaceAll("str");
        });
        Mocha.it("element", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var elm = Browser.document.createElement("span");
            div.replaceAll(elm);
        });
        Mocha.it("content", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            var div2 = new JqHtml(Browser.document.createElement("span"));
            div.replaceAll(div2);
        });
    }
    
    @:describe
    public static function scroollLeft(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.scrollLeft();
        });
        Mocha.it("value", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.scrollLeft(100);
            div.scrollLeft(200.0);
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
            div.scrollTop(400.0);
        });
    }
    
    @:describe
    public static function siblings(): Void {
        Mocha.it("selector", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.siblings();
            div.siblings("div");
        });
    }
    
    @:describe
    public static function slice(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.slice(0);
            div.slice(1, 2);
        });
    }
    
    @:describe
    public static function text(): Void {
        Mocha.it("call", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.text();
        });
        Mocha.it("text", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.text("string");
            div.text(10);
            div.text(20.1);
            div.text(true);
        });
        Mocha.it("function", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.text(function(index: Int, text: String) { return "new text"; } );
        });
    }

    @:describe
    public static function toggleClass(): Void {
        Mocha.it("class", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.toggleClass("className");
            div.toggleClass("className", true);
        });
        Mocha.it("switch", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.toggleClass();
            div.toggleClass(true);
        });
        Mocha.it("function", function() {
            var div = new JqHtml(Browser.document.createElement("div"));
            div.toggleClass(function (index: Int, className: String, flag: Bool) { return "className"; } );
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
}