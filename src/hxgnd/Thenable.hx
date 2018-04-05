package hxgnd;

typedef Thenable<T> = {
	function then(resolve:T->Void, ?reject:Dynamic->Void):Void;
}