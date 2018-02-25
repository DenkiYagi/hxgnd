package hxgnd;

import utest.Assert;
import hxgnd.MacroTools;

class MacroToolsTest {
    public function new() {}

    public function test_isNull() {
        Assert.isTrue(isNull(null));
        Assert.isFalse(isNull("null"));
    }

    static macro function isNull(expr: haxe.macro.Expr) {
        return if (MacroTools.isNull(expr)) {
            macro true;
        } else {
            macro false;
        }
    }
}