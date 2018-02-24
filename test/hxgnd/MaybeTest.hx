package hxgnd;

import utest.Assert;

class MaybeTest {
    public function new() {}

    public function test_cast() {
        var a: Maybe<Int> = 1;
        Assert.equals(a.get(), 1);

        var b: Maybe<Int> = null;
        Assert.isTrue(b.isEmpty());
    }

    public function test_operator() {
        var a: Maybe<String> = "test";
        var b: Maybe<String> = "test";
        var c: Maybe<String> = "hoge";

        Assert.isTrue(a == b);
        Assert.isFalse(a == c);
        Assert.isFalse(a == Maybe.empty());
    }

    public function test_of() {
        var a = Maybe.of(1);
        Assert.equals(a.get(), 1);
        
        Assert.raises(function () Maybe.of(null), Error);
        #if js
        Assert.raises(function () Maybe.of(js.Lib.undefined), Error);
        #end
    }

    public function test_ofNullable() {
        var a = Maybe.ofNullable(1);
        Assert.equals(a.get(), 1);

        var b = Maybe.ofNullable(null);
        Assert.isTrue(b.isEmpty());

        #if js
        var c = Maybe.ofNullable(js.Lib.undefined);
        Assert.isTrue(c.isEmpty());
        #end
    }

    public function test_empty() {
        Assert.isTrue(Maybe.empty().isEmpty());
    }

    public function test_get() {
        Assert.equals(Maybe.of(1).get(), 1);
        Assert.raises(function () Maybe.empty().get(), Error);
    }

    public function test_getOrElse() {
        Assert.equals(Maybe.of(1).getOrElse(-5), 1);
        Assert.equals(Maybe.empty().getOrElse(-6), -6);
    }

    public function test_getOrNull() {
        Assert.equals(Maybe.of(1).getOrNull(), 1);
        Assert.equals(Maybe.empty().getOrNull(), null);
    }

    public function test_isEmpty() {
        Assert.isFalse(Maybe.of(1).isEmpty());
        Assert.isTrue(Maybe.empty().isEmpty());
    }

    public function test_nonEmpty() {
        Assert.isTrue(Maybe.of(1).nonEmpty());
        Assert.isFalse(Maybe.empty().nonEmpty());
    }

    public function test_forEach() {
        Maybe.of(1).forEach(function (x) {
            Assert.equals(x, 1);
        });

        Maybe.empty().forEach(function (x) {
            Assert.fail();
        });
        Assert.pass();
    }

    public function test_map() {
        var ret = Maybe.of(1).map(function (x) {
            Assert.equals(x, 1);
            return x + 1;
        });
        Assert.equals(ret, 2);
        
        Maybe.empty().map(function (x) {
            Assert.fail();
            return 0;
        });
        Assert.pass();
    }

    public function test_flatMap() {
        var ret1 = Maybe.of(1).flatMap(function (x) {
            Assert.equals(x, 1);
            return Maybe.of(x + 1);
        });
        Assert.equals(ret1.get(), 2);

        var ret2 = Maybe.of(1).flatMap(function (x) {
            return Maybe.empty();
        });
        Assert.isTrue(ret2.isEmpty());

        Maybe.empty().flatMap(function (x) {
            Assert.fail();
            return Maybe.empty();
        });
        Assert.pass();
    }

    public function test_filter() {
        var ret1 = Maybe.of(2).filter(function (x) {
            Assert.equals(x, 2);
            return x == 2;
        });
        Assert.equals(ret1, 2);

        var ret2 = Maybe.of(2).filter(function (x) {
            return x == 0;
        });
        Assert.isTrue(ret2.isEmpty());

        Maybe.empty().filter(function (x) {
            Assert.fail();
            return true;
        });
        Assert.pass();
    }
}