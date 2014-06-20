package hxgnd.js;

@:native("Error")
extern class Error {
    public function new(?message: String);
    public var name: String;
    public var message: String;
    public var stack: String;
}
