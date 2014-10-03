package hxgnd;

class ArrayTools {
    public static function array<T>(x: Iterator<T>): Array<T> {
        var array = [];
        while (x.hasNext()) {
            array.push(x.next());
        }
        return array;
    }

    public static function zipWithIndex<A>(array: Array<A>): Array<{index: Int, value: A}> {
        return mapWithIndex(array, function (a, i) {
            return { index: i, value: a };
        });
    }

    public static inline function iter<A>(array: Array<A>, f: A -> Void): Void {
        for (x in array) f(x);
    }

    public static inline function iterWithIndex<A>(array: Array<A>, f: A -> Int -> Void): Void {
        var i = 0;
        for (x in array) f(x, i++);
    }

    public static function filter<A>(array: Array<A>, f: A -> Bool): Array<A> {
        var result = [];
        iter(array, function (a) {
            if (f(a)) result.push(a);
        });
        return result;
    }

    public static function map<A, B>(array: Array<A>, f: A -> B): Array<B> {
        var result = [];
        iter(array, function (a) {
            result.push(f(a));
        });
        return result;
    }

    public static function mapWithIndex<A, B>(array: Array<A>, f: A -> Int -> B): Array<B> {
        var result = [];
        iterWithIndex(array, function (a, i) {
            result.push(f(a, i));
        });
        return result;
    }

    public static function flatMap<A, B>(array: Array<Array<A>>, f: A -> B): Array<B> {
        var result = [];
        iter(array, function (sub) {
            iter(sub, function (a) result.push(f(a)));
        });
        return result;
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

    public static function findOption<A>(array: Array<A>, f: A -> Bool): Option<A> {
        return OptionTools.toOption(Lambda.find(array, f));
    }

    public static function head<A>(array: Array<A>, ?f: A -> Bool): A {
        return OptionTools.getOrThrow(headOption(array, f), new Error("not found"));
    }

    public static function headOption<A>(array: Array<A>, ?f: A -> Bool): Option<A> {
        if (f == null) {
            if (array.length > 0) return Some(array[0]);
        } else {
            for (x in array) {
                if (f(x)) return Some(x);
            }
        }
        return None;
    }

    public static function lastOption<A>(array: Array<A>): Option<A> {
        return if(array.length == 0) None else Some(array[array.length - 1]);
    }

    public static function flatten<A>(array: Array<Array<A>>): Array<A> {
        function concat<A>(a1: Array<A>, a2: Array<A>){ return a2.concat(a1); }
        return Lambda.array(Lambda.fold(array, concat, []));
    }

    public static function span<A>(array: Array<A>, cond: A -> Bool): {first: Array<A>, rest: Array<A>} {
        var i = 0;
        while(i < array.length && !cond(array[i])){
            i ++;
        }
        return {first: array.slice(0, i), rest: array.slice(i, array.length)};
    }
}
