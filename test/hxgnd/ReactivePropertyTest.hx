package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using buddy.Should;

class ReactivePropertyTest extends BuddySuite {
    public function new() {
        timeoutMs = 100;

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
                    });
                    property.get();
                    wait(5, done);
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
                        }
                    });

                    property.set(-5);
                    property.set(-10);

                    wait(5, function () {
                        count.should.be(2);
                        done();
                    });
                });
            });

            describe("multi subscribers", {
                it("should not call all subscribers", function (done) {
                    var property = new ReactiveProperty(10);
                    property.subscribe(function (x) {
                        fail();
                    });
                    property.subscribe(function (x) {
                        fail();
                    });
                    property.get();
                    wait(5, done);
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

                    wait(5, function () {
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
                        }
                    });

                    property.set(-5);
                    property.set(-10);

                    wait(5, function () {
                        count1.should.be(2);
                        count2.should.be(2);
                        done();
                    });
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
                        });
                        property.set(10);
                        wait(5, done);
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

                        wait(5, function () {
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
                        });
                        property.set(11);
                        wait(5, done);
                    });
                });
            });
        });

        describe("ReactiveProperty#unsubscribe()", {
            it("should not call subscriber", function (done) {
                var property = new ReactiveProperty(10);
                function f(x) fail();
                property.subscribe(f);
                property.unsubscribe(f);
                property.set(-5);
                wait(5, done);
            });

            it("should not call 1st-subscriber", function (done) {
                var count2 = 0;

                var property = new ReactiveProperty(10);
                function f1(x: Int) fail();
                function f2(x: Int) {
                    count2++;
                    x.should.be(-5);
                }

                property.subscribe(f1);
                property.subscribe(f2);

                property.unsubscribe(f1);
                property.set(-5);

                wait(5, function () {
                    count2.should.be(1);
                    done();
                });
            });

            it("should remove all subscribers", function (done) {
                var property = new ReactiveProperty(10);
                function f1(x) fail();
                function f2(x) fail();

                property.subscribe(f1);
                property.subscribe(f2);

                property.unsubscribe(f1);
                property.unsubscribe(f2);
                property.set(-5);

                wait(5, done);
            });

            it("should pass when it is called 2-times", {
                var property = new ReactiveProperty(10);
                function f(x) {}

                property.subscribe(f);

                property.unsubscribe(f);
                property.unsubscribe(f);
            });
        });
    }
}