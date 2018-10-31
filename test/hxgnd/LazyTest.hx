package hxgnd;

import buddy.BuddySuite;
using buddy.Should;

class LazyTest extends BuddySuite {
    public function new() {
        describe("Lazy#new", {
            it("should not call factory", {
                var called = 0;
                new Lazy(function () {
                    called++;
                    return "value";
                });
                called.should.be(0);
            });
        });

        describe("Lazy#get", {
            it("should return value", {
                var lazy = new Lazy(function () {
                    return "value";
                });

                lazy.get().should.be("value");
            });

            it("should call factory", {
                var called = 0;
                var lazy = new Lazy(function () {
                    called++;
                    return "value";
                });
                called.should.be(0);

                lazy.get().should.be("value");
                called.should.be(1);
            });

            it("should call factory once", {
                var called = 0;
                var lazy = new Lazy(function () {
                    called++;
                    return "value";
                });
                called.should.be(0);

                lazy.get().should.be("value");
                lazy.get().should.be("value");
                lazy.get().should.be("value");
                called.should.be(1);
            });
        });
    }
}