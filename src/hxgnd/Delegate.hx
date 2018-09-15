package hxgnd;

using hxgnd.ArrayTools;

abstract Delegate<T>(Array<T -> Void>) to ReadOnlyArray<T -> Void> {
    public inline function new() {
        this = [];
    }

    public inline function add(f: T -> Void): Void {
        if (this.notExists(f)) this.push(f);
    }

    public inline function remove(f: T -> Void): Bool {
        return this.remove(f);
    }

    public inline function removeAll(): Void {
        this = [];
    }

    public inline function invoke(x: T): Void {
        for (f in this) f(x);
    }
}