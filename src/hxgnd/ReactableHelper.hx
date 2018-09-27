package hxgnd;

class ReactableHelper {
    public static inline function map<T, U>(observable: Observable<T>, fn: T -> U): Reactable<U> {
        return new ReactiveStream<U>(function (emit) {
            observable.observe(function map_observer(x) {
                emit(fn(x));
            });
        });
    }

    public static inline function flatMap<T, U>(observable: Observable<T>, fn: T -> Reactable<U>): Reactable<U> {
        return new ReactiveStream<U>(function (emit) {
            observable.observe(function flatMap_observer(x) {
                fn(x).observe(emit);
            });
        });
    }

    public static inline function filter<T>(observable: Observable<T>, fn: T -> Bool): Reactable<T> {
        return new ReactiveStream<T>(function (emit) {
            observable.observe(function filter_observer(x) {
                if (fn(x)) emit(x);
            });
        });
    }

    public static inline function reduce<T>(observable: Observable<T>, fn: T -> T -> T): Reactable<T> {
        return new ReactiveStream<T>(function (emit) {
            var prev = Maybe.empty();
            observable.observe(function reduce_observer(x) {
                var value = prev.isEmpty() ? x : fn(prev.get(), x);
                prev = Maybe.ofNullable(value);
                emit(value);
            });
        });
    }

    public static inline function fold<T, U>(observable: Observable<T>, init: U, fn: U -> T -> U): Reactable<U> {
        return new ReactiveStream<U>(function (emit) {
            var prev = init;
            observable.observe(function fold_observer(x) {
                var value = fn(prev, x);
                prev = value;
                emit(value);
            });
        });
    }

    public static inline function skip<T>(observable: Observable<T>, count: Int): Reactable<T> {
        return if (count > 0) {
            new ReactiveStream<T>(function (emit) {
                observable.observe(function skip_observer(x) {
                    if (count-- > 0) {
                        observable.unobserve(skip_observer);
                        observable.observe(emit);
                    }
                });
            });
        } else {
            toReactable(observable);
        }
    }

    public static inline function throttle<T>(observable: Observable<T>, msec: Int): Reactable<T> {
        return if (msec > 0) {
            new ReactiveStream<T>(function (emit) {
                var prev = Math.NEGATIVE_INFINITY;
                observable.observe(function throttle_observer(x) {
                    var time = hxgnd.js.JsDate.now();
                    if ((time - prev) >= msec) {
                        prev = time;
                        emit(x);
                    }
                });
            });
        } else {
            toReactable(observable);
        }
    }

    public static inline function debounce<T>(observable: Observable<T>, msec: Int): Reactable<T> {
        return if (msec > 0) {
            new ReactiveStream<T>(function (emit) {
                var handle = Maybe.empty();
                observable.observe(function debounce_observer(x) {
                    if (handle.nonEmpty()) {
                        js.Browser.window.clearTimeout(handle.get());
                    }
                    handle = Maybe.ofNullable(js.Browser.window.setTimeout(emit.bind(x), msec));
                });
            });
        } else {
            toReactable(observable);
        }
    }

    public static inline function toReactable<T>(observable: Observable<T>): Reactable<T> {
        return new ReactiveStream<T>(function (emit) {
            observable.observe(emit);
        });
    }
}