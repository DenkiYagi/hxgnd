package specs;

import hxmocha.Mocha;
import js.Browser;

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
    public static function next(): Void {
        Mocha.it("selector", function() {
            var jq = new JqHtml(Browser.document.body);
            jq.next();
            jq.next("div");
        });
    }
}