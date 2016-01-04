package hxgnd;

class ResultUtils {

    public static inline function create<T>(f: Void -> T): Result<T> {
        return try {
            Success(f());
        } catch (e: Error) {
            Failure(e);
        } catch (e: Dynamic) {
            Failure(new Error(Std.string(e)));
        }
    }

    public static inline function map<A, B>(x: Result<A>, f: A -> B): Result<B> {
        return switch (x) {
            case Success(a):
                try {
                    Success(f(a));
                } catch (e: Error) {
                    Failure(e);
                } catch (e: Dynamic) {
                    Failure(new Error(Std.string(e)));
                }
            case Failure(e):
                Failure(e);
        }
    }

    public static inline function get<A>(x: Result<A>): A {
        return switch (x) {
            case Success(a): a;
            case Failure(ex): throw "get method was called but receiver was Failure: " + Std.string(ex);
        }
    }
    public static inline function isSuccess<A>(x: Result<A>): Bool {
        return switch (x) {
            case Success(a): true;
            case Failure(ex): false;
        }
    }

    public static inline function flatten<A>(x: Result<Result<A>>): Result<A> {
        return switch (x) {
            case Success(a): a;
            case Failure(ex): Failure(ex);
        }
    }

    public static inline function flatMap<A, B>(x: Result<A>, f: A -> Result<B>): Result<B> {
        return switch (x) {
            case Success(a): flatten(map(x, f));
            case Failure(ex): Failure(ex);
        }
    }

    public static inline function failureMap<A>(x: Result<A>, f: Error -> Result<A>): Result<A> {
        return switch (x) {
            case Success(a): x;
            case Failure(ex):
                try {
                    f(ex);
                } catch (e: Error) {
                    Failure(e);
                } catch (e: Dynamic) {
                    Failure(new Error(Std.string(e)));
                };
        }
    }

    public static inline function iter<A>(x: Result<A>, f: A -> Void): Void {
        switch(x){
            case Success(a): f(a);
            case Failure(ex): Unit;
        }
    }
    public static inline function failureIter<A>(x: Result<A>, f: Error -> Void): Void {
        switch(x){
            case Success(a): Unit;
            case Failure(ex): f(ex);
        }
    }

    public inline static function toPromise<A>(result:Result<A>):Promise<A> {
        return switch(result) {
            case Success(arg): Promise.fulfilled(arg);
            case Failure(err): Promise.rejected(err);
        }
    }
}
