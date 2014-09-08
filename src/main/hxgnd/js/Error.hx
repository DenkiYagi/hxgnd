package hxgnd.js;

typedef Error = js.Error;

class ErrorTools {
    public static inline function initialize(error: Error, message: String) {
        error.name = Type.getClassName(Type.getClass(error));
        error.message = (message != null) ? message : "";
        cast(error).stack = new js.Error().stack;
    }
}