package specs;

import hxgnd.Error;
import hxgnd.PromiseBroker;
import hxmocha.Mocha;

class PromiseBrokerSpec {
    @:describe
    public static function promise(): Void {
        Mocha.it("fulfill", function (done) {
            var brocker = new PromiseBroker();

            Mocha.expect(brocker.promise.isPending).to.equal(true);
            brocker.fulfill("fulfill");
            brocker.promise.then(function (x) {
                Mocha.expect(x).to.equal("fulfill");
                Mocha.expect(brocker.promise.isPending).to.equal(false);
                done();
            });
        });

        Mocha.it("reject", function (done) {
            var brocker = new PromiseBroker();

            Mocha.expect(brocker.promise.isPending).to.equal(true);
            brocker.reject(new Error("my error"));
            brocker.promise.thenError(function (e) {
                Mocha.expect(e.message).to.equal("my error");
                Mocha.expect(brocker.promise.isPending).to.equal(false);
                done();
            });
        });

        Mocha.it("cancel", function (done) {
            var brocker = new PromiseBroker();

            Mocha.expect(brocker.promise.isPending).to.equal(true);
            brocker.cancel();
            brocker.promise.thenError(function (e) {
                Mocha.expect(e.message).to.equal("Canceled");
                Mocha.expect(brocker.promise.isPending).to.equal(false);
                done();
            });
        });

        Mocha.it("onCancel", function (done) {
            var called = false;

            var brocker = new PromiseBroker(function (ctx) {
                called = true;
            });

            Mocha.expect(brocker.promise.isPending).to.equal(true);
            brocker.cancel();
            brocker.promise.thenError(function (e) {
                Mocha.expect(called).to.equal(true);
                Mocha.expect(brocker.promise.isPending).to.equal(false);
                done();
            });
        });
    }
}