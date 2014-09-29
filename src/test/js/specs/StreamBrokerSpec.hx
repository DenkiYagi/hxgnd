package specs;

import hxgnd.Error;
import hxgnd.StreamBroker;
import hxmocha.Mocha;

class StreamBrokerSpec {
    @:describe
    public static function stream(): Void {
        Mocha.it("update", function (done) {
            var brocker = new StreamBroker();

            Mocha.expect(brocker.stream.isPending).to.equal(true);
            brocker.update("update");
            brocker.stream.then(function (x) {
                Mocha.expect(x).to.equal("update");
                Mocha.expect(brocker.stream.isPending).to.equal(false);
                done();
            });
        });

        Mocha.it("close", function (done) {
            var brocker = new StreamBroker();

            Mocha.expect(brocker.stream.isPending).to.equal(true);
            brocker.close();
            brocker.stream.thenClosed(function () {
                Mocha.expect(brocker.stream.isPending).to.equal(false);
                done();
            });
        });

        Mocha.it("reject", function (done) {
            var brocker = new StreamBroker();

            Mocha.expect(brocker.stream.isPending).to.equal(true);
            brocker.fail(new Error("my error"));
            brocker.stream.thenError(function (e) {
                Mocha.expect(e.message).to.equal("my error");
                Mocha.expect(brocker.stream.isPending).to.equal(false);
                done();
            });
        });

        Mocha.it("cancel", function (done) {
            var brocker = new StreamBroker();

            Mocha.expect(brocker.stream.isPending).to.equal(true);
            brocker.cancel();
            brocker.stream.thenError(function (e) {
                Mocha.expect(e.message).to.equal("Canceled");
                Mocha.expect(brocker.stream.isPending).to.equal(false);
                done();
            });
        });

        Mocha.it("onCancel", function (done) {
            var called = false;

            var brocker = new StreamBroker();
            brocker.onCancel = function (ctx) {
                called = true;
            };

            Mocha.expect(brocker.stream.isPending).to.equal(true);
            brocker.cancel();
            brocker.stream.thenError(function (e) {
                Mocha.expect(called).to.equal(true);
                Mocha.expect(brocker.stream.isPending).to.equal(false);
                done();
            });
        });
    }
}