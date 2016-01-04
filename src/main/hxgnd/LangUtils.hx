package hxgnd;

class LangUtils {
    public static var nop(default, null) = function () { };

    public inline static function orElse<T>(a: Null<T>, b: T): T {
        return (a != null) ? a : b;
    }
	
	public static function parseFloat(x: String): Option<Float> {
		if (StringUtils.nonEmpty(x)) {
			try {
				return Some(Std.parseFloat(x));
			} catch (e: Dynamic) {
			}
		}
		return None;
	}
}