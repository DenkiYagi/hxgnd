package hxgnd.internal.enumerator;

import buddy.BuddySuite;
using buddy.Should;
import hxgnd.internal.enumerator.EffectControl;

class TakeEffectTest extends BuddySuite {
    public function new() {
        describe("TakeEffectTest", {
            describe("negative number", {
                it("should pass", {
                    var effect = new TakeEffect(-1);

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
            });

            describe("zero", {
                it("should pass", {
                    var effect = new TakeEffect(0);

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
            });

            describe("positive number", {
                it("should pass", {
                    var effect = new TakeEffect(1);

                    var context = new EffectContext();
                    context.acc = 10;

                    context.control = Pass;
                    effect.apply(context);
                    context.acc.should.be(10);
                    context.control.should.be(Pass);

                    context.control = Pass;
                    effect.apply(context);
                    context.acc.should.be(10);
                    context.control.should.be(Break);

                    context.control = Pass;
                    effect.apply(context);
                    context.acc.should.be(10);
                    context.control.should.be(Break);
                });
            });
        });
    }
}