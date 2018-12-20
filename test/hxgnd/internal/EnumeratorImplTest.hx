package hxgnd.internal;

import buddy.BuddySuite;
import hxgnd.Enumerator;
import hxgnd.internal.EnumeratorImpl;
using buddy.Should;

class EnumeratorImplTest extends BuddySuite {
    public function new() {
        function test(factory: EnumeratorSource<Int> -> Enumerable<Int>) {
            describe("forEach()", {
                it("should pass when it is given empty source", {
                    var actual = [];
                    factory([]).forEach(function (x) {
                        actual.push(x);
                    });
                    actual.should.containExactly([]);
                });

                it("should pass when it is given unempty source", {
                    var actual = [];
                    factory(0...5).forEach(function (x) {
                        actual.push(x);
                    });
                    actual.should.containExactly([0, 1, 2, 3, 4]);
                });
            });
        }

        describe("GenericEnumerator", {
            test(function (src) return new GenericEnumerator(src));
        });
    }
}