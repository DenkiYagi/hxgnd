package hxgnd;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import extype.Maybe;
using haxe.macro.ExprTools;
using hxgnd.LangTools;
using hxgnd.ArrayTools;

class Computation {
    public static function perform<T, M>(builder: ComputationExprBuilder<T, M>, blockExpr: Expr): Expr {
        var transformer = new VirtualExprTransformer(builder);

        var nodes = [Untraversed(blockExpr)];
        while (nodes.nonEmpty()) {
            // trace(nodes[0]);
            switch (nodes.shift()) {
                case Untraversed(expr):
                    switch (expr.expr) {
                        case EReturn(e) if (e.isNull()):
                            transformer.emit(ReturnZero);
                        case EReturn(e):
                            nodes = [Virtual(Return), Untraversed(e), Virtual(End)].concat(nodes);

                        case EMeta({name: "return"}, e):
                            nodes = [Virtual(ReturnFrom), Untraversed(e), Virtual(End)].concat(nodes);

                        case EMeta({name: "do"}, e):
                            nodes = [Virtual(Do), Untraversed(e), Virtual(End)].concat(nodes);
                        case EMeta({name: "var"}, e):
                            switch (e.expr) {
                                case EBinop(OpAssign, {expr: EConst(CIdent(ident))}, e):
                                    nodes = [Virtual(Bind(ident, null)), Untraversed(e), Virtual(End)].concat(nodes);
                                case _:
                                    Context.error("syntax error", e.pos);
                            }
                        case EVars(vars):
                            var i = vars.length;
                            while (--i >= 0) {
                                var v = vars[i];
                                if (v.expr == null) Context.error("Unsupported expr", v.expr.pos);
                                nodes = [Virtual(Var(v.name, v.type)), Untraversed(v.expr), Virtual(End)].concat(nodes);
                            }
                        case EBlock(e):
                            if (e.nonEmpty()) {
                                var tmp = [Virtual(Block)];
                                for (x in e) tmp.push(Untraversed(x));
                                tmp.push(Virtual(End));
                                nodes = tmp.concat(nodes);
                            }
                        case EIf(econd, eif, eelse):
                            if (eelse != null) {
                                nodes = [Virtual(If(econd)), Untraversed(eif), Virtual(Else), Untraversed(eelse), Virtual(End)].concat(nodes);
                            } else {
                                nodes = [Virtual(If(econd)), Untraversed(eif), Virtual(End)].concat(nodes);
                            }
                        case ETernary(econd, eif, eelse):
                            nodes = [Virtual(If(econd)), Untraversed(eif), Virtual(Else), Untraversed(eelse), Virtual(End)].concat(nodes);
                        case ESwitch(e, cases, edef):
                            var tmp = [Virtual(Switch(e))];
                            for (x in cases) {
                                tmp = tmp.concat([Virtual(Case(x.values, x.guard)), Untraversed(x.expr)]);
                            }
                            if (edef != null) {
                                tmp = tmp.concat([Virtual(CaseDefault), Untraversed(edef)]);
                            }
                            tmp.push(Virtual(End));
                            nodes = tmp.concat(nodes);
                        case EWhile(econd, e, true):
                            nodes = [Virtual(While(econd)), Untraversed(e), Virtual(End)].concat(nodes);
                        case EFor({expr: EIn({expr: EConst(CIdent(ident))}, iter)}, e):
                            nodes = [Virtual(For(iter, ident)), Untraversed(e), Virtual(End)].concat(nodes);
                        case ETry(e, catches):
                            var tmp = [Virtual(Try), Untraversed(e)];
                            for (c in catches) {
                                tmp = tmp.concat([Virtual(Catch(c.name, c.type)), Untraversed(c.expr)]);
                            }
                            tmp.push(Virtual(End));
                            nodes = tmp.concat(nodes);
                        case EBreak:
                            Context.error("Unsupported expr", expr.pos);
                        case _:
                            transformer.emit(Expr(expr));
                    }
                case Virtual(vexpr):
                    transformer.emit(vexpr);
            }
        }

        //trace(haxe.macro.ExprTools.toString(transformer.transform()));
        return transformer.transform();
    }
}

typedef ComputationExprBuilder<T, M> = {
    var buildZero: Void -> ExprOf<M>;
    var buildBind: ExprOf<M> -> ExprOf<T -> M> -> ExprOf<M>;
    var buildReturn: ExprOf<T> -> ExprOf<M>;
    @:optional var buildReturnFrom: ExprOf<M -> M>;
    @:optional var buildWhile: ExprOf<Void -> Bool> -> ExprOf<Void -> M> -> ExprOf<M>;
    @:optional var buildFor: Expr -> ExprOf<Void -> M> -> ExprOf<M>;
    @:optional var buildRun: ExprOf<Void -> M> -> ExprOf<M>;
    @:optional var buildDelay: ExprOf<Void -> M> -> ExprOf<Void -> M>;
    @:optional var buildCombine: ExprOf<M> -> ExprOf<M> -> ExprOf<M>;
}

private class VirtualExprTransformer<T, M> {
    var builder: ComputationExprBuilder<T, M>;
    var blockStack: Array<ComputationBlock<T, M>>;
    var currentBlock: ComputationBlock<T, M>;

    public function new(builder: ComputationExprBuilder<T, M>) {
        this.builder = builder;
        this.blockStack = [];
        pushBlock(new ComputationBlock(Block, builder));
    }

    public function transform(): Expr {
        var expr = currentBlock.build();
        var body = buildDelay(expr);
        return if (builder.buildRun.nonNull()) {
            builder.buildRun(body);
        } else {
            macro ${body}();
        }
    }

    function buildDelay(cexpr: ComputationExpr): ExprOf<Void-> M> {
        var fn = cexpr.isReturn
                ? macro function delay() ${cexpr.expr}
                : macro function delay() return ${cexpr.expr};

        return if (builder.buildDelay.nonNull()) {
            builder.buildDelay(fn);
        } else {
            fn;
        }
    }

    public function emit(vexpr: VirtualExpr): Void {
        switch (vexpr) {
            case Expr(expr):
                currentBlock.emitRawExpr(expr);
            case ReturnZero:
                currentBlock.emitReturnFrom({
                    expr: builder.buildZero(),
                    isReturn: false
                });
            case End:
                buildBlock();
            case _:
                pushBlock(new ComputationBlock(vexpr, builder));
        }
    }

    function buildBlock(): Void {
        switch (currentBlock.vexpr) {
            case Return:
                var cexpr = currentBlock.build();
                popBlock();
                currentBlock.emitReturn(cexpr);
            case ReturnFrom:
                var cexpr = currentBlock.build();
                popBlock();
                currentBlock.emitReturnFrom(cexpr);

            case Var(name, type):
                var cexpr = currentBlock.build();
                popBlock();
                currentBlock.emitRawExpr({
                    expr: EVars([{name: name, type: type, expr: cexpr.expr}]),
                    pos: Context.currentPos()
                });

            case Do:
                var cexpr = currentBlock.build();
                popBlock();
                currentBlock.emitBinding("_", null, cexpr.expr);
            case Bind(name, type):
                var cexpr = currentBlock.build();
                popBlock();
                currentBlock.emitBinding(name, type, cexpr.expr);

            case Block:
                var cexpr = currentBlock.build();
                popBlock();
                currentBlock.emitCexpr(cexpr);

            case If(cond):
                var cif = currentBlock.build();
                popBlock();
                currentBlock.emitCexpr({
                    expr: {expr: EIf(cond, cif.expr, builder.buildZero()), pos: Context.currentPos()},
                    isReturn: false
                });
            case Else:
                var celse = currentBlock.build();
                popBlock();
                switch (currentBlock.vexpr) {
                    case If(cond):
                        var cif = currentBlock.build();
                        popBlock();
                        currentBlock.emitCexpr({
                            expr: {expr: EIf(cond, cif.expr, celse.expr), pos: Context.currentPos()},
                            isReturn: cif.isReturn && celse.isReturn
                        });
                    case _:
                        Context.error("invalid expr", Context.currentPos());
                }

            case Case(values, guard):
                var cases = [{values: values, guard: guard, expr: currentBlock.build().expr}];
                while (true) {
                    popBlock();
                    switch (currentBlock.vexpr) {
                        case Switch(expr):
                            popBlock();
                            currentBlock.emitCexpr({
                                expr: {expr: ESwitch(expr, cases, null), pos: Context.currentPos()},
                                isReturn: false
                            });
                            break;
                        case Case(values, guard):
                            cases.unshift({values: values, guard: guard, expr: currentBlock.build().expr});
                        case _:
                            Context.error("invalid expr", Context.currentPos());
                    }
                }
            case CaseDefault:
                var cdef = currentBlock.build();
                var cases = [];
                var isReturn = cdef.isReturn;
                while (true) {
                    popBlock();
                    switch (currentBlock.vexpr) {
                        case Switch(expr):
                            popBlock();
                            currentBlock.emitCexpr({
                                expr: {expr: ESwitch(expr, cases, cdef.expr), pos: Context.currentPos()},
                                isReturn: isReturn
                            });
                            break;
                        case Case(values, guard):
                            var cexpr = currentBlock.build();
                            cases.unshift({values: values, guard: guard, expr: cexpr.expr});
                            isReturn = isReturn && cexpr.isReturn;
                        case _:
                            Context.error("invalid expr", Context.currentPos());
                    }
                }

            case While(cond):
                if (builder.buildWhile.nonNull()) {
                    var body = buildDelay(currentBlock.build());
                    popBlock();
                    currentBlock.emitCexpr({
                        expr: builder.buildWhile(macro function() return ${cond}, body),
                        isReturn: false
                    });
                } else {
                    popBlock();
                }
            case For(iter, ident):
                if (builder.buildFor.nonNull()) {
                    var body = currentBlock.build();
                    popBlock();
                    currentBlock.emitCexpr({
                        expr: builder.buildFor(iter, ${{
                            expr: EFunction(null, {
                                args: [{name: ident, type: null}],
                                ret: null,
                                expr: body.isReturn ? body.expr : macro return ${body.expr}
                            }),
                            pos: Context.currentPos()
                        }}),
                        isReturn: false
                    });
                } else {
                    popBlock();
                }

            case Catch(name, type):
                var cexpr = currentBlock.build();
                var cathes = [{name: name, type: type, expr: cexpr.expr}];
                var isReturn = cexpr.isReturn;
                while (true) {
                    popBlock();
                    switch (currentBlock.vexpr) {
                        case Try:
                            var cexpr = currentBlock.build();
                            popBlock();
                            isReturn = isReturn && cexpr.isReturn;
                            currentBlock.emitCexpr({
                                expr: {expr: ETry(cexpr.expr, cathes), pos: Context.currentPos()},
                                isReturn: isReturn
                            });
                            break;
                        case Catch(name, type):
                            var cexpr = currentBlock.build();
                            isReturn = isReturn && cexpr.isReturn;
                            cathes.unshift({name: name, type: type, expr: cexpr.expr});
                        case _:
                            Context.error("invalid expr", Context.currentPos());
                    }
                }

            case _:
                trace(currentBlock.vexpr);
                Context.error("invalid expr", Context.currentPos());
        }
    }

    inline function pushBlock(vblock: ComputationBlock<T, M>): Void {
        blockStack.push(vblock);
        currentBlock = vblock;
    }

    inline function popBlock(): Void {
        if (blockStack.isEmpty()) Context.error("invalid expr", Context.currentPos());
        blockStack.pop();
        currentBlock = blockStack.last().getOrThrow();
    }
}

private class ComputationBlock<T, M> {
    public var vexpr(default, null): VirtualExpr;

    var builder: ComputationExprBuilder<T, M>;
    var bindings: Array<{name: String, type: Null<ComplexType>, preExprs: Array<Expr>, cexpr: Expr}>;
    var preExprs: Array<Expr>;
    var cexpr: Maybe<Expr>;
    var isReturned: Bool;

    public function new(vexpr: VirtualExpr, builder: ComputationExprBuilder<T, M>) {
        this.vexpr = vexpr;
        this.builder = builder;
        this.bindings = [];
        this.preExprs = [];
        this.cexpr = Maybe.empty();
        this.isReturned = false;
    }

    public function emitRawExpr(expr: Expr): Void {
        if (isReturned) return;

        preExprs.push(expr);
    }

    public function emitCexpr(cexpr: ComputationExpr): Void {
        if (isReturned) return;

        _emitCexpr(cexpr.expr);
        isReturned = cexpr.isReturn;
    }

    private inline function _emitCexpr(expr: Expr) {
        if (cexpr.isEmpty()) {
            cexpr = expr;
        } else if (builder.buildCombine.nonNull()) {
            cexpr = builder.buildCombine(build().expr, expr);
            preExprs = [];
            bindings = [];
        } else {
            bindings.push({
                name: "_",
                type: null,
                preExprs: preExprs,
                cexpr: cexpr.get(),
            });
            cexpr = expr;
            preExprs = [];
        }
    }

    public function emitReturn(cexpr: ComputationExpr): Void {
        if (isReturned) return;

        emitCexpr({
            expr: cexpr.isReturn ? cexpr.expr : macro return ${builder.buildReturn(cexpr.expr)},
            isReturn: true
        });
    }

    public function emitReturnFrom(cexpr: ComputationExpr): Void {
        if (isReturned) return;

        emitCexpr({
            expr: cexpr.isReturn ? cexpr.expr : macro return ${cexpr.expr},
            isReturn: true
        });
    }

    public function emitBinding(name: String, type: Null<ComplexType>, expr: Expr): Void {
        if (isReturned) return;

        bindings.push({
            name: name,
            type: type,
            preExprs: preExprs,
            cexpr: expr,
        });
        preExprs = [];
        cexpr = Maybe.empty();
    }

    public function build(): ComputationExpr {
        return if (bindings.isEmpty()) {
            var acc = if (cexpr.isEmpty()) {
                switch (vexpr) {
                    case Var(_, _) | Bind(_, _) | Do | Return | ReturnFrom:
                        switch (preExprs.length) {
                            case 0: null;
                            case 1: preExprs[0];
                            case _: macro $b{preExprs}
                        }
                    case _:
                        if (preExprs.isEmpty()) {
                            builder.buildZero();
                        } else {
                            macro $b{preExprs.concat([builder.buildZero()])};
                        }
                }
            } else {
                if (preExprs.isEmpty()) {
                    cexpr.get();
                } else {
                    macro $b{preExprs.concat([cexpr.get()])};
                }
            }

            {expr: acc, isReturn: isReturned};
        } else {
            var acc = if (cexpr.isEmpty()) {
                if (preExprs.isEmpty()) {
                    builder.buildZero();
                } else {
                    macro $b{preExprs.concat([builder.buildZero()])};
                }
            } else {
                if (preExprs.isEmpty()) {
                    cexpr.get();
                } else {
                    macro $b{preExprs.concat([cexpr.get()])};
                }
            }

            if (!isReturned) {
                acc = macro return ${acc};
            }

            var i = bindings.length;
            while (i > 0) {
                var binding = bindings[--i];

                acc = builder.buildBind(binding.cexpr, {
                    expr: EFunction(null, {
                        args: [{name: binding.name, type: binding.type}],
                        ret: null,
                        expr: macro ${acc}
                    }),
                    pos: binding.cexpr.pos
                });

                if (binding.preExprs.nonEmpty()) {
                    acc = macro $b{binding.preExprs.concat([acc])};
                }

                acc = macro return ${acc};
            }

            {expr: acc, isReturn: true};
        }
    }
}

private enum TraversingExpr {
    Untraversed(expr: Expr);
    Virtual(vexpr: VirtualExpr);
}

private enum VirtualExpr {
    Expr(expr: Expr);
    Return;
    ReturnFrom;
    ReturnZero;
    Var(name: String, type: Null<ComplexType>);
    Bind(name: String, type: Null<ComplexType>);
    Do;
    Block;
    If(cond: Expr);
    Else;
    Switch(expr: Expr);
    Case(values: Array<Expr>, guard: Null<Expr>);
    CaseDefault;
    While(cond: Expr);
    For(iter: Expr, ident: String);
    Try;
    Catch(name: String, type: ComplexType);
    End;
}

private typedef ComputationExpr = {
    var expr: Expr;
    var isReturn: Bool;
}
#end
