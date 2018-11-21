package hxgnd;

import buddy.BuddySuite;
using buddy.Should;
import haxe.ds.Option;
using hxgnd.OptionTools;

class OptionToolsTest extends BuddySuite {
    public function new() {
        timeoutMs = 50;

        describe("OptionTools.isEmpty()", {
            it("should be false", {
                Some(1).isEmpty().should.be(false);
            });

            it("should be true", {
                None.isEmpty().should.be(true);
            });
        });

        describe("OptionTools.nonEmpty()", {
            it("should be true", {
                Some(1).nonEmpty().should.be(true);
            });

            it("should be false", {
                None.nonEmpty().should.be(false);
            });
        });

        describe("OptionTools.forEach()", {
            it("should call fn", function (done) {
                Some(1).forEach(function (x) {
                    x.should.be(1);
                    done();
                });
            });

            it("should not call fn", function (done) {
                None.forEach(function (x) {
                    fail();
                });
                TestTools.wait(10, done);
            });
        });

        describe("OptionTools.map()", {
            it("should call fn", {
                Some(1).map(function (x) {
                    return x * 2;
                })
                .should.equal(Some(2));
            });

            it("should not call fn", {
                None.map(function (x) {
                    fail();
                    return x * 2;
                })
                .should.equal(None);
            });
        });

        describe("OptionTools.flatMap()", {
            it("should call fn", {
                Some(1).flatMap(function (x) {
                    return Some(x * 2);
                })
                .should.equal(Some(2));

                Some(1).flatMap(function (x) {
                    return None;
                })
                .should.equal(None);
            });

            it("should not call fn", {
                var ret = None.map(function (x) {
                    fail();
                    return x * 2;
                });
                ret.should.equal(None);
            });
        });

        describe("OptionTools.flatten()", {
            it("should flatten", {
                Some(Some(1)).flatten().should.equal(Some(1));
            });

            it("should be None", {
                Some(None).flatten().should.equal(None);
                None.flatten().should.equal(None);
            });
        });

        describe("OptionTools.exists()", {
            it("should be true", {
                Some(1).exists(1).should.be(true);
            });

            it("should be false", {
                Some(1).exists(0).should.be(false);
                None.exists(1).should.be(false);
            });
        });

        describe("OptionTools.notExists()", {
            it("should be false", {
                Some(1).notExists(1).should.be(false);
            });

            it("should be true", {
                Some(1).notExists(0).should.be(true);
                None.notExists(1).should.be(true);
            });
        });

        describe("OptionTools.find()", {
            it("should be true", {
                Some(1).find(function (x) return x == 1).should.be(true);
            });

            it("should be false", {
                Some(1).find(function (x) return false).should.be(false);
                None.find(function (x) return true).should.be(false);
            });
        });
    }
}