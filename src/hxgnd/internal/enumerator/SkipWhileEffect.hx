package hxgnd.internal.enumerator;

class SkipWhileEffect {
    var fn: Dynamic -> Bool;
    var active: Bool;

    public function new(fn: Dynamic -> Bool) {
        this.fn = fn;
    }

    public function apply(ctx: EffectContext): Void {
        if (active) {
            active = fn(ctx.acc);
            if (active) ctx.control = Continue;
        }
    }
}
