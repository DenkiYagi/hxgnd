package hxgnd;

import utest.Assert;
import hxgnd.Stream;
import haxe.Timer;

class StreamTest {
    public function new() {}

    public function test_already_ended() {
        var stream = new Stream(function (ctx) {
            ctx.emit(End);
            Assert.pass();
        });
        
        var count = 0;
        stream.subscribe(function (value) {
            Assert.isTrue(count <= 0);
            Assert.same(End, value);
            Assert.isFalse(stream.isActive);
            count++;
        });

        Assert.isTrue(stream.isActive);
    }

    public function test_duplicated_end() {
        var stream = new Stream(function (ctx) {
            ctx.emit(End);
            ctx.emit(End);
            Assert.pass();
        });

        var count = 0;
        stream.subscribe(function (value) {
            Assert.isTrue(count <= 0);
            Assert.same(End, value);
            Assert.isFalse(stream.isActive);
            count++;
        });
        
        Assert.isTrue(stream.isActive);
    }

    public function test_subscribe_end() {
        var done = Assert.createAsync();

        var killTimer = Timer.delay(function () {
            Assert.fail();
            done();
        }, 100);

        var stream = new Stream(function (ctx) {
            Timer.delay(function () {
                ctx.emit(End);
            }, 10);
        });
        stream.subscribe(function (value) {
            Assert.same(End, value);
            Assert.isFalse(stream.isActive);
            done();
            killTimer.stop();
        });
        Assert.isTrue(stream.isActive);
        
        initTimerLoop();
    }

    public function test_subscribe_duplicated_end() {
        var done = Assert.createAsync();

        var stream = new Stream(function (ctx) {
            Timer.delay(ctx.emit.bind(End), 10);
            Timer.delay(ctx.emit.bind(End), 20);
        });

        // do not call End twice.
        var count = 0;
        Timer.delay(function () {
            Assert.equals(1, count);
            Assert.isFalse(stream.isActive);
            done();
        }, 30);

        stream.subscribe(function (value) {
            Assert.same(End, value);
            Assert.isFalse(stream.isActive);
            count++;
        });
        Assert.isTrue(stream.isActive);
        
        initTimerLoop();
    }

    public function test_subscribe_one_value() {
        var done = Assert.createAsync();

        var killTimer = Timer.delay(function () {
            Assert.fail();
            done();
        }, 100);

        var count = 0;
        var stream = new Stream(function (ctx) {
            Timer.delay(function () {
                count++;
                ctx.emit(Data(1));
            }, 10);

            Timer.delay(function () {
                count++;
                ctx.emit(End);
            }, 20);
        });

        stream.subscribe(function (value) {
            switch (count) {
                case 1:
                    Assert.same(Data(1), value);
                    Assert.isTrue(stream.isActive);
                case 2:
                    Assert.same(End, value);
                    Assert.isFalse(stream.isActive);
                    done();
                    killTimer.stop();
                case _:
                    Assert.fail();
                    done();
                    killTimer.stop();
            }
        });
        Assert.isTrue(stream.isActive);

        initTimerLoop();
    }

    public function test_subscribe_two_values() {
        var done = Assert.createAsync();

        var killTimer = Timer.delay(function () {
            Assert.fail();
            done();
        }, 100);

        var count = 0;
        var stream = new Stream(function (ctx) {
            Timer.delay(function () {
                count++;
                ctx.emit(Data(1));
            }, 10);
            Timer.delay(function () {
                count++;
                ctx.emit(Data(2));
            }, 20);
            Timer.delay(function () {
                count++;
                ctx.emit(End);
            }, 30);
        });

        stream.subscribe(function (value) {
            switch (count) {
                case 1:
                    Assert.same(Data(1), value);
                    Assert.isTrue(stream.isActive);
                case 2:
                    Assert.same(Data(2), value);
                    Assert.isTrue(stream.isActive);
                case 3:
                    Assert.same(End, value);
                    Assert.isFalse(stream.isActive);
                    done();
                    killTimer.stop();
                case _:
                    Assert.fail();
                    done();
                    killTimer.stop();
            }
        });
        Assert.isTrue(stream.isActive);

        initTimerLoop();
    }

    public function test_two_subscribers() {
        var done = Assert.createAsync();

        var killTimer = Timer.delay(function () {
            Assert.fail();
            done();
        }, 100);

        var count = 0;
        var stream = new Stream(function (ctx) {
            Timer.delay(function () {
                count++;
                ctx.emit(Data(1));
            }, 10);
            Timer.delay(function () {
                count++;
                ctx.emit(End);
            }, 20);
        });

        stream.subscribe(function (value) {
            switch (count) {
                case 1:
                    Assert.same(Data(1), value);
                    Assert.isTrue(stream.isActive);
                case 2:
                    Assert.same(End, value);
                    Assert.isFalse(stream.isActive);
                case _:
                    Assert.fail();
                    killTimer.stop();
                    done();
            }
        });

        stream.subscribe(function (value) {
            switch (count) {
                case 1:
                    Assert.same(Data(1), value);
                    Assert.isTrue(stream.isActive);
                case 2:
                    Assert.same(End, value);
                    Assert.isFalse(stream.isActive);
                    killTimer.stop();
                    done();
                case _:
                    Assert.fail();
                    killTimer.stop();
                    done();
            }
        });

        Assert.isTrue(stream.isActive);

        initTimerLoop();
    }

    inline function initTimerLoop() {
        // for haxe.Timer
        #if neko
        haxe.EntryPoint.run();
        #end
    }
}