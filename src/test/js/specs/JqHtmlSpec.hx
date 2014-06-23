package specs;

import hxmocha.Mocha;
import js.Browser;

using hxgnd.js.JqHtml;

class JqHtmlSpec {    
    @:describe
    public static function add(): Void {
        var jq = new JqHtml(Browser.document.body);
        Mocha.it("element", function() {
            jq.add(Browser.document.body);
        });
        Mocha.it("elements", function() {
            jq.add([Browser.document.body]);
        });
        // selection or content?
        Mocha.it("selection", function() {
            jq.add(jq);
        });
        Mocha.it("string", function() {
            jq.add("str");
        });
        Mocha.it("selector, element", function() {
            jq.add("str", Browser.document.body);
        });
    }
    
    @:describe
    public static function addBack(): Void {
        var jq = new JqHtml(Browser.document.body);
        Mocha.it("selector", function() {
            jq.addBack();
            //jq.addBack("body");
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
    
    public static function detach(): Void {
        var jq = new JqHtml(Browser.document.body);
        Mocha.it("selector", function() {
            jq.detach("selector");
        });
    }
}