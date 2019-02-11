package hxgnd;

import buddy.BuddySuite;
import extype.Maybe;
using buddy.Should;

class TraverserTest extends BuddySuite {
    public function new() {
        function testEmpty<T>(factory: Void -> Traverser<T>) {
            it("should pass", {
                var traverser = factory();

                // before next()
                traverser.current.isEmpty().should.be(true);

                // over eof
                traverser.next().should.be(false);
                traverser.current.isEmpty().should.be(true);

                traverser.next().should.be(false);
                traverser.current.isEmpty().should.be(true);
            });
        }

        function testOne<T>(factory: Void -> Traverser<T>, v1: T) {
            it("should pass", {
                var traverser = factory();

                // before next()
                traverser.current.isEmpty().should.be(true);

                // 1st
                traverser.next().should.be(true);
                traverser.current.get().should.be(v1);

                // over eof
                traverser.next().should.be(false);
                traverser.current.isEmpty().should.be(true);
            });
        }

        function testMany<T>(factory: Void -> Traverser<T>, v1: T, v2: T) {
            it("should pass", {
                var traverser = factory();

                // before next()
                traverser.current.isEmpty().should.be(true);

                // 1st
                traverser.next().should.be(true);
                traverser.current.get().should.be(v1);

                // 2nd
                traverser.next().should.be(true);
                traverser.current.nonEmpty().should.be(true);
            });
        }

        describe("Traverser/Array", {
            testEmpty(function () return Traverser.from([]));
            testOne(function () return Traverser.from([1]), 1);
            testMany(function () return Traverser.from([1, 2, 3]), 1, 2);
        });

        describe("Traverser/IntIterator", {
            testEmpty(function () return Traverser.from(0...0));
            testOne(function () return Traverser.from(0...1), 0);
            testMany(function () return Traverser.from(0...10), 0, 1);
        });

        describe("Traverser/Iterator", {
            testEmpty(function () return Traverser.from([].iterator()));
            testOne(function () return Traverser.from([1].iterator()), 1);
            testMany(function () return Traverser.from([1, 2, 3].iterator()), 1, 2);
        });

        describe("Traverser/Iterable", {
            testEmpty(function () return Traverser.from(([]: Iterable<Int>)));
            testOne(function () return Traverser.from(([1]: Iterable<Int>)), 1);
            testMany(function () return Traverser.from(([1, 2, 3]: Iterable<Int>)), 1, 2);
        });
    }
}