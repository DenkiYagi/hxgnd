package hxgnd.internal.enumerator;

import buddy.BuddySuite;
using buddy.Should;
import hxgnd.internal.enumerator.EffectControl;

class TakeWhileEffectTest extends BuddySuite {
    public function new() {
        describe("TakeWhileEffect", {
            it("should pass when it is given (x -> false)", {
                var effect = new TakeWhileEffect(function (x) return false);

                var context = new EffectContext();
                context.acc = 10;

                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(10);
                context.control.should.be(Break);

                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(10);
                context.control.should.be(Break);
            });

            it("should pass when it is given (x -> true)", {
                var effect = new TakeWhileEffect(function (x) return true);

                var context = new EffectContext();
                context.acc = 10;

                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(10);
                context.control.should.be(Pass);

                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(10);
                context.control.should.be(Pass);
            });

            it("should pass when it is given (x -> x > 0)", {
                var effect = new TakeWhileEffect(function (x) return x > 0);

                var context = new EffectContext();

                context.acc = 10;
                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(10);
                context.control.should.be(Pass);

                context.acc = 1;
                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(1);
                context.control.should.be(Pass);

                context.acc = 0;
                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(0);
                context.control.should.be(Break);

                context.acc = 10;
                context.control = Pass;
                effect.apply(context);
                context.acc.should.be(10);
                context.control.should.be(Break);
            });
        });
    }
}