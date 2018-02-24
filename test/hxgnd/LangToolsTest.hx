package hxgnd;

import utest.Assert;

using hxgnd.LangTools;

class LangToolsTest {
    public function new() {}

    public function test_eq() {
        Assert.isTrue(0.eq(0));
        Assert.isTrue("hello".eq("hello"));
        var a = 1;
        var b = 1;
        Assert.isTrue(a.eq(b));
        
        Assert.isFalse(0.eq(null));
        Assert.isFalse(0.eq(1));
        Assert.isFalse("hello".eq("fuga"));
        var x = 1;
        var y = 2;
        Assert.isFalse(x.eq(y));
    }

    public function test_neq() {
        Assert.isFalse(0.neq(0));
        Assert.isFalse("hello".neq("hello"));
        var a = 1;
        var b = 1;
        Assert.isFalse(a.neq(b));
        
        Assert.isTrue(0.neq(null));
        Assert.isTrue(0.neq(1));
        Assert.isTrue("hello".neq("fuga"));
        var x = 1;
        var y = 2;
        Assert.isTrue(x.neq(y));
    }

    public function test_isNull() {
        //Assert.isTrue(null.isNull());
        Assert.isTrue(LangTools.isNull(null));
        Assert.isFalse(0.isNull());
        Assert.isFalse("".isNull());
        var a: Null<Int> = null;
        var b = 1;
        Assert.isTrue(a.isNull());
        Assert.isFalse(b.isNull());

        #if js
        Assert.isTrue(LangTools.isNull(js.Lib.undefined));
        #end
    }

    public function test_nonNull() {
        //Assert.isTrue(null.isNull());
        Assert.isFalse(LangTools.nonNull(null));
        Assert.isTrue(0.nonNull());
        Assert.isTrue("".nonNull());
        var a: Null<Int> = null;
        var b = 1;
        Assert.isFalse(a.nonNull());
        Assert.isTrue(b.nonNull());

        #if js
        Assert.isFalse(LangTools.nonNull(js.Lib.undefined));
        #end
    }

    #if js
    public function test_isUndefined() {
        Assert.isTrue(LangTools.isUndefined(js.Lib.undefined));
        var a: Int = js.Lib.undefined;
        Assert.isTrue(a.isUndefined());

        Assert.isFalse(0.isUndefined());
        Assert.isFalse("".isUndefined());
        Assert.isFalse(LangTools.isUndefined(null));
    }
    #end

    public function test_toMaybe() {
        var a: Null<Int> = 1;
        var b: Null<Int> = null;
        Assert.isTrue(a.toMaybe().nonEmpty());
        Assert.isTrue(b.toMaybe().isEmpty());
    }

    public function test_isEmpty() {
        var x: String = null;
        Assert.isTrue(x.isEmpty());
        Assert.isTrue("".isEmpty());
        Assert.isFalse(" ".isEmpty());
        Assert.isFalse("　".isEmpty());
        Assert.isFalse("a".isEmpty());
        
        #if js
        var y: String = js.Lib.undefined;
        Assert.isTrue(y.isBlank());
        #end
    }

    public function test_nonEmpty() {
        var x: String = null;
        Assert.isFalse(x.nonEmpty());
        Assert.isFalse("".nonEmpty());
        Assert.isTrue(" ".nonEmpty());
        Assert.isTrue("　".nonEmpty());
        Assert.isTrue("a".nonEmpty());
        
        #if js
        var y: String = js.Lib.undefined;
        Assert.isFalse(y.nonEmpty());
        #end
    }

    public function test_isBlank() {
        var x: String = null;
        Assert.isTrue(x.isBlank());

        Assert.isTrue("".isBlank());
        Assert.isTrue(" ".isBlank());
        Assert.isTrue("　".isBlank());
        Assert.isTrue("\u3000".isBlank());
        #if js
        Assert.isTrue(("\u0009\u000A\u000B\u000C\u000D\u0085\u0020\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000" + untyped __js__("'\\u2028'") + untyped __js__("'\\u2029'")).isBlank());
        #else
        Assert.isTrue("\u0009\u000A\u000B\u000C\u000D\u0085\u0020\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000\u2028\u2029".isBlank());
        #end
        Assert.isFalse(" a".isBlank());
        Assert.isFalse(" \u2030".isBlank());

        #if js
        var y: String = js.Lib.undefined;
        Assert.isTrue(y.isBlank());
        #end
    }

    public function test_nonBlank() {
        var x: String = null;
        Assert.isFalse(x.nonBlank());

        Assert.isFalse("".nonBlank());
        Assert.isFalse(" ".nonBlank());
        Assert.isFalse("　".nonBlank());
        Assert.isFalse("\u3000".nonBlank());
        #if js
        Assert.isFalse(("\u0009\u000A\u000B\u000C\u000D\u0085\u0020\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000" + untyped __js__("'\\u2028'") + untyped __js__("'\\u2029'")).nonBlank());
        #else
        Assert.isFalse("\u0009\u000A\u000B\u000C\u000D\u0085\u0020\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000\u2028\u2029".nonBlank());
        #end
        Assert.isTrue(" a".nonBlank());
        Assert.isTrue(" \u2030".nonBlank());

        #if js
        var y: String = js.Lib.undefined;
        Assert.isFalse(y.nonBlank());
        #end
    }
}