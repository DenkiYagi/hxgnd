package hxgnd.internal.traverser;

import extype.Maybe;

interface ITraverser<T> {
    var current(default, null): Maybe<T>;
    function next(): Bool;
}
