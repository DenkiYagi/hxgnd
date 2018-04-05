package hxgnd;

import buddy.BuddySuite;
import buddy.tools.AsyncTools.wait;
import hxgnd.Result;
using hxgnd.LangTools;
using buddy.Should;

class FutureTest extends BuddySuite {
    public function new() {
        describe("Future.new()", {
            it("should call", function (done) {
                new Future(function (_, _) {
                    done();
                    return function () return PromiseLike.resolve();
                }#if js ,false#end);
            });
            
            it("should be empty", {
                var future = new Future(function (_, _) {
                    return function () return PromiseLike.resolve();
                }#if js ,false#end);
                future.result.isEmpty().should.be(true);
            });

            it("should rejected", {
                var future = new Future(function (_, _) {
                    throw "error";
                }#if js ,false#end);
                future.result.same(Maybe.of(Failed("error"))).should.be(true);
            });
        });
        #if js
        describe("Future(async).new()", {
            it("should call", function (done) {
                new Future(function (_, _) {
                    done();
                    return function () return PromiseLike.resolve();
                }#if js ,true#end);
            });
            
            it("should be empty", {
                var future = new Future(function (_, _) {
                    return function () return PromiseLike.resolve();
                }#if js ,true#end);
                future.result.isEmpty().should.be(true);
            });

            it("should rejected", function (done) {
                var future = new Future(function (_, _) {
                    throw "error";
                }#if js ,true#end);
                future.result.isEmpty().should.be(true);

                future.then(function (result: Result<Dynamic>) {
                    result.same(Failed("error")).should.be(true);
                    done();
                });
            });
        });
        #end

        describe("Future.then() : already complated", {
            it("should call", function (done) {
                new Future(function (complate, _) {
                    complate(1);
                    return function () return PromiseLike.resolve();
                }#if js ,false#end).then(function (x: Result<Int>) {
                    x.same(Success(1)).should.be(true);
                    done();
                });
            });

            it("should not call", function (done) {
                new Future(function (_, abort) {
                    abort("error");
                    return function () return PromiseLike.resolve();
                }#if js ,false#end).then(function (x: Result<Int>) {
                    x.same(Failed("error")).should.be(true);
                    done();
                });
            });
        });
        #if js
        describe("Future(async).then() : already complated", {
            it("should call", function (done) {
                new Future(function (complate, _) {
                    complate(1);
                    return function () return PromiseLike.resolve();
                }#if js ,true#end).then(function (x: Result<Int>) {
                    x.same(Success(1)).should.be(true);
                    done();
                });
            });

            it("should not call", function (done) {
                new Future(function (_, abort) {
                    abort("error");
                    return function () return PromiseLike.resolve();
                }#if js ,true#end).then(function (x: Result<Int>) {
                    x.same(Failed("error")).should.be(true);
                    done();
                });
            });
        });
        #end

        describe("Future.then() : async", {
            it("should call", function (done) {
                new Future(function (complate, _) {
                    wait(5).then(function (_) complate(1));
                    return function () return PromiseLike.resolve();
                }#if js ,false#end).then(function (x: Result<Int>) {
                    x.same(Success(1)).should.be(true);
                    done();
                });
            });

            it("should not call", function (done) {
                new Future(function (_, abort) {
                    wait(5).then(function (_)  abort("error"));
                    return function () return PromiseLike.resolve();
                }#if js ,false#end).then(function (x: Result<Int>) {
                    x.same(Failed("error")).should.be(true);
                    done();
                });
            });
        });
        #if js
        describe("Future(async).then() : async", {
            it("should call", function (done) {
                new Future(function (complate, _) {
                    wait(5).then(function (_) complate(1));
                    return function () return PromiseLike.resolve();
                }#if js ,true#end).then(function (x: Result<Int>) {
                    x.same(Success(1)).should.be(true);
                    done();
                });
            });

            it("should not call", function (done) {
                new Future(function (_, abort) {
                    wait(5).then(function (_)  abort("error"));
                    return function () return PromiseLike.resolve();
                }#if js ,true#end).then(function (x: Result<Int>) {
                    x.same(Failed("error")).should.be(true);
                    done();
                });
            });
        });
        #end
    }
}