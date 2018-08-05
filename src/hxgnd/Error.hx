package hxgnd;

#if js
typedef Error = js.Error;
#else
import haxe.CallStack;

class Error {
    private inline static var DEFAULT_NAME = "Error";

    public var message(default, default): String;
    public var name(default, default): String;
    public var stack(default, null): String;

    public function new(?message : Dynamic) {
        this.message = Maybe.ofNullable(message).getOrElse("");
        this.name = DEFAULT_NAME;
        this.stack = getCallStack();
    }

    @:allow(hxgnd)
    private static function create(error: Dynamic): Error {
        return if (Std.is(error, String)) {
            new Error(error);
        } else if (Std.is(error.message, String)) {
            var e = new Error(error.message);
            if (Std.is(error.name, String))  e.name  = error.name;
            if (Std.is(error.stack, String)) e.stack = error.stack;
            e;
        } else {
            new Error(Std.string(error));
        }
    }

    private static function getCallStack(): String {
        var callStack = CallStack.callStack();
        callStack.splice(0, 3);
        return CallStack.toString(callStack);
    }
}
#end