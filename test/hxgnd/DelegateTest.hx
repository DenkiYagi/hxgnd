package hxgnd;

import buddy.BuddySuite;
using buddy.Should;
using hxgnd.LangTools;

class DelegateTest extends BuddySuite {
    public function new() {
        describe("Delegate.new()", {
            it("should be empty", {
                var delegate = new Delegate<Int>();
                (delegate: ReadOnlyArray<Int -> Void>).length.should.be(0);
            });
        });

        describe("Delegate.add()", {
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

        describe("Delegate.remove()", {
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

        describe("Delegate.removeAll()", {
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

        describe("Delegate.invoke()", {
            it("should complete when it has no items", {
                var delegate = new Delegate<Int>();
                delegate.invoke(1);
            });

            it("should complete when it has one item", function (done) {
                var delegate = new Delegate<Int>();
                delegate.add(function (i) {
                    i.should.be(1);
                    done();
                });

                delegate.invoke(1);
            });

            it("should complete when it has two items", function (done) {
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
        });
    }
}