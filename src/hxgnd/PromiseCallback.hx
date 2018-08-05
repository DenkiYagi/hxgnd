package hxgnd;

import externtype.Mixed2;

// typedef PromiseCallback<T, TOut> = Mixed2<
//     //T -> IPromise<TOut>,
//     T -> Promise<TOut>,
//     T -> TOut
// >;
abstract PromiseCallback<T, TOut>(T -> Dynamic)
    from T -> TOut
    from T -> Promise<TOut>
    #if js from T -> js.Promise<TOut> #end
    to T -> Dynamic
{

}