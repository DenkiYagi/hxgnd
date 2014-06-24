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
        var jq = new JqHtml(Browser.document.body);
        Mocha.it("selector", function() {
            jq.appendTo("str");
        });
        Mocha.it("element", function() {
            jq.appendTo(Browser.document.body);
        });
        Mocha.it("selection", function() {
            jq.appendTo(jq);
        });
    }
    
    @:describe
    public static function children(): Void {
        var jq = new JqHtml(Browser.document.body);
        Mocha.it("selector", function() {
           jq.children();
           jq.children("str");
        });
    }
    
    @:describe
    public static function contents(): Void {
        var jq = new JqHtml(Browser.document.body);
        Mocha.it("call", function() {
            jq.contents();
        });
    }
    
    @:describe
    public static function delay(): Void {
        var jq = new JqHtml(Browser.document.body);
        Mocha.it("duration", function() {
            jq.delay(100);
            jq.delay(200, "queue");
        });
    }
    
    @:describe
    public static function dequeue(): Void {
        var jq = new JqHtml(Browser.document.body);
        Mocha.it("dequeue", function() {
            jq.dequeue();
            jq.dequeue("queue");
        });
    }
    
    @:describe
    public static function detach(): Void {
        var jq = new JqHtml(Browser.document.body);
        Mocha.it("selector", function() {
            jq.detach("selector");
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