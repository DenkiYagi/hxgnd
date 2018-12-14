package hxgnd;

import buddy.BuddySuite;
import extype.Tuple;
using buddy.Should;
using hxgnd.ArrayTools;
using hxgnd.LangTools;

class ArrayToolsTest extends BuddySuite {
    public function new() {
        describe("ArrayTools.isEmpty()", {
            it("should be true", {
                [].isEmpty().should.be(true);
            });

            it("should be false", {
                [1].isEmpty().should.be(false);
            });
        });

        describe("ArrayTools.nonEmpty()", {
            it("should be false", {
                [].nonEmpty().should.be(false);
            });

            it("should be true", {
                [1].nonEmpty().should.be(true);
            });
        });

        describe("ArrayTools.toArray()", {
            it("can convert empty iterable", {
                var result = ({ iterator: function () return 0...-1 }).toArray();
                result.same([]).should.be(true);
            });

            it("can convert some values iterable", {
                var result = ({ iterator: function () return 0...3 }).toArray();
                result.same([0, 1, 2]).should.be(true);
            });

            it("can convert empty iterator", {
                var result = (0...-1).toArray();
                result.same([]).should.be(true);
            });

            it("can convert some values iterator", {
                var result = (0...3).toArray();
                result.same([0, 1, 2]).should.be(true);
            });
        });

        describe("ArrayTools.forEach()", {
            it("should not call", {
                [].forEach(function (_) {
                    fail();
                });
            });

            it("should call", {
                var i = 1;
                [1, 2, 3].forEach(function (x) {
                    LangTools.eq(x, i++).should.be(true);
                });
                i.should.be(4);
            });
        });

        describe("ArrayTools.forEachWithIndex()", {
            it("should not call", {
                [].forEachWithIndex(function (_, _) {
                    fail();
                });
            });

            it("should call", {
                var index = 0;
                var expected = ["a", "b", "c"];
                ["a", "b", "c"].forEachWithIndex(function (x, i) {
                    LangTools.eq(x, expected[index]).should.be(true);
                    LangTools.eq(i, index).should.be(true);
                    index++;
                });
                index.should.be(3);
            });
        });

        describe("ArrayTools.exists()", {
            it("should be false when it is given empty array", {
                [].exists(1).should.be(false);
            });

            it("should be true when a matched value exists in the array", {
                [0, 1, 2].exists(1).should.be(true);
            });

            it("should be false when no matched values exist in the array", {
                [0, -1, 2].exists(1).should.be(false);
            });
        });

        describe("ArrayTools.notExists()", {
            it("should be true when it is given empty array", {
                [].notExists(1).should.be(true);
            });

            it("should be false when a matched value exists in the array", {
                [0, 1, 2].notExists(1).should.be(false);
            });

            it("should be true when no matched values exist in the array", {
                [0, -1, 2].notExists(1).should.be(true);
            });
        });

        describe("ArrayTools.find()", {
            it("should be false when it is given empty array", {
                [].find(function (x) return x == 1).should.be(false);
            });

            it("should be true when a matched value exists in the array", {
                [0, 1, 2].find(function (x) return x == 1).should.be(true);
            });

            it("should be false when no matched values exist in the array", {
                [0, -1, 2].find(function (x) return x == 1).should.be(false);
            });
        });

        describe("ArrayTools.mapWithIndex()", {
            it("should not call", {
                var ret = [].mapWithIndex(function (_, _) {
                    fail();
                    return 0;
                });
                ret.same([]).should.be(true);
            });

            it("should call", {
                var index = 0;
                var expected = ["a", "b", "c"];
                var ret = ["a", "b", "c"].mapWithIndex(function (x, i) {
                    LangTools.eq(x, expected[index]).should.be(true);
                    LangTools.eq(i, index).should.be(true);
                    index++;
                    return x + i;
                });
                index.should.be(3);
                ret.same(["a0", "b1", "c2"]).should.be(true);
            });
        });

        describe("ArrayTools.zip()", {
            it("should throw", {
                (function () [].zip([1])).should.throwAnything();
                (function () [1].zip([])).should.throwAnything();
            });

            it("should be success", {
                [1].zip(["foo"])
                    .same([new Tuple2(1, "foo")]).should.be(true);

                [1,2,3].zip(["foo","bar","baz"])
                    .same([
                        new Tuple2(1, "foo"),
                        new Tuple2(2, "bar"),
                        new Tuple2(3, "baz")
                    ]).should.be(true);
            });
        });

        describe("ArrayTools.zipStringMap()", {
            it("should throw", {
                (function () [].zipStringMap([1])).should.throwAnything();
                (function () [1].zipStringMap([])).should.throwAnything();
            });

            it("should be success", {
                [1].zipStringMap(["foo"])
                    .same(["1" => "foo"]).should.be(true);

                [1,2,3].zipStringMap(["foo","bar","baz"])
                    .same([
                        "1" => "foo",
                        "2" => "bar",
                        "3" => "baz"
                    ]).should.be(true);
            });
        });

        describe("ArrayTools.head()", {
            it("should take from empty", {
                [].head().isEmpty().should.be(true);
            });
            it("should take from any", {
                [1, 2, 3].head().should.be(1);
            });

            it("should take from empty with filter", {
                [].head(function (x) return true).isEmpty().should.be(true);
                [].head(function (x) return false).isEmpty().should.be(true);
            });
            it("should take from any with filter", {
                [1, 2, 3].head(function (x) return x == 2).should.be(2);
                [1, 2, 3].head(function (x) return false).isEmpty().should.be(true);
            });
        });

        describe("ArrayTools.last()", {
            it("should take from empty", {
                [].last().isEmpty().should.be(true);
            });
            it("should take from any", {
                [1, 2, 3].last().should.be(3);
            });
        });

        describe("ArrayTools.flatten()", {
            it("should pass when it is given []", {
                [].flatten().isEmpty().should.be(true);
            });

            it("should pass when it is given [ [1, 2] ]", {
                [ [1, 2] ].flatten().should.containExactly([1, 2]);
            });

            it("should pass when it is given [ [1, 2], [], [3, 4], [5, 6] ]", {
                [ [1, 2], [], [3, 4], [5, 6] ].flatten().should.containExactly([1, 2, 3, 4, 5, 6]);
            });
        });


        describe("ArrayTools.toStringMap()", {
            it("should convert to Map from empty", {
                var map = [].toStringMap();
                map.keys().toArray().should.containExactly([]);
            });

            it("should convert to Map from any", {
                var map = [new Tuple2("key1", 10), new Tuple2("key2", 20)].toStringMap();
                map.keys().toArray().should.containAll(["key1", "key2"]);
                map.get("key1").should.be(10);
                map.get("key2").should.be(20);
            });
        });

        describe("ArrayTools.toIntMap()", {
            it("should convert to Map from empty", {
                var map = [].toIntMap();
                map.keys().toArray().should.containExactly([]);
            });

            it("should convert to Map from any", {
                var map = [new Tuple2(1, 10), new Tuple2(2, 20)].toIntMap();
                map.keys().toArray().should.containAll([1, 2]);
                map.get(1).should.be(10);
                map.get(2).should.be(20);
            });
        });

        describe("ArrayTools.toObjectMap()", {
            it("should convert to Map from empty", {
                var map = [].toObjectMap();
                map.keys().toArray().should.containExactly([]);
            });

            it("should convert to Map from any", {
                var k1 = {name: "k1"};
                var k2 = {name: "k2"};

                var map = [new Tuple2(k1, 10), new Tuple2(k2, 20)].toObjectMap();
                map.keys().toArray().should.containAll([k1, k2]);
                map.get(k1).should.be(10);
                map.get(k2).should.be(20);
            });
        });

        describe("ArrayTools.toHashMap()", {
            it("should convert to Map from empty", {
                var map = [].toHashMap();
                map.keys().toArray().should.containExactly([]);
            });

            it("should convert to Map from any", {
                var k1 = {hashCode: function () return 1};
                var k2 = {hashCode: function () return 2};

                var map = [new Tuple2(k1, 10), new Tuple2(k2, 20)].toHashMap();
                map.keys().toArray().should.containAll([k1, k2]);
                map.get(k1).should.be(10);
                map.get(k2).should.be(20);
            });
        });
    }
}
