package hxgnd.internal;

import buddy.BuddySuite;
import hxgnd.internal.ForEacherImpl;
using buddy.Should;

class ForEacherImplTest extends BuddySuite {
    public function new() {
        describe("ArrayForEacher", {
            describe("#forEach()", {
                function test(src, expect) {
                    var eacher = new ArrayForEacher(src);
                    var actual = [];
                    eacher.forEach(actual.push);
                    actual.should.containExactly(expect);
                }

                it("should pass", {
                    test([], []);
                    test([10, 20, 30], [10, 20, 30]);
                });
            });

            describe("#forEachWhile()", {
                function test(src, expect) {
                    var eacher = new ArrayForEacher(src);
                    var actual = [];
                    eacher.forEachWhile(function (x) {
                        actual.push(x);
                        return x < 30;
                    });
                    actual.should.containExactly(expect);
                }

                it("should pass", {
                    test([], []);
                    test([10, 20], [10, 20]);
                    test([10, 20, 30], [10, 20, 30]);
                    test([10, 20, 30, 40, 50], [10, 20, 30]);
                    test([10, 20, 30, 29], [10, 20, 30]);
                });
            });
        });

        describe("IntIteratorForEacher", {
            describe("#forEach()", {
                function test(src, expect) {
                    var eacher = new IntIteratorForEacher(src);
                    var actual = [];
                    eacher.forEach(actual.push);
                    actual.should.containExactly(expect);
                }

                it("should pass", {
                    test(0...0, []);
                    test(1...4, [1, 2, 3]);
                });
            });

            describe("#forEachWhile()", {
                function test(src, expect) {
                    var eacher = new IntIteratorForEacher(src);
                    var actual = [];
                    eacher.forEachWhile(function (x) {
                        actual.push(x);
                        return x < 3;
                    });
                    actual.should.containExactly(expect);
                }

                it("should pass", {
                    test(0...0, []);
                    test(1...3, [1, 2]);
                    test(1...4, [1, 2, 3]);
                    test(1...6, [1, 2, 3]);
                });
            });
        });

        describe("IteratorForEacher", {
            describe("#forEach()", {
                function test(src, expect) {
                    var eacher = new IteratorForEacher(src);
                    var actual = [];
                    eacher.forEach(actual.push);
                    actual.should.containExactly(expect);
                }

                it("should pass", {
                    test([].iterator(), []);
                    test([1, 2, 3, 4, 5].iterator(), [1, 2, 3, 4, 5]);
                });
            });

            describe("#forEachWhile()", {
                function test(src, expect) {
                    var eacher = new IteratorForEacher(src);
                    var actual = [];
                    eacher.forEachWhile(function (x) {
                        actual.push(x);
                        return x < 30;
                    });
                    actual.should.containExactly(expect);
                }

                it("should pass", {
                    test([].iterator(), []);
                    test([10, 20].iterator(), [10, 20]);
                    test([10, 20, 30].iterator(), [10, 20, 30]);
                    test([10, 20, 30, 40, 50].iterator(), [10, 20, 30]);
                    test([10, 20, 30, 29].iterator(), [10, 20, 30]);
                });
            });
        });
    }
}