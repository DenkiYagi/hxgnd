package hxgnd;

import buddy.BuddySuite;
import TestTools.wait;
using buddy.Should;

import hxgnd.Stream;
import hxgnd.Result;
using hxgnd.LangTools;

class StreamTest extends BuddySuite {
    public function new() {
        describe("Stream is Abortable", {
            it("should can compile", {
                var stream: Abortable = Stream.apply(function (ctx) {
                    ctx.emit(End);
                });
            });
        });

        describe("Stream.new()", {
            timeoutMs = 1000;

            it("should emit Error", function (done) {
                var stream = Stream.apply(function (ctx) {
                    throw "error";
                });
                #if js
                stream.subscribe(function (e) {
                    e.same(Error("error")).should.be(true);
                    stream.isActive.should.be(false);
                    done();
                });
                #else
                wait(10, function () {
                    stream.isActive.should.be(false);
                    done();
                });
                #end
            });
        });

        describe("Stream.subscribe()", {
            timeoutMs = 1000;

            #if js
            it("should invoke middleware defer", function (done) {
                var stream = Stream.apply(function (ctx) {
                    ctx.emit(End);
                });

                var count = 0;
                stream.subscribe(function (e) {
                    e.same(End).should.be(true);
                    stream.isActive.should.be(false);
                    count++;
                });
                stream.isActive.should.be(true);

                wait(5, function () {
                    count.should.be(1);
                    done();
                });
            });
            #end

            it("should wait delayed End", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(End);
                    });
                });

                var count = 0;
                stream.subscribe(function (e) {
                    e.same(End).should.be(true);
                    stream.isActive.should.be(false);
                    count++;
                });
                stream.isActive.should.be(true);

                wait(10, function () {
                    count.should.be(1);
                    done();
                });
            });

            it("should notify single End when executor emits End 2-times", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(End);
                        ctx.emit(End);
                    });
                });

                var count = 0;
                stream.subscribe(function (e) {
                    e.same(End).should.be(true);
                    stream.isActive.should.be(false);
                    count++;
                });
                #if !neko
                stream.isActive.should.be(true);
                #end

                wait(10, function () {
                    count.should.be(1);
                    done();
                });
            });

            it("should subscribe 1 Data and End", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(Data(1));
                    });
                    wait(10, function () {
                        ctx.emit(End);
                    });
                });

                var count = 0;
                stream.subscribe(function (e) {
                    switch (count) {
                        case 0:
                            e.same(Data(1)).should.be(true);
                            stream.isActive.should.be(true);
                            count++;
                        case 1:
                            e.same(End).should.be(true);
                            stream.isActive.should.be(false);
                            count++;
                        case _:
                            fail();
                    }
                });
                stream.isActive.should.be(true);

                wait(15, function () {
                    count.should.be(2);
                    done();
                });
            });

            it("should notify single End when executor emits End and Data", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(End);
                        ctx.emit(Data(1));
                    });
                });

                var count = 0;
                stream.subscribe(function (e) {
                    e.same(End).should.be(true);
                    stream.isActive.should.be(false);
                    count++;
                });
                #if !neko
                stream.isActive.should.be(true);
                #end

                wait(10, function () {
                    count.should.be(1);
                    done();
                });
            });

            it("should notify single End when executor emits End and Error", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(End);
                        ctx.emit(Error("error"));
                    });
                });

                var count = 0;
                stream.subscribe(function (e) {
                    e.same(End).should.be(true);
                    stream.isActive.should.be(false);
                    count++;
                });
                #if !neko
                stream.isActive.should.be(true);
                #end

                wait(10, function () {
                    count.should.be(1);
                    done();
                });
            });

            it("should notify single Error when executor emits Error and End", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(Error("error"));
                        ctx.emit(End);
                    });
                });

                var count = 0;
                stream.subscribe(function (e) {
                    e.same(Error("error")).should.be(true);
                    stream.isActive.should.be(false);
                    count++;
                });
                #if !neko
                stream.isActive.should.be(true);
                #end

                wait(10, function () {
                    count.should.be(1);
                    done();
                });
            });

            it("should notify single End when executor emits Error and Data", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(Error("error"));
                        ctx.emit(Data(1));
                    });
                });

                var count = 0;
                stream.subscribe(function (e) {
                    e.same(Error("error")).should.be(true);
                    stream.isActive.should.be(false);
                    count++;
                });
                #if !neko
                stream.isActive.should.be(true);
                #end

                wait(10, function () {
                    count.should.be(1);
                    done();
                });
            });

            it("should notify single Error when executor emits Error 2-times", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(Error("error"));
                        ctx.emit(Error("error2"));
                    });
                });

                var count = 0;
                stream.subscribe(function (e) {
                    e.same(Error("error")).should.be(true);
                    stream.isActive.should.be(false);
                    count++;
                });
                #if !neko
                stream.isActive.should.be(true);
                #end

                wait(10, function () {
                    count.should.be(1);
                    done();
                });
            });

            it("should subscribe 1 Data and Error", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(Data(1));
                    });
                    wait(10, function () {
                        ctx.emit(Error("error"));
                    });
                });

                var count = 0;
                stream.subscribe(function (e) {
                    switch (count) {
                        case 0:
                            e.same(Data(1)).should.be(true);
                            stream.isActive.should.be(true);
                            count++;
                        case 1:
                            e.same(Error("error")).should.be(true);
                            stream.isActive.should.be(false);
                            count++;
                        case _:
                            fail();
                    }
                });
                stream.isActive.should.be(true);

                wait(15, function () {
                    count.should.be(2);
                    done();
                });
            });

            it("should subscribe 2 Data and End", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(Data(1));
                    });
                    wait(10, function () {
                        ctx.emit(Data(2));
                    });
                    wait(15, function () {
                        ctx.emit(End);
                    });
                });

                var count = 0;
                stream.subscribe(function (e) {
                    switch (count) {
                        case 0:
                            e.same(Data(1)).should.be(true);
                            stream.isActive.should.be(true);
                            count++;
                        case 1:
                            e.same(Data(2)).should.be(true);
                            stream.isActive.should.be(true);
                            count++;
                        case 2:
                            e.same(End).should.be(true);
                            stream.isActive.should.be(false);
                            count++;
                        case _:
                            fail();
                    }
                });
                stream.isActive.should.be(true);

                wait(20, function () {
                    count.should.be(3);
                    done();
                });
            });

            it("should notify to 2 subscribers", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(Data(1));
                    });
                    wait(10, function () {
                        ctx.emit(Data(2));
                    });
                    wait(15, function () {
                        ctx.emit(End);
                    });
                });

                var count1 = 0;
                stream.subscribe(function (e) {
                    switch (count1) {
                        case 0:
                            e.same(Data(1)).should.be(true);
                            stream.isActive.should.be(true);
                            count1++;
                        case 1:
                            e.same(Data(2)).should.be(true);
                            stream.isActive.should.be(true);
                            count1++;
                        case 2:
                            e.same(End).should.be(true);
                            stream.isActive.should.be(false);
                            count1++;
                        case _:
                            fail();
                    }
                });
                stream.isActive.should.be(true);

                var count2 = 0;
                stream.subscribe(function (e) {
                    switch (count2) {
                        case 0:
                            e.same(Data(1)).should.be(true);
                            stream.isActive.should.be(true);
                            count2++;
                        case 1:
                            e.same(Data(2)).should.be(true);
                            stream.isActive.should.be(true);
                            count2++;
                        case 2:
                            e.same(End).should.be(true);
                            stream.isActive.should.be(false);
                            count2++;
                        case _:
                            fail();
                    }
                });
                stream.isActive.should.be(true);

                wait(20, function () {
                    count1.should.be(3);
                    count2.should.be(3);
                    done();
                });
            });
        });

        describe("Stream.unsubscribe()", {
            timeoutMs = 1000;

            it("should not subscribe", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, function () {
                        ctx.emit(End);
                    });
                });

                function handler(e) {
                    fail();
                }

                stream.subscribe(handler);
                stream.unsubscribe(handler);

                wait(10, function () {
                    stream.isActive.should.be(false);
                    done();
                });
            });
        });

        describe("Stream.abort()", {
            timeoutMs = 1000;

            it("should abort event loop", function (done) {
                var stream = Stream.apply(function (ctx) {
                    var i = 0;
                    function loop() {
                        ctx.emit(Data(i++));
                        wait(5, function () loop());
                    }
                    loop();
                });

                wait(10, function () {
                    stream.isActive.should.be(true);
                    stream.subscribe(function (e) {
                        switch (e) {
                            case Error(e): done();
                            case _:
                        }
                    });
                    stream.abort();
                });
            });

            it("should call onAbort", function (done) {
                var isCalled = false;

                var stream = Stream.apply(function (ctx) {
                    ctx.onAbort = function () {
                        isCalled = true;
                    }

                    function loop() {
                        wait(5, function () loop());
                    }
                    loop();
                });

                wait(5, function () {
                    stream.isActive.should.be(true);
                    stream.subscribe(function (e) {
                        switch (e) {
                            case Error(e):
                                isCalled.should.be(true);
                                done();
                            case _:
                        }
                    });
                    stream.abort();
                });
            });
        });

        describe("Stream.end", {
            it("should be singleton", {
                var stream = Stream.apply(function (ctx) {
                });
                var end = stream.end;
                (end == stream.end).should.be(true);
            });

            it("should subscribe End", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, ctx.emit.bind(End));
                });
                stream.end.then(function (result) {
                    result.same(Success(new Unit())).should.be(true);
                    done();
                });
            });

            it("should subscribe Error", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, ctx.emit.bind(Error("error")));
                });
                stream.end.then(function (result) {
                    switch (result) {
                        case Failure(e):
                            LangTools.same(e, "error").should.be(true);
                            done();
                        case _:
                            fail();
                            done();
                    }
                });
            });

            it("should not subscribe Data", function (done) {
                var stream = Stream.apply(function (ctx) {
                    wait(5, ctx.emit.bind(Data(1)));
                });
                stream.end.then(function (result) {
                    fail();
                    done();
                });
                wait(10, done);
            });

            it("should abort stream", function (done) {
                var stream = Stream.apply(function (ctx) {
                    ctx.onAbort = done;
                });
                wait(10, stream.end.abort);
            });
        });
    }
}