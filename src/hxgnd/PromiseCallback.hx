package hxgnd;

import externtype.Mixed;

abstract PromiseCallback<T, TOut>(T -> Dynamic)
    #if js
    from Mixed5<
        T -> js.Promise<TOut>,
        T -> SyncPromise<TOut>,
        T -> AbortablePromise<TOut>,
        T -> Promise<TOut>,
        T -> TOut
    >
    #else
    from Mixed4<
        T -> SyncPromise<TOut>,
        T -> AbortablePromise<TOut>,
        T -> Promise<TOut>,
        T -> TOut
    >
    #end
    to T -> Dynamic
{}