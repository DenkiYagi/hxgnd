package hxgnd.internal.enumerator;

class TakeWhileEffect {
    var fn: Dynamic -> Bool;

    public function new(fn: Dynamic -> Bool) {
        this.fn = fn;
    }

    public function apply(ctx: EffectContext): Void {
        if (!fn(ctx.acc)) ctx.control = Break;
    }
}