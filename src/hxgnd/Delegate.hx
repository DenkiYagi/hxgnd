package hxgnd;

using hxgnd.ArrayTools;

abstract Delegate<T>(Array<T -> Void>) to ReadOnlyArray<T -> Void> {
    public inline function new(?array: Array<T -> Void>) {
        this = (array == null) ? [] : array.copy();
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

    public inline function isEmpty(): Bool {
        return this.isEmpty();
    }

    public inline function nonEmpty(): Bool {
        return this.nonEmpty();
    }

    public inline function invoke(x: T): Void {
        for (f in this.copy()) f(x);
    }

    public inline function copy(): Delegate<T> {
        return new Delegate(this);
    }
}

abstract Delegate0(Array<Void -> Void>) to ReadOnlyArray<Void -> Void> {
    public inline function new(?array: Array<Void -> Void>) {
        this = (array == null) ? [] : array.copy();
    }

    public inline function add(f: Void -> Void): Void {
        if (this.notExists(f)) this.push(f);
    }

    public inline function remove(f: Void -> Void): Bool {
        return this.remove(f);
    }

    public inline function removeAll(): Void {
        this = [];
    }

    public inline function isEmpty(): Bool {
        return this.isEmpty();
    }

    public inline function nonEmpty(): Bool {
        return this.nonEmpty();
    }

    public inline function invoke(): Void {
        for (f in this.copy()) f();
    }

    public inline function copy(): Delegate0 {
        return new Delegate0(this);
    }
}