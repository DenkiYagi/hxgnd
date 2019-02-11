package hxgnd.internal.enumerator;

import buddy.BuddySuite;
using buddy.Should;
import hxgnd.internal.enumerator.EffectControl;

class SkipEffectTest extends BuddySuite {
    public function new() {
        describe("SkipEffect", {
            describe("negative number", {
                it("should pass", {
                    var effect = new SkipEffect(-1);

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
            });

            describe("zero", {
                it("should pass", {
                    var effect = new SkipEffect(0);

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
            });

            describe("positive number", {
                it("should pass", {
                    var effect = new SkipEffect(1);

                    var context = new EffectContext();
                    context.acc = 10;

                    context.control = Pass;
                    effect.apply(context);
                    context.acc.should.be(10);
                    context.control.should.be(Continue);

                    context.control = Pass;
                    effect.apply(context);
                    context.acc.should.be(10);
                    context.control.should.be(Pass);

                    context.control = Pass;
                    effect.apply(context);
                    context.acc.should.be(10);
                    context.control.should.be(Pass);
                });
            });
        });
    }
}