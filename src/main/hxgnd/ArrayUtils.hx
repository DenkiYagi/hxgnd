package hxgnd;

abstract Iter<T>(Iterator<T>) from Iterator<T> to Iterator<T> {
	inline function new(x: Iterator<T>) {
		this = x;
	}
	
	@:from
	public static inline function fromIterable<T>(x: Iterable<T>) {
		return new Iter(x.iterator());
	}
}

class ArrayUtils {
    public static function array<T>(iter: Iter<T>): Array<T> {
		var it: Iterator<T> = iter;
        var array = [];
		while (it.hasNext()) array.push(it.next());
        return array;
    }

    public static function zipWithIndex<A>(array: Array<A>): Array<{index: Int, value: A}> {
        return mapi(array, function (a, i) {
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

    public static function mapi<A, B>(array: Array<A>, f: A -> Int -> B): Array<B> {
        var result = [];
        iterWithIndex(array, function (a, i) {
            result.push(f(a, i));
        });
        return result;
    }

    public static function flatMap<A, B>(array: Array<A>, f: A -> Array<B>): Array<B> {
        var result = [];
		for (x in array) {
		 	result = result.concat(f(x));
		}
        return result;
    }

    public static function flatMapi<A, B>(array: Array<A>, f: A -> Int -> Array<B>): Array<B> {
        var result = [];
		var i = 0;
		for (x in array) {
		 	result = result.concat(f(x, i++));
		}
        return result;
    }

    public static function groupBy<A>(array: Array<A>, f: A -> String): Map<String, Array<A>> {
        var result = new Map<String, Array<A>>();
        for (x in array) {
            var key = f(x);
            if (result.exists(key)) {
                result.get(key).push(x);
            } else {
                result.set(key, [x]);
            }
        }
        return result;
    }

    public static function findOption<A>(array: Array<A>, f: A -> Bool): Option<A> {
        return OptionUtils.toOption(Lambda.find(array, f));
    }

    public static function head<A>(array: Array<A>, ?f: A -> Bool): A {
        return OptionUtils.getOrThrow(headOption(array, f), new Error("not found"));
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

	public static function foldLeft<A, B>(array: Array<A>, init: B, f: B -> A -> B): B {
		return if (array.length == 0) {
			init;
		} else {
			var acc = init;
			for (x in array) {
				acc = f(acc, x);
			}
			acc;
		}
	}

	public static function foldRight<A, B>(array: Array<A>, init: B, f: A -> B -> B): B {
		return if (array.length == 0) {
			init;
		} else {
			var acc = init;
			var i = array.length;
            while (i > 0) {
				acc = f(array[--i], acc);
            }
			acc;
		}
	}

	public static function exists<A>(array: Array<A>, f: A -> Bool): Bool {
		if (array != null && array.length >= 0) {
			for (x in array) if (f(x)) return true;
		}
		return false;
	}

	public static function count<A>(array: Array<A>, f: A -> Bool): Int {
		var count = 0;
		for (x in array) {
			if (f(x)) ++count;
		}
		return count;
	}
}
