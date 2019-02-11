package hxgnd;

import buddy.BuddySuite;
import hxgnd.Enumerator;
using buddy.Should;

class EnumeratorTest extends BuddySuite {
    public function new() {
        describe("Enumerator#traverser()", {
            it("should pass when it is given empty source", {
                var actual = [];
                var traverser = Enumerator.from([]).traverser();
                traverser.forEach(actual.push);
                actual.should.containExactly([]);
            });

            it("should pass when it is given non empty source", {
                var actual = [];
                var traverser = Enumerator.from([1, 2, 3, 4, 5]);
                traverser.forEach(actual.push);
                actual.should.containExactly([1, 2, 3, 4, 5]);
            });
        });

        describe("Enumerator#forEach()", {
            it("should pass when it is given empty source", {
                var actual = [];
                Enumerator.from([]).forEach(actual.push);
                actual.should.containExactly([]);
            });

            it("should pass when it is given non empty source", {
                var actual = [];
                Enumerator.from([1, 2, 3, 4, 5]).forEach(actual.push);
                actual.should.containExactly([1, 2, 3, 4, 5]);
            });
        });

        describe("Enumerator#map()", {
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
    }
}