package hxgnd.internal.enumerator;

class SkipEffect {
    var counter: Int;
    var active: Bool;

    public function new(length: Int) {
        this.counter = length;
        this.active = length > 0;
    }

    public function apply(ctx: EffectContext): Void {
        if (active) {
            active = (--counter <= 0);
            if (active) ctx.control = Continue;
        }
    }
}
