package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using buddy.Should;

class ReactiveStreamTest extends BuddySuite {
    public function new() {
        describe("ReactiveStream.create()", {
            describe("idle", {

            });

            describe("running", {

            });

            describe("paused", {

            });

            describe("closed", {

            });

            describe("failed", {

            });
        });

        describe("ReactiveStream.never()", {
            describe("subscribe()", {
                it("should not call", function (done) {
                    var called = false;
                    ReactiveStream.never().subscribe(function (_) {
                        called = true;
                    });
                    wait(10, function () {
                        called.should.be(false);
                        done();
                    });
                });
            });

            describe("subscribeEnd()", {
                it("should not call", function (done) {
                    var called = false;
                    ReactiveStream.never().subscribeEnd(function () {
                        called = true;
                    });
                    wait(10, function () {
                        called.should.be(false);
                        done();
                    });
                });
            });

            describe("subscribeError()", {
                it("should not call", function (done) {
                    var called = false;
                    ReactiveStream.never().subscribeError(function (_) {
                        called = true;
                    });
                    wait(10, function () {
                        called.should.be(false);
                        done();
                    });
                });
            });

            describe("tryCatch()", {
            });

            describe("finally()", {
                it("should not call", function (done) {
                    var called = false;
                    ReactiveStream.never().finally(function () {
                        called = true;
                    });
                    wait(10, function () {
                        called.should.be(false);
                        done();
                    });
                });
            });

            describe("close()", {
                it("should pass", function (done) {
                    ReactiveStream.never().close();
                    wait(10, done);
                });

                it("should notify end when it subscribe before close()", function (done) {
                    var called = false;
                    var stream = ReactiveStream.never();
                    stream.subscribeEnd(function () {
                        called = true;
                    });
                    stream.close();
                    wait(10, function () {
                        called.should.be(true);
                        done();
                    });
                });

                it("should notify end when it subscribe after close()", function (done) {
                    var called = false;
                    var stream = ReactiveStream.never();
                    stream.close();

                    stream.subscribeEnd(function () {
                        called = true;
                    });
                    wait(10, function () {
                        called.should.be(true);
                        done();
                    });
                });
            });
        });

        describe("ReactiveStream.empty()", {
            // closed
        });

        describe("ReactiveStream.fail()", {
            // failed
        });

        describe("ReactiveStream.new()", {
            it("should pass", {
                ReactiveStream.empty();
            });
        });
    }
}