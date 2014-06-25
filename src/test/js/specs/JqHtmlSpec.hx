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
    public static function next(): Void {
        Mocha.it("selector", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.next();
            jq.next("div");
        });
    }
}