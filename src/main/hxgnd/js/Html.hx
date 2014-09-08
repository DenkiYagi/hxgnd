package hxgnd.js;
import js.html.Element;
import js.html.EventTarget;
import js.html.Node;
import js.html.NodeList;

@:forward
abstract Html(JqHtml) from JqHtml to JqHtml {
    inline function new(x: JqHtml) {
        this = x;
    }

    @:from public static function fromString(selector: String): Html {
        return new Html(JQuery._(selector));
    }

    @:from public static function fromNode(node: Node): Html {
        return new Html(JQuery._(node));
    }

    @:from public static function fromNodes(nodes: Array<Node>): Html {
        return new Html(JQuery._(nodes));
    }

    @:from public static function fromNodeList(nodes: NodeList): Html {
        return new Html(JQuery._(nodes));
    }

    @:from public static function fromEventTarget(node: EventTarget): Html {
        return new Html(JQuery._(node));
    }
}