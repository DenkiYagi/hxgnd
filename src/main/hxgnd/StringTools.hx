package hxgnd;

class StringTools {

    public static function isEmpty(x: Null<String>): Bool {
        return x == null || x == "";
    }
    
    public static function isNotEmpty(x: Null<String>): Bool {
        return x != null && x != "";
    }
    
}