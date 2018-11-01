package hxgnd;

import buddy.BuddySuite;
import extype.ReadOnlyArray;
using buddy.Should;
using hxgnd.LangTools;
import hxgnd.Delegate;
import TestTools.wait;

class DelegateTest extends BuddySuite {
    public function new() {
        timeoutMs = 100;

        describe("Delegate<T>", {
            describe("Delegate#new()", {
                it("should be empty", {
                    var delegate = new Delegate<Int>();
                    (delegate: ReadOnlyArray<Int -> Void>).length.should.be(0);
                });

                it("should copy", {
                    var functions = [
                        function (x) {},
                        function (x) {}
                    ];

                    var delegate = new Delegate<Int>(functions);
                    LangTools.eq(untyped delegate, untyped functions).should.be(false);
                    (delegate: ReadOnlyArray<Int -> Void>).length.should.be(2);
                    (delegate: ReadOnlyArray<Int -> Void>).same(functions).should.be(true);
                });
            });

            describe("Delegate#add()", {
                it("should be added when it has no items", {
                    var delegate = new Delegate<Int>();
                    var f = function (i) {}
                    delegate.add(f);

                    var array = (delegate: ReadOnlyArray<Int -> Void>);
                    array.length.should.be(1);
                    array[0].same(f).should.be(true);
                });

                it("should be skipped when it is given a same item", {
                    var delegate = new Delegate<Int>();
                    var f = function (i) {}
                    delegate.add(f);
                    delegate.add(f);

                    var array = (delegate: ReadOnlyArray<Int -> Void>);
                    array.length.should.be(1);
                    array[0].same(f).should.be(true);
                });

                it("should be added when it is given a different item", {
                    var delegate = new Delegate<Int>();
                    var f1 = function (i) {}
                    var f2 = function (i) {}
                    delegate.add(f1);
                    delegate.add(f2);

                    var array = (delegate: ReadOnlyArray<Int -> Void>);
                    array.length.should.be(2);
                    array[0].same(f1).should.be(true);
                    array[1].same(f2).should.be(true);
                });
            });

            describe("Delegate#remove()", {
                it("should return false when it has no items", {
                    var delegate = new Delegate<Int>();
                    var f1 = function (i) {}

                    var ret = delegate.remove(f1);
                    ret.should.be(false);

                    var array = (delegate: ReadOnlyArray<Int -> Void>);
                    array.length.should.be(0);
                });

                it("should be removed and should return true when it is given a matched item", {
                    var delegate = new Delegate<Int>();
                    var f1 = function (i) {}
                    var f2 = function (i) {}
                    delegate.add(f1);
                    delegate.add(f2);

                    var ret = delegate.remove(f1);
                    ret.should.be(true);

                    var array = (delegate: ReadOnlyArray<Int -> Void>);
                    array.length.should.be(1);
                    array[0].same(f2).should.be(true);
                });

                it("should not be removed and should return false when it is given a unmatched item", {
                    var delegate = new Delegate<Int>();
                    var f1 = function (i) {}
                    var f2 = function (i) {}
                    var f3 = function (i) {}
                    delegate.add(f1);
                    delegate.add(f2);

                    delegate.remove(f3);

                    var array = (delegate: ReadOnlyArray<Int -> Void>);
                    array.length.should.be(2);
                    array[0].same(f1).should.be(true);
                    array[1].same(f2).should.be(true);
                });
            });

            describe("Delegate#removeAll()", {
                it("should complete when is has no items", {
                    var delegate = new Delegate<Int>();
                    delegate.removeAll();

                    var array = (delegate: ReadOnlyArray<Int -> Void>);
                    array.length.should.be(0);
                });

                it("should be removed all when it has any items", {
                    var delegate = new Delegate<Int>();
                    var f1 = function (i) {}
                    var f2 = function (i) {}
                    delegate.add(f1);
                    delegate.add(f2);

                    delegate.removeAll();

                    var array = (delegate: ReadOnlyArray<Int -> Void>);
                    array.length.should.be(0);
                });
            });

            describe("Delegate#isEmpty()", {
                it("should be true", {
                    var delegate = new Delegate();
                    delegate.isEmpty().should.be(true);
                });

                it("should be false", {
                    var delegate = new Delegate();
                    delegate.add(function (_) {});
                    delegate.isEmpty().should.be(false);
                });
            });

            describe("Delegate#nonEmpty()", {
                it("should be false", {
                    var delegate = new Delegate();
                    delegate.nonEmpty().should.be(false);
                });

                it("should be true", {
                    var delegate = new Delegate();
                    delegate.add(function (_) {});
                    delegate.nonEmpty().should.be(true);
                });
            });

            describe("Delegate#invoke()", {
                it("should pass when it has no items", {
                    var delegate = new Delegate<Int>();
                    delegate.invoke(1);
                });

                it("should pass when it has one item", function (done) {
                    var delegate = new Delegate<Int>();
                    delegate.add(function (i) {
                        i.should.be(1);
                        done();
                    });

                    delegate.invoke(1);
                });

                it("should pass when it has two items", function (done) {
                    var delegate = new Delegate<Int>();
                    delegate.add(function (i) {
                        i.should.be(2);
                    });
                    delegate.add(function (i) {
                        i.should.be(2);
                        done();
                    });

                    delegate.invoke(2);
                });

                it("should pass when it remove itself", {
                    var count1 = 0;
                    var count2 = 0;

                    var delegate = new Delegate<Int>();
                    delegate.add(function f1(i) {
                        delegate.remove(f1);
                        count1++;
                    });
                    delegate.add(function f2(i) {
                        delegate.remove(f2);
                        count2++;
                    });

                    delegate.invoke(2);
                    count1.should.be(1);
                    count2.should.be(1);

                    delegate.invoke(3);
                    count1.should.be(1);
                    count2.should.be(1);
                });
            });

            describe("Delegate#invokeAsync()", {
                it("should pass when it has no items", {
                    var delegate = new Delegate<Int>();
                    delegate.invokeAsync(0);
                });

                it("should pass when it has one item", function (done) {
                    var delegate = new Delegate<Int>();
                    delegate.add(function (i) {
                        i.should.be(1);
                        done();
                    });

                    delegate.invokeAsync(1);
                });

                it("should pass when it has two items", function (done) {
                    var delegate = new Delegate<Int>();
                    delegate.add(function (i) {
                        i.should.be(2);
                    });
                    delegate.add(function (i) {
                        i.should.be(2);
                        done();
                    });

                    delegate.invokeAsync(2);
                });

                it("should pass when it has two items", function (done) {
                    var count1 = 0;
                    var count2 = 0;

                    var delegate = new Delegate<Int>();
                    delegate.add(function (i) {
                        i.should.be(2);
                        count1++;
                    });
                    delegate.add(function (i) {
                        i.should.be(2);
                        count2++;
                    });

                    delegate.invokeAsync(2);
                    count1.should.be(0);
                    count2.should.be(0);

                    wait(5, function () {
                        count1.should.be(1);
                        count2.should.be(1);
                        done();
                    });
                });

                it("should pass when it remove itself", function (done) {
                    var count1 = 0;
                    var count2 = 0;

                    var delegate = new Delegate<Int>();
                    delegate.add(function f1(i) {
                        delegate.remove(f1);
                        count1++;
                    });
                    delegate.add(function f2(i) {
                        delegate.remove(f2);
                        count2++;
                    });

                    delegate.invokeAsync(2);
                    count1.should.be(0);
                    count2.should.be(0);

                    wait(5, function () {
                        count1.should.be(1);
                        count2.should.be(1);

                        wait(5, function () {
                            delegate.invoke(3);
                            count1.should.be(1);
                            count2.should.be(1);
                            done();
                        });
                    });
                });

                it("should call all handlers when it calls removeAll() before dispatch", function (done) {
                    var called1 = 0;
                    var called2 = 0;
                    var delegate = new Delegate([
                        function (i) called1++,
                        function (i) called2++,
                    ]);
                    delegate.invokeAsync(1);
                    delegate.removeAll();

                    called1.should.be(0);
                    called2.should.be(0);
                    wait(5, function () {
                        called1.should.be(1);
                        called2.should.be(1);
                        done();
                    });
                });
            });

            describe("Delegate#copy()", {
                it("should pass", {
                    var delegate = new Delegate<Int>([
                        function (x) {},
                        function (x) {},
                    ]);
                    var copy = delegate.copy();
                    copy.eq(delegate).should.be(false);
                    copy.same(delegate).should.be(true);
                });
            });
        });

        describe("Delegate0", {
            describe("Delegate0#new()", {
                it("should be empty", {
                    var delegate = new Delegate0();
                    (delegate: ReadOnlyArray<Void -> Void>).length.should.be(0);
                });

                it("should copy", {
                    var functions = [
                        function () {},
                        function () {}
                    ];

                    var delegate = new Delegate0(functions);
                    LangTools.eq(untyped delegate, untyped functions).should.be(false);
                    (delegate: ReadOnlyArray<Void -> Void>).length.should.be(2);
                    (delegate: ReadOnlyArray<Void -> Void>).same(functions).should.be(true);
                });
            });

            describe("Delegate0#add()", {
                it("should be added when it has no items", {
                    var delegate = new Delegate0();
                    var f = function () {}
                    delegate.add(f);

                    var array = (delegate: ReadOnlyArray<Void -> Void>);
                    array.length.should.be(1);
                    array[0].same(f).should.be(true);
                });

                it("should be skipped when it is given a same item", {
                    var delegate = new Delegate0();
                    var f = function () {}
                    delegate.add(f);
                    delegate.add(f);

                    var array = (delegate: ReadOnlyArray<Void -> Void>);
                    array.length.should.be(1);
                    array[0].same(f).should.be(true);
                });

                it("should be added when it is given a different item", {
                    var delegate = new Delegate0();
                    var f1 = function () {}
                    var f2 = function () {}
                    delegate.add(f1);
                    delegate.add(f2);

                    var array = (delegate: ReadOnlyArray<Void -> Void>);
                    array.length.should.be(2);
                    array[0].same(f1).should.be(true);
                    array[1].same(f2).should.be(true);
                });
            });

            describe("Delegate0#remove()", {
                it("should return false when it has no items", {
                    var delegate = new Delegate0();
                    var f1 = function () {}

                    var ret = delegate.remove(f1);
                    ret.should.be(false);

                    var array = (delegate: ReadOnlyArray<Void -> Void>);
                    array.length.should.be(0);
                });

                it("should be removed and should return true when it is given a matched item", {
                    var delegate = new Delegate0();
                    var f1 = function () {}
                    var f2 = function () {}
                    delegate.add(f1);
                    delegate.add(f2);

                    var ret = delegate.remove(f1);
                    ret.should.be(true);

                    var array = (delegate: ReadOnlyArray<Void -> Void>);
                    array.length.should.be(1);
                    array[0].same(f2).should.be(true);
                });

                it("should not be removed and should return false when it is given a unmatched item", {
                    var delegate = new Delegate0();
                    var f1 = function () {}
                    var f2 = function () {}
                    var f3 = function () {}
                    delegate.add(f1);
                    delegate.add(f2);

                    delegate.remove(f3);

                    var array = (delegate: ReadOnlyArray<Void -> Void>);
                    array.length.should.be(2);
                    array[0].same(f1).should.be(true);
                    array[1].same(f2).should.be(true);
                });
            });

            describe("Delegate0#removeAll()", {
                it("should complete when is has no items", {
                    var delegate = new Delegate0();
                    delegate.removeAll();

                    var array = (delegate: ReadOnlyArray<Void -> Void>);
                    array.length.should.be(0);
                });

                it("should be removed all when it has any items", {
                    var delegate = new Delegate0();
                    var f1 = function () {}
                    var f2 = function () {}
                    delegate.add(f1);
                    delegate.add(f2);

                    delegate.removeAll();

                    var array = (delegate: ReadOnlyArray<Void -> Void>);
                    array.length.should.be(0);
                });
            });

            describe("Delegate0#isEmpty()", {
                it("should be true", {
                    var delegate = new Delegate0();
                    delegate.isEmpty().should.be(true);
                });

                it("should be false", {
                    var delegate = new Delegate0();
                    delegate.add(function () {});
                    delegate.isEmpty().should.be(false);
                });
            });

            describe("Delegate0#nonEmpty()", {
                it("should be false", {
                    var delegate = new Delegate0();
                    delegate.nonEmpty().should.be(false);
                });

                it("should be true", {
                    var delegate = new Delegate0();
                    delegate.add(function () {});
                    delegate.nonEmpty().should.be(true);
                });
            });

            describe("Delegate0#invoke()", {
                it("should pass when it has no items", {
                    var delegate = new Delegate0();
                    delegate.invoke();
                });

                it("should pass when it has one item", function (done) {
                    var delegate = new Delegate0();
                    delegate.add(function () {
                        done();
                    });

                    delegate.invoke();
                });

                it("should pass when it has two items", {
                    var count1 = 0;
                    var count2 = 0;

                    var delegate = new Delegate0();
                    delegate.add(function () {
                        count1++;
                    });
                    delegate.add(function () {
                        count2++;
                    });

                    delegate.invoke();
                    count1.should.be(1);
                    count2.should.be(1);
                });

                it("should pass when it remove itself", {
                    var count1 = 0;
                    var count2 = 0;

                    var delegate = new Delegate0();
                    delegate.add(function f1() {
                        delegate.remove(f1);
                        count1++;
                    });
                    delegate.add(function f2() {
                        delegate.remove(f2);
                        count2++;
                    });

                    delegate.invoke();
                    count1.should.be(1);
                    count2.should.be(1);

                    delegate.invoke();
                    count1.should.be(1);
                    count2.should.be(1);
                });
            });

            describe("Delegate0#invokeAsync()", {
                it("should pass when it has no items", {
                    var delegate = new Delegate0();
                    delegate.invokeAsync();
                });

                it("should pass when it has one item", function (done) {
                    var delegate = new Delegate0();
                    delegate.add(function () {
                        done();
                    });

                    delegate.invokeAsync();
                });

                it("should pass when it has two items", function (done) {
                    var count1 = 0;
                    var count2 = 0;

                    var delegate = new Delegate0();
                    delegate.add(function () {
                        count1++;
                    });
                    delegate.add(function () {
                        count2++;
                    });

                    delegate.invokeAsync();
                    count1.should.be(0);
                    count2.should.be(0);

                    wait(5, function () {
                        count1.should.be(1);
                        count2.should.be(1);
                        done();
                    });
                });

                it("should pass when it remove itself", function (done) {
                    var count1 = 0;
                    var count2 = 0;

                    var delegate = new Delegate0();
                    delegate.add(function f1() {
                        delegate.remove(f1);
                        count1++;
                    });
                    delegate.add(function f2() {
                        delegate.remove(f2);
                        count2++;
                    });

                    delegate.invokeAsync();
                    wait(5, function () {
                        count1.should.be(1);
                        count2.should.be(1);
                        wait(5, function () {
                            delegate.invokeAsync();
                            count1.should.be(1);
                            count2.should.be(1);
                            done();
                        });
                    });
                });

                it("should call all handlers when it calls removeAll() before dispatch", function (done) {
                    var called1 = 0;
                    var called2 = 0;
                    var delegate = new Delegate0([
                        function () called1++,
                        function () called2++,
                    ]);
                    delegate.invokeAsync();
                    delegate.removeAll();

                    called1.should.be(0);
                    called2.should.be(0);
                    wait(5, function () {
                        called1.should.be(1);
                        called2.should.be(1);
                        done();
                    });
                });
            });

            describe("Delegate0#copy()", {
                it("should pass", {
                    var delegate = new Delegate0([
                        function () {},
                        function () {},
                    ]);
                    var copy = delegate.copy();
                    copy.eq(delegate).should.be(false);
                    copy.same(delegate).should.be(true);
                });
            });
        });
    }
}