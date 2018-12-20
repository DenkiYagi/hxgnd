package hxgnd.internal;

import buddy.BuddySuite;
import hxgnd.internal.ForEacherImpl;
using buddy.Should;

class ForEacherTest extends BuddySuite {
    public function new() {
        describe("ArrayForEacher", {
            describe("#forEach()", {
                it("should pass", {
                    var eacher = new ArrayForEacher([10, 20, 30]);
                    var actual = [];
                    eacher.forEach(actual.push);
                    actual.should.containExactly([10, 20, 30]);
                });
            });

            describe("#forEachWhile()", {
                it("should pass", {
                    var eacher = new ArrayForEacher([10, 20, 30, 40, 50]);
                    var actual = [];
                    eacher.forEachWhile(function (x) {
                        actual.push(x);
                        return x < 30;
                    });
                    actual.should.containExactly([10, 20, 30]);
                });
            });
        });

        describe("IntIteratorForEacher", {
            describe("#forEach()", {
                it("should pass", {
                    var eacher = new IntIteratorForEacher(1...4);
                    var actual = [];
                    eacher.forEach(actual.push);
                    actual.should.containExactly([1, 2, 3]);
                });
            });

            describe("#forEachWhile()", {
                it("should pass", {
                    var eacher = new IntIteratorForEacher(1...5);
                    var actual = [];
                    eacher.forEachWhile(function (x) {
                        actual.push(x);
                        return x < 3;
                    });
                    actual.should.containExactly([1, 2, 3]);
                });
            });
        });

        describe("IteratorForEacher", {
            describe("#forEach()", {
                it("should pass", {
                    var eacher = new IteratorForEacher([10, 20, 30].iterator());
                    var actual = [];
                    eacher.forEach(actual.push);
                    actual.should.containExactly([10, 20, 30]);
                });
            });

            describe("#forEachWhile()", {
                it("should pass", {
                    var eacher = new IteratorForEacher([10, 20, 30, 40, 50].iterator());
                    var actual = [];
                    eacher.forEachWhile(function (x) {
                        actual.push(x);
                        return x < 30;
                    });
                    actual.should.containExactly([10, 20, 30]);
                });
            });
        });

        describe("IterableForEacher", {
            describe("#forEach()", {
                it("should pass", {
                    var eacher = new IterableForEacher([10, 20, 30]);
                    var actual = [];
                    eacher.forEach(actual.push);
                    actual.should.containExactly([10, 20, 30]);
                });
            });

            describe("#forEachWhile()", {
                it("should pass", {
                    var eacher = new IterableForEacher([10, 20, 30, 40, 50]);
                    var actual = [];
                    eacher.forEachWhile(function (x) {
                        actual.push(x);
                        return x < 30;
                    });
                    actual.should.containExactly([10, 20, 30]);
                });
            });
        });
    }
}