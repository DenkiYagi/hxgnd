package hxgnd;

import buddy.BuddySuite;
using buddy.Should;

class ReactiveStreamTest extends BuddySuite {
    public function new() {
        describe("ReactiveStream.new()", {
            it("should pass", {
                new hxgnd.ReactiveStream(function (ctx) {

                    return {
                        attach: function (fn) {},
                        detach: function (fn) {},
                        close: function () {}
                    }
                });
            });
        });
    }
}