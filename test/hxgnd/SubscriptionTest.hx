package hxgnd;

import buddy.BuddySuite;
using buddy.Should;
import TestTools.wait;

class SubscriptionTest extends BuddySuite {
    public function new() {
        describe("Subscription#subscribe()", {

        });

        describe("Subscription#map()", {

        });

        describe("Subscription#dispose()", {
            it("should change true after it is disposed", {
                var subscription = new Subscription({
                    subscribe: function (fn) {
                        return function () {}
                    }
                }, function (emit, x) {});

                subscription.isDisposed.should.be(false);
                subscription.dispose();
                subscription.isDisposed.should.be(true);
            });

            it("should call an unsubscribe function", function (done) {
                var subscription = new Subscription({
                    subscribe: function (fn) {
                        return function () done();
                    }
                }, function (emit, x) {});

                subscription.dispose();
            });

            it("should dispose all children when it is disposed", {
                var parent = new Subscription({
                    subscribe: function (fn) {
                        return function () {}
                    },
                }, function (emit, x) {});

                var child1 = parent.map(function (x) return x);
                child1.subscribe(function (_) fail());

                var child2 = parent.map(function (x) return x);
                child2.subscribe(function (_) fail());

                parent.dispose();
                child1.isDisposed.should.be(true);
                child2.isDisposed.should.be(true);
            });

            it("should not send a message", function (done) {
                var send: Int -> Void;
                var subscription = new Subscription({
                    subscribe: function (fn) {
                        send = fn;
                        return function () {}
                    },
                }, function (emit, x) {});

                subscription.subscribe(function (_) fail());
                subscription.dispose();
                send(10);

                wait(10, done);
            });
        });
    }
}