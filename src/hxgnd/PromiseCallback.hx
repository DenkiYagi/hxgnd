package hxgnd;

import haxe.extern.EitherType;

abstract PromiseCallback<T, TOut>(T -> Dynamic)
    #if js
    from EitherType<T -> js.Promise<TOut>,
            EitherType<T -> SyncPromise<TOut>,
                EitherType<T -> AbortablePromise<TOut>,
                    EitherType<T -> Promise<TOut>, T -> TOut>>>>
    #else
    from EitherType<T -> SyncPromise<TOut>,
            EitherType<T -> AbortablePromise<TOut>,
                EitherType<T -> Promise<TOut>, T -> TOut>>>
    #end
    to T -> Dynamic
{}