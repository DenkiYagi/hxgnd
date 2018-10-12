package hxgnd;

import buddy.BuddySuite;
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
            // idle
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