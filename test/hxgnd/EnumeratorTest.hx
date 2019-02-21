package hxgnd;

import buddy.BuddySuite;
import hxgnd.Enumerator;
using buddy.Should;

class EnumeratorTest extends BuddySuite {
    public function new() {
        describe("Enumerator.from()", {
            function test<T>(factory: Void -> Enumerator<T>, expect: Array<T>) {
                it("should pass", {
                    var actual = [];
                    factory().forEach(actual.push);
                    actual.should.containExactly(expect);
                });
            }

            describe("Array", {
                test(function () return Enumerator.from([]), []);
                test(function () return Enumerator.from([1]), [1]);
                test(function () return Enumerator.from([1, 2, 3]), [1, 2, 3]);
            });

            describe("IntIterator", {
                test(function () return Enumerator.from(0...0), []);
                test(function () return Enumerator.from(0...1), [0]);
                test(function () return Enumerator.from(0...5), [0, 1, 2, 3, 4]);
            });

            describe("Iterator<T>", {
                test(function () return Enumerator.from([].iterator()), []);
                test(function () return Enumerator.from([1].iterator()), [1]);
                test(function () return Enumerator.from([1, 2, 3].iterator()), [1, 2, 3]);
            });

            describe(" Iterable<T>", {
                test(function () return Enumerator.from(([]: Iterable<Int>)), []);
                test(function () return Enumerator.from(([1]: Iterable<Int>)), [1]);
                test(function () return Enumerator.from(([1, 2, 3]: Iterable<Int>)), [1, 2, 3]);
            });
        });

        describe("Enumerator#traverser()", {
            describe("empty source", {
                it("should pass", {
                    var actual = [];
                    var traverser = Enumerator.from([]).traverser();
                    traverser.forEach(actual.push);
                    actual.should.containExactly([]);
                });
            });

            describe("non empty source", {
                it("should pass", {
                    var actual = [];
                    var traverser = Enumerator.from([1, 2, 3, 4, 5]);
                    traverser.forEach(actual.push);
                    actual.should.containExactly([1, 2, 3, 4, 5]);
                });
            });
        });

        describe("Enumerator#forEach()", {
            describe("empty source", {
                it("should pass", {
                    var actual = [];
                    Enumerator.from([]).forEach(actual.push);
                    actual.should.containExactly([]);
                });
            });

            describe("non empty source", {
                it("should pass", {
                    var actual = [];
                    Enumerator.from([1, 2, 3, 4, 5]).forEach(actual.push);
                    actual.should.containExactly([1, 2, 3, 4, 5]);
                });
            });
        });

        describe("Enumerator#map()", {
            describe("empty source", {
                it("should pass when it is given a mapper", {
                    var actual = [];
                    Enumerator.from([])
                        .map(function (x) return x * 10)
                        .forEach(actual.push);
                    actual.should.containExactly([]);
                });

                it("should pass when it is given 2 mappers", {
                    var actual = [];
                    Enumerator.from([])
                        .map(function (x) return x * 10)
                        .map(function (x) return x + 1)
                        .forEach(actual.push);
                    actual.should.containExactly([]);
                });
            });

            describe("non empty source", {
                it("should pass when it is given a mapper", {
                    var actual = [];
                    Enumerator.from([1, 2, 3, 4, 5])
                        .map(function (x) return x * 10)
                        .forEach(actual.push);
                    actual.should.containExactly([10, 20, 30, 40, 50]);
                });

                it("should pass when it is given 2 mappers", {
                    var actual = [];
                    Enumerator.from([1, 2, 3, 4, 5])
                        .map(function (x) return x * 10)
                        .map(function (x) return x + 1)
                        .forEach(actual.push);
                    actual.should.containExactly([11, 21, 31, 41, 51]);
                });
            });
        });

        describe("Enumerator#flatMap()", {
        });

        describe("Enumerator#filter()", {
        });

        describe("Enumerator#skip()", {
        });

        describe("Enumerator#skipWhile()", {
        });

        describe("Enumerator#take()", {
        });

        describe("Enumerator#takeWhile()", {
        });
    }
}