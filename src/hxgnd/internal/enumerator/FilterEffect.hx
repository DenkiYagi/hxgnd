package hxgnd.internal.enumerator;

import extype.Maybe;

abstract FilterEffect(Void) {
    public static function factory(fns: Array<Dynamic -> Bool>): Effect {
        return switch (fns.length) {
            case 1: new FilterEffect1(fns);
            case 2: new FilterEffect2(fns);
            case 3: new FilterEffect3(fns);
            case _: new FilterEffectMany(fns);
        }
    }
}

private class FilterEffect1 {
    var fn1: Dynamic -> Bool;

    public function new(fns: Array<Dynamic -> Bool>) {
        this.fn1 = fns[0];
    }

    public function apply(ctx: EffectContext): Void {
        if (!fn1(ctx.acc)) ctx.control = Continue;
    }
}

private class FilterEffect2 {
    var fn1: Dynamic -> Bool;
    var fn2: Dynamic -> Bool;

    public function new(fns: Array<Dynamic -> Bool>) {
        this.fn1 = fns[0];
        this.fn2 = fns[1];
    }

    public function apply(ctx: EffectContext): Void {
        var acc = ctx.acc;
        if (!fn1(acc) || !fn2(acc)) ctx.control = Continue;
    }
}

private class FilterEffect3 {
    var fn1: Dynamic -> Bool;
    var fn2: Dynamic -> Bool;
    var fn3: Dynamic -> Bool;

    public function new(fns: Array<Dynamic -> Bool>) {
        this.fn1 = fns[0];
        this.fn2 = fns[1];
        this.fn3 = fns[2];
    }

    public function apply(ctx: EffectContext): Void {
        var acc = ctx.acc;
        if (!fn1(acc) || !fn2(acc) || !fn3(acc)) ctx.control = Continue;
    }
}

private class FilterEffectMany {
    var fn1: Dynamic -> Bool;
    var fn2: Dynamic -> Bool;
    var fn3: Dynamic -> Bool;
    var fn4: Dynamic -> Bool;
    var fnRest: Maybe<Array<Dynamic -> Bool>>;

    public function new(fns: Array<Dynamic -> Bool>) {
        this.fn1 = fns[0];
        this.fn2 = fns[1];
        this.fn3 = fns[2];
        this.fn4 = fns[3];
        this.fnRest = (fns.length > 4) ? Maybe.ofNullable(fns.slice(4)) : Maybe.empty();
    }

    public function apply(ctx: EffectContext): Void {
        var acc = ctx.acc;
        if (fn1(acc) && fn2(acc) && fn3(acc) && fn4(acc)) {
            if (fnRest.nonEmpty()) {
                for (f in fnRest.get()) {
                    if (!f(acc)) {
                        ctx.control = Continue;
                        return;
                    }
                }
            }
        } else {
            ctx.control = Continue;
        }
    }
}