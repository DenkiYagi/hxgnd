package hxgnd;

import utest.Assert;
import hxgnd.Stream;
import haxe.Timer;

class StreamTest {
    public function new() {}

    public function test_already_ended() {
        var stream = new Stream(function (callback) {
            callback(End);
            Assert.pass();
        });
        stream.subscribe(function (_) {
            Assert.fail();
        });
    }

    public function test_duplicate_end() {
        var stream = new Stream(function (callback) {
            callback(End);
            callback(End);
            Assert.pass();
        });
        stream.subscribe(function (_) {
            Assert.fail();
        });
    }

    public function test_subscribe_end() {
        var done = Assert.createAsync();

        var killTimer = Timer.delay(function () {
            Assert.fail();
            done();
        }, 100);

        var stream = new Stream(function (callback) {
            Timer.delay(function () {
                callback(End);
            }, 10);
        });
        stream.subscribe(function (value) {
            Assert.same(End, value);
            done();
            killTimer.stop();
        });
        
        initTimerLoop();
    }

    public function test_subscribe_one_value() {
        var done = Assert.createAsync();

        var killTimer = Timer.delay(function () {
            Assert.fail();
            done();
        }, 100);

        var count = 0;
        var stream = new Stream(function (callback) {
            Timer.delay(function () {
                count++;
                callback(Some(1));
            }, 10);

            Timer.delay(function () {
                count++;
                callback(End);
            }, 20);
        });

        stream.subscribe(function (value) {
            switch (count) {
                case 1:
                    Assert.same(Some(1), value);
                case 2:
                    Assert.same(End, value);
                    done();
                    killTimer.stop();
                case _:
                    Assert.fail();
                    done();
                    killTimer.stop();
            }
        });

        initTimerLoop();
    }

    public function test_subscribe_two_values() {
        var done = Assert.createAsync();

        var killTimer = Timer.delay(function () {
            Assert.fail();
            done();
        }, 100);

        var count = 0;
        var stream = new Stream(function (callback) {
            Timer.delay(function () {
                count++;
                callback(Some(1));
            }, 10);
            Timer.delay(function () {
                count++;
                callback(Some(2));
            }, 20);
            Timer.delay(function () {
                count++;
                callback(End);
            }, 30);
        });

        stream.subscribe(function (value) {
            switch (count) {
                case 1:
                    Assert.same(Some(1), value);
                case 2:
                    Assert.same(Some(2), value);
                case 3:
                    Assert.same(End, value);
                    done();
                    killTimer.stop();
                case _:
                    Assert.fail();
                    done();
                    killTimer.stop();
            }
        });
    }

    public function test_two_subscribers() {
        var done = Assert.createAsync();

        var killTimer = Timer.delay(function () {
            Assert.fail();
            done();
        }, 100);

        var count = 0;
        var stream = new Stream(function (callback) {
            Timer.delay(function () {
                count++;
                callback(Some(1));
            }, 10);
            Timer.delay(function () {
                count++;
                callback(End);
            }, 20);
        });

        stream.subscribe(function (value) {
            switch (count) {
                case 1:
                    Assert.same(Some(1), value);
                case 2:
                    Assert.same(End, value);
                case _:
                    Assert.fail();
                    killTimer.stop();
                    done();
            }
        });

        stream.subscribe(function (value) {
            switch (count) {
                case 1:
                    Assert.same(Some(1), value);
                case 2:
                    Assert.same(End, value);
                    killTimer.stop();
                    done();
                case _:
                    Assert.fail();
                    killTimer.stop();
                    done();
            }
        });

        initTimerLoop();
    }

    inline function initTimerLoop() {
        // for haxe.Timer
        #if neko
        haxe.EntryPoint.run();
        #end
    }
}