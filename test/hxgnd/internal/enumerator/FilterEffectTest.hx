package hxgnd.internal.enumerator;

import buddy.BuddySuite;
using buddy.Should;
import hxgnd.internal.enumerator.EffectControl;

class FilterEffectTest extends BuddySuite {
    public function new() {
        describe("FilterEffect", {
            function testTrue(effect: FilterEffect) {
                it("should be Pass when it returns true", {
                    var context = new EffectContext();
                    context.acc = 10;
                    context.control = Pass;
                    effect.apply(context);
                    context.acc.should.be(10);
                    context.control.should.be(Pass);
                });
            }

            function testFalse(effect: FilterEffect) {
                it("should be Continue when it returns false", {
                    var context = new EffectContext();
                    context.acc = 10;
                    context.control = Pass;
                    effect.apply(context);
                    context.acc.should.be(10);
                    context.control.should.be(Continue);
                });
            }

            describe("1 filter", {
                testTrue(new FilterEffect([
                    function (x) return true,
                ]));
                testFalse(new FilterEffect([
                    function (x) return false,
                ]));
            });

            describe("2 filters", {
                testTrue(new FilterEffect([
                    function (x) return true,
                    function (x) return true,
                ]));
                testFalse(new FilterEffect([
                    function (x) return true,
                    function (x) return false,
                ]));
            });

            describe("3 filters", {
                testTrue(new FilterEffect([
                    function (x) return true,
                    function (x) return true,
                    function (x) return true,
                ]));
                testFalse(new FilterEffect([
                    function (x) return true,
                    function (x) return true,
                    function (x) return false,
                ]));
            });

            describe("4 filters", {
                testTrue(new FilterEffect([
                    function (x) return true,
                    function (x) return true,
                    function (x) return true,
                    function (x) return true,
                ]));
                testFalse(new FilterEffect([
                    function (x) return true,
                    function (x) return true,
                    function (x) return true,
                    function (x) return false,
                ]));
            });

            describe("5 filters", {
                testTrue(new FilterEffect([
                    function (x) return true,
                    function (x) return true,
                    function (x) return true,
                    function (x) return true,
                    function (x) return true,
                ]));
                testFalse(new FilterEffect([
                    function (x) return true,
                    function (x) return true,
                    function (x) return true,
                    function (x) return true,
                    function (x) return false,
                ]));
            });        });
    }
}