package hxgnd;

import extype.Error;

class AbortedError extends Error {
    public function new(message: String = "aborted") {
        super(message);
        this.name = "AbortedError";
    }
}