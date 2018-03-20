package hxgnd.js;

import js.html.EventTarget;
import js.html.EventListener;
import haxe.Constraints.Function;
import externtype.Mixed2;

class HtmlTools {
    public static inline function addVenderEventListener(target: EventTarget, type: String, listener: Mixed2<EventListener, Function>, ?capture: Bool = false): Void {
        if (JsReflect.has(target, "on" + type)) {
            target.addEventListener(type, listener);
        } else if (JsReflect.has(target, "onwebkit" + type)) {
            target.addEventListener("webkit" + type, listener);
        } else if (JsReflect.has(target, "onmoz" + type)) {
            target.addEventListener("moz" + type, listener);
        } else if (JsReflect.has(target, "onms" + type)) {
            target.addEventListener("ms" + type, listener);
        } 
    }

    public static inline function removeVenderEventListener(target: EventTarget, type: String, listener: Mixed2<EventListener, Function>, ?capture: Bool = false): Void {
        if (JsReflect.has(target, "on" + type)) {
            target.removeEventListener(type, listener);
        } else if (JsReflect.has(target, "onwebkit" + type)) {
            target.removeEventListener("webkit" + type, listener);
        } else if (JsReflect.has(target, "onmoz" + type)) {
            target.removeEventListener("moz" + type, listener);
        } else if (JsReflect.has(target, "onms" + type)) {
            target.removeEventListener("ms" + type, listener);
        } 
    }
}