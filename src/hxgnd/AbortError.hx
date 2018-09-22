package hxgnd;

class AbortError extends Error {
    public function new(?message: String) {
        super(Maybe.ofNullable(message).getOrElse("aborted"));
        this.name = "AbortError";
    }
}