package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using buddy.Should;

class ReactiveVarTest extends BuddySuite {
    public function new() {
        describe("ReactiveVar.new()", {
            it("should pass", {
                new ReactiveVar(10);
            });
        });

        describe("ReactiveVar.get()", {
            it("should pass", {
                var reactiveVar = new ReactiveVar(10);
                reactiveVar.get().should.be(10);
            });
        });

        describe("ReactiveVar.set()", {
            it("should pass", {
                var reactiveVar = new ReactiveVar(10);
                reactiveVar.set(-5);
                reactiveVar.get().should.be(-5);
            });
        });

        describe("ReactiveVar.subscribe()", {
            describe("single subscriber", {
                it("should not call subscriber", function (done) {
                    var reactiveVar = new ReactiveVar(10);
                    reactiveVar.subscribe(function (x) {
                        fail();
                        done();
                    });
                    reactiveVar.get();
                    wait(10, done);
                });

                it("should call subscriber 1-time", function (done) {
                    var count = 0;

                    var reactiveVar = new ReactiveVar(10);
                    reactiveVar.subscribe(function (x) {
                        count++;
                        x.should.be(-5);
                        count.should.be(1);
                        done();
                    });
                    reactiveVar.set(-5);
                });

                it("should call subscriber 2-times", function (done) {
                    var count = 0;

                    var reactiveVar = new ReactiveVar(10);
                    reactiveVar.subscribe(function (x) {
                        switch (++count) {
                            case 1:
                                x.should.be(-5);
                            case 2:
                                x.should.be(-10);
                            case _:
                                fail();
                                done();
                        }
                    });

                    reactiveVar.set(-5);
                    reactiveVar.set(-10);

                    wait(10, function () {
                        count.should.be(2);
                        done();
                    });
                });

                it("should remove subscriber", function (done) {
                    var reactiveVar = new ReactiveVar(10);
                    var unscribe = reactiveVar.subscribe(function (x) {
                        fail();
                        done();
                    });
                    unscribe();
                    reactiveVar.set(-5);
                    wait(10, done);
                });
            });

            describe("multi subscribers", {
                it("should not call all subscribers", function (done) {
                    var reactiveVar = new ReactiveVar(10);
                    reactiveVar.subscribe(function (x) {
                        fail();
                        done();
                    });
                    reactiveVar.subscribe(function (x) {
                        fail();
                        done();
                    });
                    reactiveVar.get();
                    wait(10, done);
                });

                it("should call all subscribers 1-time", function (done) {
                    var count1 = 0;
                    var count2 = 0;

                    var reactiveVar = new ReactiveVar(10);
                    reactiveVar.subscribe(function (x) {
                        x.should.be(-5);
                        count1++;
                    });
                    reactiveVar.subscribe(function (x) {
                        x.should.be(-5);
                        count2++;
                    });
                    reactiveVar.set(-5);

                    wait(10, function () {
                        count1.should.be(1);
                        count2.should.be(1);
                        done();
                    });
                });

                it("should call subscriber 2-times", function (done) {
                    var count1 = 0;
                    var count2 = 0;

                    var reactiveVar = new ReactiveVar(10);
                    reactiveVar.subscribe(function (x) {
                        switch (++count1) {
                            case 1:
                                x.should.be(-5);
                            case 2:
                                x.should.be(-10);
                            case _:
                                fail();
                                done();
                        }
                    });
                    reactiveVar.subscribe(function (x) {
                        switch (++count2) {
                            case 1:
                                x.should.be(-5);
                            case 2:
                                x.should.be(-10);
                            case _:
                                fail();
                                done();
                        }
                    });

                    reactiveVar.set(-5);
                    reactiveVar.set(-10);

                    wait(10, function () {
                        count1.should.be(2);
                        count2.should.be(2);
                        done();
                    });
                });

                it("should remove 1st-subscriber", function (done) {
                    var count2 = 0;

                    var reactiveVar = new ReactiveVar(10);
                    var unscribe1 = reactiveVar.subscribe(function (x) {
                        fail();
                        done();
                    });
                    reactiveVar.subscribe(function (x) {
                        count2++;
                        x.should.be(-5);
                    });

                    unscribe1();
                    reactiveVar.set(-5);

                    wait(10, function () {
                        count2.should.be(1);
                        done();
                    });
                });

                it("should remove all subscribers", function (done) {
                    var reactiveVar = new ReactiveVar(10);
                    var unscribe1 = reactiveVar.subscribe(function (x) {
                        fail();
                        done();
                    });
                    var unscribe2 = reactiveVar.subscribe(function (x) {
                        fail();
                        done();
                    });

                    unscribe1();
                    unscribe2();
                    reactiveVar.set(-5);

                    wait(10, done);
                });
            });

            describe("equaler", {
                describe("default equaler", {
                    it("should notify", function (done) {
                        var reactiveVar = new ReactiveVar(10);
                        reactiveVar.subscribe(function (x) {
                            x.should.be(11);
                            done();
                        });
                        reactiveVar.set(11);
                    });

                    it("should not notify", function (done) {
                        var reactiveVar = new ReactiveVar(10);
                        reactiveVar.subscribe(function (x) {
                            fail();
                            done();
                        });
                        reactiveVar.set(10);
                        wait(10, done);
                    });
                });

                describe("custom equaler", {
                    it("should call equaler", function (done) {
                        var called = false;

                        var reactiveVar = new ReactiveVar(10, function (a, b) {
                            called = true;
                            return a == b;
                        });
                        reactiveVar.set(10);

                        wait(10, function () {
                            called.should.be(true);
                            done();
                        });
                    });

                    it("should notify", function (done) {
                        var reactiveVar = new ReactiveVar(10, function (a, b) {
                            return false;
                        });
                        reactiveVar.subscribe(function (x) {
                            x.should.be(10);
                            done();
                        });
                        reactiveVar.set(10);
                    });

                    it("should not notify", function (done) {
                        var reactiveVar = new ReactiveVar(10, function (a, b) {
                            return true;
                        });
                        reactiveVar.subscribe(function (x) {
                            fail();
                            done();
                        });
                        reactiveVar.set(11);
                        wait(10, done);
                    });
                });
            });
        });
    }
}