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
}