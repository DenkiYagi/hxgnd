package hxgnd;

class ArrayTools {
    public static function toArray<T>(iter: IteratorOrIterable<T>): Array<T> {
        var it: Iterator<T> = iter;
        var array = [];
        while (it.hasNext()) array.push(it.next());
        return array;
    }

    public static inline function forEach<T>(array: Array<T>, fn: T -> Void): Void {
        #if js
        untyped array.forEach(fn);
        #else
        for (x in array) fn(x);
        #end
    }

    public static inline function forEachWithIndex<T>(array: Array<T>, fn: T -> Int -> Void): Void {
        #if js
        untyped array.forEach(fn);
        #else
        for (i in 0...array.length) fn(array[i], i);
        #end
    }

    public static inline function mapWithIndex<T, U>(array: Array<T>, fn: T -> Int -> U): Array<U> {
        #if js
        return untyped __js__("{0}.map({1})", array, fn);
        #else
        return [for (i in 0...array.length) fn(array[i], i)];
        #end
    }

    public static function zip<A, B>(a: Array<A>, b: Array<B>): Array<{value1: A, value2: B}> {
        if (a.length != b.length) throw new Error("invalid argument");
        
        var array = [];
        for (i in 0...a.length) {
            array.push({value1: a[i], value2: b[i]});
        }
        return array;
    }

    public static function zipStringMap<A, B>(a: Array<A>, b: Array<B>): Map<String, B> {
        if (a.length != b.length) throw new Error("invalid argument");
        
        var map = new haxe.ds.StringMap<B>();
        for (i in 0...a.length) {
            map.set(Std.string(a[i]), b[i]);
        }
        return map;
    }

    // public static function zipWithIndex<A>(array: Array<A>): Array<{index: Int, value: A}> {
    //     return mapi(array, function (a, i) {
    //         return { index: i, value: a };
    //     });
    // }

    // public static function flatMap<A, B>(array: Array<A>, f: A -> Array<B>): Array<B> {
    //     var result = [];
	// 	for (x in array) {
	// 	 	result = result.concat(f(x));
	// 	}
    //     return result;
    // }

    // public static function flatMapi<A, B>(array: Array<A>, f: A -> Int -> Array<B>): Array<B> {
    //     var result = [];
	// 	var i = 0;
	// 	for (x in array) {
	// 	 	result = result.concat(f(x, i++));
	// 	}
    //     return result;
    // }

    // public static function groupBy<A>(array: Array<A>, f: A -> String): Map<String, Array<A>> {
    //     var result = new Map<String, Array<A>>();
    //     for (x in array) {
    //         var key = f(x);
    //         if (result.exists(key)) {
    //             result.get(key).push(x);
    //         } else {
    //             result.set(key, [x]);
    //         }
    //     }
    //     return result;
    // }

    // public static function findOption<A>(array: Array<A>, f: A -> Bool): Option<A> {
    //     return OptionUtils.toOption(Lambda.find(array, f));
    // }

    public static function head<A>(array: Array<A>, ?fn: A -> Bool): Maybe<A> {
        if (fn == null) {
            if (array.length > 0) return Maybe.of(array[0]);
        } else {
            for (x in array) {
                if (fn(x)) return Maybe.of(x);
            }
        }
        return Maybe.empty();
    }

    // public static function lastOption<A>(array: Array<A>): Option<A> {
    //     return if(array.length == 0) None else Some(array[array.length - 1]);
    // }

    // public static function flatten<A>(array: Array<Array<A>>): Array<A> {
    //     function concat<A>(a1: Array<A>, a2: Array<A>){ return a2.concat(a1); }
    //     return Lambda.array(Lambda.fold(array, concat, []));
    // }

    // public static function span<A>(array: Array<A>, cond: A -> Bool): {first: Array<A>, rest: Array<A>} {
    //     var i = 0;
    //     while(i < array.length && !cond(array[i])){
    //         i ++;
    //     }
    //     return {first: array.slice(0, i), rest: array.slice(i, array.length)};
    // }

	// public static function foldLeft<A, B>(array: Array<A>, init: B, f: B -> A -> B): B {
	// 	return if (array.length == 0) {
	// 		init;
	// 	} else {
	// 		var acc = init;
	// 		for (x in array) {
	// 			acc = f(acc, x);
	// 		}
	// 		acc;
	// 	}
	// }

	// public static function foldRight<A, B>(array: Array<A>, init: B, f: A -> B -> B): B {
	// 	return if (array.length == 0) {
	// 		init;
	// 	} else {
	// 		var acc = init;
	// 		var i = array.length;
    //         while (i > 0) {
	// 			acc = f(array[--i], acc);
    //         }
	// 		acc;
	// 	}
	// }

	// public static function exists<A>(array: Array<A>, f: A -> Bool): Bool {
	// 	if (array != null && array.length >= 0) {
	// 		for (x in array) if (f(x)) return true;
	// 	}
	// 	return false;
	// }

	// public static function count<A>(array: Array<A>, f: A -> Bool): Int {
	// 	var count = 0;
	// 	for (x in array) {
	// 		if (f(x)) ++count;
	// 	}
	// 	return count;
	// }

    // public static function distinct<A>(array: Array<A>, f: A -> String) {
    //     var map = new haxe.ds.StringMap<Any>();
    //     var result = [];
    //     for (x in array) {
    //         var k = f(x);
    //         if (!map.exists(k)) {
    //            map.set(k, null);
    //             result.push(x);
    //         }
    //     }
    //     return result;
    // }
}

abstract IteratorOrIterable<T>(Iterator<T>) from Iterator<T> to Iterator<T> {
	private inline function new(x: Iterator<T>) {
		this = x;
	}
	
	@:from
	public static inline function fromIterable<T>(x: Iterable<T>) {
		return new IteratorOrIterable(x.iterator());
	}
}