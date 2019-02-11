package hxgnd.internal.enumerator;

import extype.Maybe;
import hxgnd.Traverser;
import hxgnd.internal.traverser.ITraverser;

abstract Pipeline<T, U>(Array<EffectType>) from Array<EffectType> to Array<EffectType> {
    public function new() {
        this = [];
    }

    public function filter(fn: U -> Bool): Pipeline<T, U> {
        var effects = this.copy();

        var last = effects.length - 1;
        if (last >= 0) {
            switch (effects[last]) {
                case Filter(fns): effects[last] = Filter(fns.concat([fn]));
                case _: effects.push(Filter([fn]));
            }
        } else {
            effects.push(Filter([fn]));
        }

        return effects;
    }

    public function map<V>(fn: U -> V): Pipeline<T, V> {
        var effects = this.copy();

        var last = effects.length - 1;
        if (last >= 0) {
            switch (effects[last]) {
                case Map(fns): effects[last] = Map(fns.concat([fn]));
                case _: effects.push(Map([fn]));
            }
        } else {
            effects.push(Map([fn]));
        }

        return effects;
    }

    public function skip(length: Int): Pipeline<T, U> {
        var effects = this.copy();
        effects.push(Skip(length));
        return effects;
    }

    public function skipWhile(fn: U -> Bool): Pipeline<T, U> {
        var effects = this.copy();
        effects.push(SkipWhile(fn));
        return effects;
    }

    public function take(length: Int): Pipeline<T, U> {
        var effects = this.copy();
        effects.push(Take(length));
        return effects;
    }

    public function takeWhile(fn: U -> Bool): Pipeline<T, U> {
        var effects = this.copy();
        effects.push(TakeWhile(fn));
        return effects;
    }

    // public inline function applyToArray(source: Array<T>, callback: U -> Void): Void {
    //     var effects = buildEffects();
    //     switch (effects.length) {
    //         case 0:
    //             for (x in source) callback(cast x);
    //         case 1:
    //             var ctx = new EffectContext();
    //             var effect0 = effects[0];
    //             for (x in source) {
    //                 ctx.acc = x;
    //                 ctx.control = Pass;

    //                 effect0.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 callback(ctx.acc);
    //             }
    //         case 2:
    //             var ctx = new EffectContext();
    //             var effect0 = effects[0];
    //             var effect1 = effects[1];
    //             for (x in source) {
    //                 ctx.acc = x;
    //                 ctx.control = Pass;

    //                 effect0.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect1.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 callback(ctx.acc);
    //             }
    //         case 3:
    //             var ctx = new EffectContext();
    //             var effect0 = effects[0];
    //             var effect1 = effects[1];
    //             var effect2 = effects[2];
    //             for (x in source) {
    //                 ctx.acc = x;
    //                 ctx.control = Pass;

    //                 effect0.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect1.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect2.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 callback(ctx.acc);
    //             }
    //         case _:
    //             var ctx = new EffectContext();
    //             var effect0 = effects[0];
    //             var effect1 = effects[1];
    //             var effect2 = effects[2];
    //             var effect3 = effects[3];
    //             var effectRest = (effects.length >= 4) ? Maybe.ofNullable(effects.slice(4)) : Maybe.empty();
    //             for (x in source) {
    //                 ctx.acc = x;
    //                 ctx.control = Pass;

    //                 effect0.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect1.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect2.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect3.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 if (effectRest.nonEmpty()) {
    //                     for (e in effectRest.get()) {
    //                         e.apply(ctx);
    //                         if (ctx.control.nonPass()) break;
    //                     }
    //                     if (ctx.control.isContinue()) continue;
    //                     if (ctx.control.isBreak()) break;
    //                 }

    //                 callback(ctx.acc);
    //             }
    //     }
    // }

    public function createTraverser(source: Traverser<T>): Traverser<U> {
        var effects = buildEffects();
        return switch (effects.length) {
            case 0: cast source;
            case 1: new EffectedTraverser1(source, effects);
            case 2: new EffectedTraverser2(source, effects);
            case 3: new EffectedTraverser3(source, effects);
            case _: new EffectedTraverserMany(source, effects);
        }
    }

    // public inline function applyToTraverser(source: Traverser<T>, callback: U -> Void): Void {
    //     var effects = buildEffects();
    //     switch (effects.length) {
    //         case 0:
    //             while (source.next()) callback(cast source.current);
    //         case 1:
    //             var ctx = new EffectContext();
    //             var effect0 = effects[0];
    //             while (source.next()) {
    //                 ctx.acc = source.current;
    //                 ctx.control = Pass;

    //                 effect0.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 callback(ctx.acc);
    //             }
    //         case 2:
    //             var ctx = new EffectContext();
    //             var effect0 = effects[0];
    //             var effect1 = effects[1];
    //             while (source.next()) {
    //                 ctx.acc = source.current;
    //                 ctx.control = Pass;

    //                 effect0.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect1.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 callback(ctx.acc);
    //             }
    //         case 3:
    //             var ctx = new EffectContext();
    //             var effect0 = effects[0];
    //             var effect1 = effects[1];
    //             var effect2 = effects[2];
    //             while (source.next()) {
    //                 ctx.acc = source.current;
    //                 ctx.control = Pass;

    //                 effect0.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect1.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect2.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 callback(ctx.acc);
    //             }
    //         case _:
    //             var ctx = new EffectContext();
    //             var effect0 = effects[0];
    //             var effect1 = effects[1];
    //             var effect2 = effects[2];
    //             var effect3 = effects[3];
    //             var effectRest = (effects.length >= 4) ? Maybe.ofNullable(effects.slice(4)) : Maybe.empty();
    //             while (source.next()) {
    //                 ctx.acc = source.current;
    //                 ctx.control = Pass;

    //                 effect0.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect1.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect2.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 effect3.apply(ctx);
    //                 if (ctx.control.isContinue()) continue;
    //                 if (ctx.control.isBreak()) break;

    //                 if (effectRest.nonEmpty()) {
    //                     for (e in effectRest.get()) {
    //                         e.apply(ctx);
    //                         if (ctx.control.nonPass()) break;
    //                     }
    //                     if (ctx.control.isContinue()) continue;
    //                     if (ctx.control.isBreak()) break;
    //                 }

    //                 callback(ctx.acc);
    //             }
    //     }
    // }

    function buildEffects(): Array<Effect> {
        return [
            for (e in this) {
                switch (e) {
                    case Map(fns): new MapEffect(fns);
                    case Filter(fns): new FilterEffect(fns);
                    case Skip(length): new SkipEffect(length);
                    case SkipWhile(fn): new SkipWhileEffect(fn);
                    case Take(length): new TakeEffect(length);
                    case TakeWhile(fn): new TakeWhileEffect(fn);
                }
            }
        ];
    }
}

private enum EffectType {
    Map(fns: Array<Dynamic -> Dynamic>);
    Filter(fns: Array<Dynamic -> Bool>);
    Skip(length: Int);
    SkipWhile(fn: Dynamic -> Bool);
    Take(length: Int);
    TakeWhile(fn: Dynamic -> Bool);
}

private class EffectedTraverser1<T, U> implements ITraverser<U> {
    var source: Traverser<T>;
    var context: EffectContext;
    var effect0: Effect;
    public var current(default, null): Maybe<U>;

    public function new(source: Traverser<T>, effects: Array<Effect>) {
        this.source = source;
        this.context = new EffectContext();
        this.effect0 = effects[0];
    }

    public function next(): Bool {
        if (context.control.isBreak()) return false;

        while (source.next()) {
            context.acc = source.current;
            context.control = Pass;

            effect0.apply(context);
            if (context.control.isContinue()) continue;
            if (context.control.isBreak()) break;

            current = context.acc;
            return true;
        }

        return false;
    }
}

private class EffectedTraverser2<T, U> implements ITraverser<U> {
    var source: Traverser<T>;
    var context: EffectContext;
    var effect0: Effect;
    var effect1: Effect;
    public var current(default, null): Maybe<U>;

    public function new(source: Traverser<T>, effects: Array<Effect>) {
        this.source = source;
        this.context = new EffectContext();
        this.effect0 = effects[0];
        this.effect1 = effects[1];
    }

    public function next(): Bool {
        if (context.control.isBreak()) return false;

        while (source.next()) {
            context.acc = source.current;
            context.control = Pass;

            effect0.apply(context);
            if (context.control.isContinue()) continue;
            if (context.control.isBreak()) break;

            effect1.apply(context);
            if (context.control.isContinue()) continue;
            if (context.control.isBreak()) break;

            current = context.acc;
            return true;
        }

        return false;
    }
}

private class EffectedTraverser3<T, U> implements ITraverser<U> {
    var source: Traverser<T>;
    var context: EffectContext;
    var effect0: Effect;
    var effect1: Effect;
    var effect2: Effect;
    public var current(default, null): Maybe<U>;

    public function new(source: Traverser<T>, effects: Array<Effect>) {
        this.source = source;
        this.context = new EffectContext();
        this.effect0 = effects[0];
        this.effect1 = effects[1];
        this.effect2 = effects[2];
    }

    public function next(): Bool {
        if (context.control.isBreak()) return false;

        while (source.next()) {
            context.acc = source.current;
            context.control = Pass;

            effect0.apply(context);
            if (context.control.isContinue()) continue;
            if (context.control.isBreak()) break;

            effect1.apply(context);
            if (context.control.isContinue()) continue;
            if (context.control.isBreak()) break;

            effect2.apply(context);
            if (context.control.isContinue()) continue;
            if (context.control.isBreak()) break;

            current = context.acc;
            return true;
        }

        return false;
    }
}

private class EffectedTraverserMany<T, U> implements ITraverser<U> {
    var source: Traverser<T>;
    var context: EffectContext;
    var effect0: Effect;
    var effect1: Effect;
    var effect2: Effect;
    var effect3: Effect;
    var effectRest: Maybe<Array<Effect>>;
    public var current(default, null): Maybe<U>;

    public function new(source: Traverser<T>, effects: Array<Effect>) {
        this.source = source;
        this.context = new EffectContext();
        this.effect0 = effects[0];
        this.effect1 = effects[1];
        this.effect2 = effects[2];
        this.effect3 = effects[3];
        this.effectRest = (effects.length >= 4) ? Maybe.ofNullable(effects.slice(4)) : Maybe.empty();
    }

    public function next(): Bool {
        if (context.control.isBreak()) return false;

        while (source.next()) {
            context.acc = source.current;
            context.control = Pass;

            effect0.apply(context);
            if (context.control.isContinue()) continue;
            if (context.control.isBreak()) break;

            effect1.apply(context);
            if (context.control.isContinue()) continue;
            if (context.control.isBreak()) break;

            effect2.apply(context);
            if (context.control.isContinue()) continue;
            if (context.control.isBreak()) break;

            effect3.apply(context);
            if (context.control.isContinue()) continue;
            if (context.control.isBreak()) break;

            if (effectRest.nonEmpty()) {
                for (e in effectRest.get()) {
                    e.apply(context);
                    if (context.control.nonPass()) break;
                }
                if (context.control.isContinue()) continue;
                if (context.control.isBreak()) break;
            }

            current = context.acc;
            return true;
        }

        return false;
    }
}