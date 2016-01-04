package hxgnd;

class StringUtils {

    public static function isEmpty(x: Null<String>): Bool {
        return x == null || x == "";
    }
    
    public static function nonEmpty(x: Null<String>): Bool {
        return x != null && x != "";
    }
    
}