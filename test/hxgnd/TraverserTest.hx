package hxgnd;

import buddy.BuddySuite;
using buddy.Should;

class TraverserTest extends BuddySuite {
    public function new() {
        function test<T>(factory: Void -> Traverser<T>, expect: Array<T>) {
            describe("core", {
                it("should pass", {
                    var traverser = factory();

                    // before next()
                    traverser.current.isEmpty().should.be(true);

                    // loop
                    var actual = [];
                    while (traverser.next()) {
                        actual.push(traverser.current.get());
                    }
                    actual.should.containExactly(expect);

                    // over eof
                    traverser.next().should.be(false);
                    traverser.current.isEmpty().should.be(true);
                    traverser.next().should.be(false);
                    traverser.current.isEmpty().should.be(true);
                });
            });

            describe("forEach()", {
                it("should pass", {
                    var traverser = factory();

                    var actual = [];
                    traverser.forEach(function (x) actual.push(x));
                    actual.should.containExactly(expect);
                });
            });
        }

        describe("Traverser/Array", {
            test(function () return Traverser.from([]), []);
            test(function () return Traverser.from([1]), [1]);
            test(function () return Traverser.from([1, 2, 3]), [1, 2, 3]);
        });

        describe("Traverser/IntIterator", {
            test(function () return Traverser.from(0...0), []);
            test(function () return Traverser.from(0...1), [0]);
            test(function () return Traverser.from(0...5), [0, 1, 2, 3, 4]);
        });

        describe("Traverser/Iterator", {
            test(function () return Traverser.from([].iterator()), []);
            test(function () return Traverser.from([1].iterator()), [1]);
            test(function () return Traverser.from([1, 2, 3].iterator()), [1, 2, 3]);
        });

        describe("Traverser/Iterable", {
            test(function () return Traverser.from(([]: Iterable<Int>)), []);
            test(function () return Traverser.from(([1]: Iterable<Int>)), [1]);
            test(function () return Traverser.from(([1, 2, 3]: Iterable<Int>)), [1, 2, 3]);
        });
    }
}