package hxgnd;

#if js
typedef Error = js.Error;
#else
class Error {
	var message(default, default): String;
	var name(default, default): String;
	var stack(default, null): String;

	public function new(?message : String) {
        this.message = message;
    }
}
#end