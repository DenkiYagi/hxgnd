package hxgnd;

import buddy.BuddySuite;
import extype.Maybe;
using buddy.Should;

class TraverserTest extends BuddySuite {
    public function new() {
        function testEmpty<T>(factory: Void -> Traverser<T>) {
            it("should be empty when it has not next()", {
                var traverser = factory();
                traverser.current.isEmpty().should.be(true);
            });
        }

        describe("Traverser/Array", {
            testEmpty(function () {
                return Traverser.from([]);
            });
        });

        describe("Traverser/IntIterator", {
            testEmpty(function () {
                return Traverser.from(0...0);
            });
        });

        describe("Traverser/Iterator", {

        });

        describe("Traverser/Iterable", {

        });
    }
}