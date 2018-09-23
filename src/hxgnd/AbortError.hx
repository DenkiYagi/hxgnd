package hxgnd;

class AbortError extends Error {
    public function new(message: String = "aborted") {
        super(message);
        this.name = "AbortError";
    }
}