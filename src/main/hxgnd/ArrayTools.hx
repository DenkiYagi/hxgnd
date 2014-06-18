package hxgnd;

class ArrayTools {
    public static inline function iter<A>(array: Array<A>, f: A -> Void): Void {
        for (x in array) f(x);
    }

    public static function groupBy<A>(array: Array<A>, f: A -> String): Dynamic<Array<A>> {
        var result: Dynamic<Array<A>> = { };
        for (x in array) {
            var key = f(x);
            if (Reflect.hasField(result, key)) {
                Reflect.field(result, key).push(x);
            } else {
                Reflect.setField(result, key, [x]);
            }
        }
        return result;
    }
}