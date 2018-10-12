package hxgnd;

import buddy.BuddySuite;
using buddy.Should;

class ReactiveStreamTest extends BuddySuite {
    public function new() {
        describe("ReactiveStream.new()", {
            it("should pass", {
                ReactiveStream.empty();
            });
        });
    }
}