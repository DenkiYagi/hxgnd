package hxgnd.internal;

import extype.extern.Mixed;

interface IPromise<T> {
    function then<TOut>(fulfilled: Null<PromiseCallback<T, TOut>>,
            ?rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut>;
    function catchError<TOut>(rejected: Mixed2<Dynamic -> Void, PromiseCallback<Dynamic, TOut>>): Promise<TOut>;
    function finally(onFinally: Void -> Void): Promise<T>;
}
