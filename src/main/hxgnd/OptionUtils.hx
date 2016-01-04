package hxgnd;

import hxgnd.Option;

class OptionUtils {
    public static inline function toOption<T>(x: T) : Option<T> {
        return (x == null) ? None: Some(x);
    }

    public static inline function getOrDefault<T>(a: Option<T>, b: T): T {
        return switch (a) {
            case Some(x): x;
            case None: b;
        }
    }

    public static inline function getOrElse<T>(a: Option<T>, b: Void -> T): T {
        return switch (a) {
            case Some(x): x;
            case None: b();
        }
    }

    public static inline function getOrThrow<T>(a: Option<T>, error: Dynamic): T {
        return switch (a) {
            case Some(x): x;
            case None: throw error;
        }
    }

    public static inline function iter<T>(x: Option<T>, f: T -> Void): Void {
        switch (x) {
            case Some(a): f(a);
            case None:
        }
    }

    public static inline function map<A, B>(x: Option<A>, f: A -> B) : Option<B> {
        return switch (x) {
            case Some(a): Some(f(a));
            case None: None;
        }
    }

    public static inline function flatMap<A, B>(x: Option<A>, f: A -> Option<B>) {
        return switch (x) {
            case Some(a): f(a);
            case None: None;
        }
    }

    public static inline function get<A>(x: Option<A>): A {
        return switch (x) {
            case Some(a): a;
            case None: throw "method 'get' was called but receiver was None";
        }
    }

    public static inline function isEmpty<A>(x: Option<A>): Bool {
        return switch (x) {
            case Some(a): false;
            case None: true;
        }
    }
	
    public static inline function nonEmpty<A>(x: Option<A>): Bool {
        return !isEmpty(x);
    }	

    public static inline function filter<A>(x: Option<A>, cond: A -> Bool): Option<A> {
        return switch (x) {
            case Some(a): cond(a) ? Some(a) : None;
            case None: None;
        }
    }

    public static inline function orElse<A>(x: Option<A>, other: Void-> Option<A>): Option<A> {
        return switch (x) {
            case Some(a): x;
            case None: other();
        }
    }

    public static inline function or<A>(x: Option<A>, other: Option<A>): Option<A> {
        return switch (x) {
            case Some(a): x;
            case None: other;
        }
    }

    public static inline function toResult<A>(x: Option<A>, error: Error): Result<A>{
        return switch(x){
            case Some(a): Success(a);
            case None: Failure(error);
        }
    }

    public static inline function toArray<A>(x: Option<A>): Array<A>{
        return switch(x){
            case Some(a): [a];
            case None: [];
        }
    }
	
	public static function all<A>(array: Array<Option<A>>): Option<Array<A>> {
		if (array.length == 0) return None;
		var result = [];
		for (x in array) {
			switch (x) {
				case Some(y): result.push(y);
				case None: return None;
			}
		}
		return Some(result);
	}
}
