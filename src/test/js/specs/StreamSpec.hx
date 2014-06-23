package specs;

import haxe.Timer;
import hxgnd.Error;
import hxgnd.Stream;
import hxmocha.Mocha;

class StreamSpec {
    @:describe
    public static function beforeState() {
        Mocha.it("pending", function () {
            var s = new Stream(function (_, _, _) {
                return function () { };
            });
            Mocha.expect(s.isPending).to.equal(true);
        });

        Mocha.it("isClosed", function () {
            var s = new Stream(function (_, _, _) {
                return function () { };
            });
            Mocha.expect(s.isClosed).to.equal(false);
        });
    }

    @:descripbe
    public static function update() {
        Mocha.it("then() - before update", function (done) {
            var s = new Stream(function (update, _, _) {
                Timer.delay(update.bind("updated"), 0);
                return function () { };
            });

            s.then(function (x) {
                Mocha.expect(x).to.equal("updated");
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(false);
                done();
            }, function () {
                Mocha.expectFail();
                done();
            }, function (e) {
                Mocha.expectFail();
                done();
            }, function () {
                Mocha.expectFail();
                done();
            });

            Mocha.expect(s.isPending).to.equal(true);
            Mocha.expect(s.isClosed).to.equal(false);
        });

        Mocha.it("then() - after update", function (done) {
            var s = new Stream(function (update, _, _) {
                update("updated");
                return function () { };
            });

            // does not call callback
            Timer.delay(function () {
                Mocha.expect(s.isPending).to.equal(false);
                Mocha.expect(s.isClosed).to.equal(false);
                s.then(function (x) {
                    Mocha.expectFail();
                    done();
                }, function () {
                    Mocha.expectFail();
                    done();
                }, function (e) {
                    Mocha.expectFail();
                    done();
                }, function () {
                    Mocha.expectFail();
                    done();
                });
                Timer.delay(function () done(), 0);
            }, 0);
        });

        //Mocha.it("thenClosed() - before closed", function (done) {
            //var s = new Stream(function (_, close, _) {
                //Timer.delay(close, 0);
                //return function () { };
            //});
//
            //s.then(function (x) {
                //Mocha.expect(x).to.equal("updated");
                //Mocha.expect(s.isPending).to.equal(false);
                //Mocha.expect(s.isClosed).to.equal(false);
                //done();
            //}, function (e) {
                //Mocha.expectFail();
                //done();
            //});
//
            //Mocha.expect(s.isPending).to.equal(true);
            //Mocha.expect(s.isClosed).to.equal(false);
        //});

        // thenerror

        // thenfinally
    }
}