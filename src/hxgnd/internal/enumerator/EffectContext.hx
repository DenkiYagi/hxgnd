package hxgnd.internal.enumerator;

class EffectContext {
    public var acc: Dynamic;
    public var control: EffectControl;

    public function new() {
        this.acc = null;
        this.control = Pass;
    }
}