package hxgnd;

import utest.Assert;

using hxgnd.ArrayTools;

class ArrayToolsTest {
    public function new() {}

    public function test_toArray() {
        Assert.same([].iterator().toArray(), []);
        Assert.same([1, 2, 3], [1, 2, 3].iterator().toArray());

        var iterable1: Iterable<Int> = [];
        Assert.same([], iterable1.toArray());

        var iterable2: Iterable<Int> = [4, 5, 6];
        Assert.same([4, 5, 6], iterable2.toArray());
    }

    public function test_forEach() {
        [].forEach(function (x) {
            Assert.fail();
        });

        var i = 1;
        [1, 2, 3].forEach(function (x) {
            Assert.equals(i++, x);
        });
        Assert.equals(4, i);
    }

    public function test_forEachWithIndex() {
        [].forEachWithIndex(function (x, i) {
            Assert.fail();
        });

        var expected = ["a", "b", "c"];
        var index = 0;
        ["a", "b", "c"].forEachWithIndex(function (x, i) {
            Assert.equals(expected[index], x);
            Assert.equals(index, i);
            index++;
        });
        Assert.equals(3, index);
    }

    public function test_mapWithIndex() {
        var ret1 = [].mapWithIndex(function (x, i) {
            Assert.fail();
            return x;
        });
        Assert.same([], ret1);

        var expected = ["a", "b", "c"];
        var index = 0;
        var ret2 = ["a", "b", "c"].mapWithIndex(function (x, i) {
            Assert.equals(expected[index], x);
            Assert.equals(index, i);
            index++;
            return x + i;
        });
        Assert.equals(3, index);
        Assert.same(["a0", "b1", "c2"], ret2);
    }

    public function test_zip() {
        Assert.raises(function () {
            [].zip([1]);
        });
        Assert.raises(function () {
            ["hello"].zip([]);
        });

        Assert.same([{value1: 1, value2: "foo"}], [1].zip(["foo"]));
        Assert.same([
            {value1: 1, value2: "foo"},
            {value1: 2, value2: "bar"},
            {value1: 3, value2: "baz"}
        ], [1,2,3].zip(["foo","bar","baz"]));
    }

    public function test_zipStringMap() {
        Assert.raises(function () {
            [].zipStringMap([1]);
        });
        Assert.raises(function () {
            ["hello"].zipStringMap([]);
        });

        var map1 = [1].zipStringMap(["foo"]);
        var keys1 = map1.keys().toArray();
        Assert.equals(1, keys1.length);
        Assert.equals("foo", map1.get("1"));

        var map2 = [1, 2, 3].zipStringMap(["foo", "bar", "baz"]);
        var keys2 = map2.keys().toArray();
        Assert.equals(3, keys2.length);
        Assert.equals("foo", map2.get("1"));
        Assert.equals("bar", map2.get("2"));
        Assert.equals("baz", map2.get("3"));
    }

    public function test_head() {
        Assert.isTrue([].head().isEmpty());
        Assert.equals(1, [1, 2, 3].head());

        Assert.isTrue([].head(function (x) return true).isEmpty());
        Assert.isTrue([].head(function (x) return false).isEmpty());

        Assert.equals(2, [1, 2, 3].head(function (x) return x == 2));
        Assert.isTrue([1, 2, 3].head(function (x) return x == 100).isEmpty());
    }
}
