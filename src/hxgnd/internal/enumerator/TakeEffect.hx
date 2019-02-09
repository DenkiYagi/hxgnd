package hxgnd.internal.enumerator;

class TakeEffect {
    var counter: Int;

    public function new(length: Int) {
        this.counter = length;
    }

    public function apply(ctx: EffectContext): Void {
        if (--counter < 0) ctx.control = Break;
    }
}
