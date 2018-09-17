package hxgnd.internal;

import hxgnd.Promise;

class PromiseComputationHelper {
    public static inline function implicitCast<T>(x: Promise<T>): Promise<T> {
        return x;
    }
}