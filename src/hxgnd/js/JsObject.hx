package hxgnd.js;

import haxe.extern.Rest;

@:native("Object")
extern class JsObject {
    static function assign(target: Dynamic, sources: Rest<Dynamic>): Dynamic;
    static function create(proto: Dynamic, propertiesObject: Rest<Dynamic>): Dynamic;
    static function defineProperties(obj: Dynamic, props: Dynamic<PropertyDescriptor>): Dynamic;
    static function defineProperty(obj: Dynamic, prop: String, descriptor: PropertyDescriptor): Dynamic; 
    static function entries(obj: Dynamic): Array<Array<Dynamic>>;
    static function freeze(obj: Dynamic): Dynamic;
    static function getOwnPropertyDescriptor(obj: Dynamic, prop: String): PropertyDescriptor;
    static function getOwnPropertyDescriptors(obj: Dynamic): Dynamic<PropertyDescriptor>;
    static function getOwnPropertyNames(obj: Dynamic): Array<String>;
    static function getOwnPropertySymbols(obj: Dynamic): Array<Dynamic>;
    static function getPrototypeOf(obj: Dynamic): Null<Dynamic>;
    static function is(value1: Dynamic, value2: Dynamic): Bool;
    static function isExtensible(obj: Dynamic): Bool;
    static function isFrozen(obj: Dynamic): Bool;
    static function isSealed(obj: Dynamic): Bool;
    static function keys(obj: Dynamic): Array<String>;
    static function preventExtensions(obj: Dynamic): Dynamic;
}

typedef PropertyDescriptor = {
    @:optional var configurable: Bool;
    @:optional var enumerable: Bool;
    @:optional var value: Dynamic;
    @:optional var writable: Bool;
    @:optional var get: Void -> Dynamic;
    @:optional var set: Dynamic -> Void;
}