class TestTools {
    public static inline function wait(msec: Int, fn: Void -> Void): Void {
        haxe.Timer.delay(fn, msec);
    }
}