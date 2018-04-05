package hxgnd;

import hxgnd.Stream;
import buddy.BuddySuite;
import buddy.tools.AsyncTools.wait;
using buddy.Should;
using hxgnd.LangTools;

class StreamTest extends BuddySuite {
    public function new() {
        describe("Stream", {
            it("should invoke middleware defer", function (done) {
                var stream = new Stream(function (ctx) {
                    ctx.emit(End);
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

                wait(5).then(function (_) {
                    count.should.be(1);
                    done();
                });
            });

            it("should be pass when middleware emits End 2-times", function (done) {
                var stream = new Stream(function (ctx) {
                    ctx.emit(End);
                    ctx.emit(End);
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

                wait(5).then(function (_) {
                    count.should.be(1);
                    done();
                });
            });

            it("should wait delayed End", function (done) {
                var stream = new Stream(function (ctx) {
                    wait(5).then(function (_) {
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

                wait(10).then(function (e) {
                    count.should.be(1);
                    done();
                });
            });

            it("should subscribe 1 Data and End", function (done) {
                var stream = new Stream(function (ctx) {
                    wait(5).then(function (_) {
                        ctx.emit(Data(1));
                    });
                    wait(10).then(function (_) {
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

                wait(15).then(function (e) {
                    count.should.be(2);
                    done();
                });
            });

            it("should subscribe 2 Data and End", function (done) {
                var stream = new Stream(function (ctx) {
                    wait(5).then(function (_) {
                        ctx.emit(Data(1));
                    });
                    wait(10).then(function (_) {
                        ctx.emit(Data(2));
                    });
                    wait(15).then(function (_) {
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

                wait(20).then(function (e) {
                    count.should.be(3);
                    done();
                });
            });

            it("should notify to 2 subscribers", function (done) {
                var stream = new Stream(function (ctx) {
                    wait(5).then(function (_) {
                        ctx.emit(Data(1));
                    });
                    wait(10).then(function (_) {
                        ctx.emit(Data(2));
                    });
                    wait(15).then(function (_) {
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

                wait(20).then(function (e) {
                    count1.should.be(3);
                    count2.should.be(3);
                    done();
                });
            });
        });
    }
}