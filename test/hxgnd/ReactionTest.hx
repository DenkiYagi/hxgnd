package hxgnd;

import buddy.BuddySuite;
using buddy.Should;
import TestTools.wait;

class ReactionTest extends BuddySuite {
    public function new() {
        describe("Reaction#new() + #subscribe()", {
            it("should pass", {
                var publisher = new Publisher();
                var reaction = new Reaction(publisher, function (emit, x) emit(x));

                var buff = [];
                reaction.subscribe(function (x) {
                    buff.push(x);
                });

                publisher.publish(1);
                publisher.publish(2);
                publisher.publish(3);
                publisher.publish(4);
                buff.should.containExactly([1, 2, 3, 4]);
            });

            it("should collect", {
                var publisher = new Publisher();
                var reaction = new Reaction(publisher, function (emit, x) if ((x % 2) == 0) emit(x * 10));

                var buff = [];
                reaction.subscribe(function (x) {
                    buff.push(x);
                });

                publisher.publish(1);
                publisher.publish(2);
                publisher.publish(3);
                publisher.publish(4);
                publisher.publish(5);
                buff.should.containExactly([20, 40]);
            });
        });

        describe("Reaction#map()", {
            it("should apply mapper", {
                var publisher = new Publisher();
                var reaction = new Reaction(publisher, function (emit, x) emit(x));

                var buff = [];
                reaction.map(function (x) return x * 10).subscribe(function (x) {
                    buff.push(x);
                });

                publisher.publish(1);
                publisher.publish(2);
                publisher.publish(3);
                publisher.publish(4);
                buff.should.containExactly([10, 20, 30, 40]);
            });

            it("should not call subscriber when it is disposed", {
                var publisher = new Publisher();
                var parent = new Reaction(publisher, function (emit, x) emit(x));

                var child = parent.map(function (x) return x * 10);
                child.subscribe(function (_) fail());
                child.dispose();
                child.isDisposed.should.be(true);

                publisher.publish(1);
            });
        });

        describe("Reaction#dispose()", {
            it("should change true after it is disposed", {
                var reaction = new Reaction({
                    subscribe: function (fn) {
                        return function () {}
                    }
                }, function (emit, x) {});

                reaction.isDisposed.should.be(false);
                reaction.dispose();
                reaction.isDisposed.should.be(true);
            });

            it("should call an unsubscribe function", function (done) {
                var reaction = new Reaction({
                    subscribe: function (fn) {
                        return function () done();
                    }
                }, function (emit, x) {});

                reaction.dispose();
            });

            it("should dispose all children when it is disposed", {
                var parent = new Reaction({
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
                var reaction = new Reaction({
                    subscribe: function (fn) {
                        send = fn;
                        return function () {}
                    },
                }, function (emit, x) {});

                reaction.subscribe(function (_) fail());
                reaction.dispose();
                send(10);

                wait(10, done);
            });
        });
    }
}

private class Publisher<T> {
    var delegate: Delegate<T>;

    public function new() {
        delegate = new Delegate();
    }

    public function publish(x: T) {
        delegate.invoke(x);
    }

    public function subscribe(fn: T -> Void): Void -> Void {
        delegate.add(fn);
        return delegate.remove.bind(fn);
    }
}