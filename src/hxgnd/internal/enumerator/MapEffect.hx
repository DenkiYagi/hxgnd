package hxgnd.internal.enumerator;

import extype.Maybe;

@:forward
abstract MapEffect(Effect) to Effect {
    public function new(fns: Array<Dynamic -> Dynamic>) {
        this = switch (fns.length) {
            case 1: new MapEffect1(fns);
            case 2: new MapEffect2(fns);
            case 3: new MapEffect3(fns);
            case _: new MapEffectMany(fns);
        };
    }
}

private class MapEffect1 {
    var fn1: Dynamic -> Dynamic;

    public function new(fns: Array<Dynamic -> Dynamic>) {
        this.fn1 = fns[0];
    }

    public function apply(ctx: EffectContext): Void {
        ctx.acc = fn1(ctx.acc);
    }
}

private class MapEffect2 {
    var fn1: Dynamic -> Dynamic;
    var fn2: Dynamic -> Dynamic;

    public function new(fns: Array<Dynamic -> Dynamic>) {
        this.fn1 = fns[0];
        this.fn2 = fns[1];
    }

    public function apply(ctx: EffectContext): Void {
        ctx.acc = fn2(fn1(ctx.acc));
    }
}

private class MapEffect3 {
    var fn1: Dynamic -> Dynamic;
    var fn2: Dynamic -> Dynamic;
    var fn3: Dynamic -> Dynamic;

    public function new(fns: Array<Dynamic -> Dynamic>) {
        this.fn1 = fns[0];
        this.fn2 = fns[1];
        this.fn3 = fns[2];
    }

    public function apply(ctx: EffectContext): Void {
        ctx.acc = fn3(fn2(fn1(ctx.acc)));
    }
}

private class MapEffectMany {
    var fn1: Dynamic -> Dynamic;
    var fn2: Dynamic -> Dynamic;
    var fn3: Dynamic -> Dynamic;
    var fn4: Dynamic -> Dynamic;
    var fnRest: Maybe<Array<Dynamic -> Dynamic>>;

    public function new(fns: Array<Dynamic -> Dynamic>) {
        this.fn1 = fns[0];
        this.fn2 = fns[1];
        this.fn3 = fns[2];
        this.fn4 = fns[3];
        this.fnRest = (fns.length > 4) ? Maybe.of(fns.slice(4)) : Maybe.empty();
    }

    public function apply(ctx: EffectContext): Void {
        var acc = fn4(fn3(fn2(fn1(ctx.acc))));
        fnRest.iter(function (fns) for (f in fns) acc = f(acc));
        ctx.acc = acc;
    }
}