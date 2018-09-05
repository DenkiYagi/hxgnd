package hxgnd;

class AbortError extends Error {
    public function new(?message: String) {
        super(message);
        this.name = "AbortError";
    }
}