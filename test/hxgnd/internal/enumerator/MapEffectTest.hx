package hxgnd.internal.enumerator;

import buddy.BuddySuite;
using buddy.Should;
import hxgnd.internal.enumerator.EffectControl;

class MapEffectTest extends BuddySuite {
    public function new() {
        describe("MapEffect", {
            it("should pass when it is given a function", {
                var effect = new MapEffect([
                    function (x) return x + 1,
                ]);

                var context = new EffectContext();
                context.acc = 10;
                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(11);
                context.control.should.be(Pass);
            });

            it("should pass when it is given 2 functions", {
                var effect = new MapEffect([
                    function (x) return x + 1,
                    function (x) return x + 2,
                ]);

                var context = new EffectContext();
                context.acc = 10;
                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(13);
                context.control.should.be(Pass);
            });

            it("should pass when it is given 3 functions", {
                var effect = new MapEffect([
                    function (x) return x + 1,
                    function (x) return x + 2,
                    function (x) return x + 3,
                ]);

                var context = new EffectContext();
                context.acc = 10;
                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(16);
                context.control.should.be(Pass);
            });

            it("should pass when it is given 4 functions", {
                var effect = new MapEffect([
                    function (x) return x + 1,
                    function (x) return x + 2,
                    function (x) return x + 3,
                    function (x) return x + 4,
                ]);

                var context = new EffectContext();
                context.acc = 10;
                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(20);
                context.control.should.be(Pass);
            });

            it("should pass when it is given 5 functions", {
                var effect = new MapEffect([
                    function (x) return x + 1,
                    function (x) return x + 2,
                    function (x) return x + 3,
                    function (x) return x + 4,
                    function (x) return x + 5,
                ]);

                var context = new EffectContext();
                context.acc = 10;
                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(25);
                context.control.should.be(Pass);
            });
        });
    }
}