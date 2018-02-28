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
}
