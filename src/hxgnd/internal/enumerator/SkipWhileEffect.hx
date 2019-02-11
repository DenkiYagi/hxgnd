package hxgnd.internal.enumerator;

using hxgnd.LangTools;

class SkipWhileEffect {
    var fn: Dynamic -> Bool;
    var active: Bool;

    public function new(fn: Dynamic -> Bool) {
        this.fn = fn;
        this.active = true;
    }

    public function apply(ctx: EffectContext): Void {
        if (active) {
            if (fn(ctx.acc).eq(true)) {
                ctx.control = Continue;
            } else {
                active = false;
            }
        }
    }
}
