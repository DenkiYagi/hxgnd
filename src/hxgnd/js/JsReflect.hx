package hxgnd.js;

import haxe.Constraints.Function;

@:native("Reflect")
extern class JsReflect {
    static function apply(target: Function, thisArgument: Dynamic, argumentsList: Array<Dynamic>): Dynamic;
    static function has(target: Dynamic, propertyKey: String): Bool;
} 