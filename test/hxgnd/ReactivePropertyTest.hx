package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using buddy.Should;

class ReactivePropertyTest extends BuddySuite {
    public function new() {
        describe("ReactiveProperty#new()", {
            it("should pass", {
                new ReactiveProperty(10);
            });
        });

        describe("ReactiveProperty#get()", {
            it("should pass", {
                var property = new ReactiveProperty(10);
                property.get().should.be(10);
            });
        });

        describe("ReactiveProperty#set()", {
            it("should pass", {
                var property = new ReactiveProperty(10);
                property.set(-5);
                property.get().should.be(-5);
            });
        });

        describe("ReactiveProperty#subscribe()", {
            describe("single subscriber", {
                it("should not call subscriber", function (done) {
                    var property = new ReactiveProperty(10);
                    property.subscribe(function (x) {
                        fail();
                        done();
                    });
                    property.get();
                    wait(10, done);
                });

                it("should call subscriber 1-time", function (done) {
                    var count = 0;

                    var property = new ReactiveProperty(10);
                    property.subscribe(function (x) {
                        count++;
                        x.should.be(-5);
                        count.should.be(1);
                        done();
                    });
                    property.set(-5);
                });

                it("should call subscriber 2-times", function (done) {
                    var count = 0;

                    var property = new ReactiveProperty(10);
                    property.subscribe(function (x) {
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

                    property.set(-5);
                    property.set(-10);

                    wait(10, function () {
                        count.should.be(2);
                        done();
                    });
                });

                it("should remove subscriber", function (done) {
                    var property = new ReactiveProperty(10);
                    var unscribe = property.subscribe(function (x) {
                        fail();
                        done();
                    });
                    unscribe();
                    property.set(-5);
                    wait(10, done);
                });
            });

            describe("multi subscribers", {
                it("should not call all subscribers", function (done) {
                    var property = new ReactiveProperty(10);
                    property.subscribe(function (x) {
                        fail();
                        done();
                    });
                    property.subscribe(function (x) {
                        fail();
                        done();
                    });
                    property.get();
                    wait(10, done);
                });

                it("should call all subscribers 1-time", function (done) {
                    var count1 = 0;
                    var count2 = 0;

                    var property = new ReactiveProperty(10);
                    property.subscribe(function (x) {
                        x.should.be(-5);
                        count1++;
                    });
                    property.subscribe(function (x) {
                        x.should.be(-5);
                        count2++;
                    });
                    property.set(-5);

                    wait(10, function () {
                        count1.should.be(1);
                        count2.should.be(1);
                        done();
                    });
                });

                it("should call subscriber 2-times", function (done) {
                    var count1 = 0;
                    var count2 = 0;

                    var property = new ReactiveProperty(10);
                    property.subscribe(function (x) {
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
                    property.subscribe(function (x) {
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

                    property.set(-5);
                    property.set(-10);

                    wait(10, function () {
                        count1.should.be(2);
                        count2.should.be(2);
                        done();
                    });
                });

                it("should remove 1st-subscriber", function (done) {
                    var count2 = 0;

                    var property = new ReactiveProperty(10);
                    var unscribe1 = property.subscribe(function (x) {
                        fail();
                        done();
                    });
                    property.subscribe(function (x) {
                        count2++;
                        x.should.be(-5);
                    });

                    unscribe1();
                    property.set(-5);

                    wait(10, function () {
                        count2.should.be(1);
                        done();
                    });
                });

                it("should remove all subscribers", function (done) {
                    var property = new ReactiveProperty(10);
                    var unscribe1 = property.subscribe(function (x) {
                        fail();
                        done();
                    });
                    var unscribe2 = property.subscribe(function (x) {
                        fail();
                        done();
                    });

                    unscribe1();
                    unscribe2();
                    property.set(-5);

                    wait(10, done);
                });
            });

            describe("equaler", {
                describe("default equaler", {
                    it("should notify", function (done) {
                        var property = new ReactiveProperty(10);
                        property.subscribe(function (x) {
                            x.should.be(11);
                            done();
                        });
                        property.set(11);
                    });

                    it("should not notify", function (done) {
                        var property = new ReactiveProperty(10);
                        property.subscribe(function (x) {
                            fail();
                            done();
                        });
                        property.set(10);
                        wait(10, done);
                    });
                });

                describe("custom equaler", {
                    it("should call equaler", function (done) {
                        var called = false;

                        var property = new ReactiveProperty(10, function (a, b) {
                            called = true;
                            return a == b;
                        });
                        property.set(10);

                        wait(10, function () {
                            called.should.be(true);
                            done();
                        });
                    });

                    it("should notify", function (done) {
                        var property = new ReactiveProperty(10, function (a, b) {
                            return false;
                        });
                        property.subscribe(function (x) {
                            x.should.be(10);
                            done();
                        });
                        property.set(10);
                    });

                    it("should not notify", function (done) {
                        var property = new ReactiveProperty(10, function (a, b) {
                            return true;
                        });
                        property.subscribe(function (x) {
                            fail();
                            done();
                        });
                        property.set(11);
                        wait(10, done);
                    });
                });
            });

            describe("unsubscribe()", {
                it("should pass when it is called 2-times", {
                    var property = new ReactiveProperty(10);
                    var unscribe = property.subscribe(function (x) {});
                    unscribe();
                    unscribe();
                });
            });
        });
    }
}