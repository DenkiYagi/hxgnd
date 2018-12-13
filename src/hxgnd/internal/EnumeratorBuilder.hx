package hxgnd.internal;

import haxe.macro.Context;
import haxe.macro.Expr;

class EnumeratorBuilder {
    public static function build(): Array<Field> {
        var fields = Context.getBuildFields();

        trace(Context.getLocalClass().get());

        return fields;
    }
}
