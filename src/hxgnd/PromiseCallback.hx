package hxgnd;

abstract PromiseCallback<T, TOut>(T -> Dynamic)
    from T -> TOut
    from T -> Promise<TOut>
    #if js from T -> js.Promise<TOut> #end
    to T -> Dynamic
{}