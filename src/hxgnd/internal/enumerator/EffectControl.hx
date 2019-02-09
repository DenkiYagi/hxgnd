package hxgnd.internal.enumerator;

using hxgnd.LangTools;

@:enum abstract EffectControl(Int) to Int {
    var Pass = 0;
    var Continue = 1;
    var Break = 2;

    @:extern public inline function isPass(): Bool {
        return this.eq(Pass);
    }

    @:extern public inline function nonPass(): Bool {
        return this.neq(Pass);
    }

    @:extern public inline function isContinue(): Bool {
        return this.eq(Continue);
    }

    @:extern public inline function isBreak(): Bool {
        return this.eq(Break);
    }
}