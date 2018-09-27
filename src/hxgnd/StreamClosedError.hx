package hxgnd;

class StreamClosedError extends Error {
    public function new(?message: String) {
        super(message);
        this.name = "StreamClosedError";
    }
}