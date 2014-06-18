package specs;

import hxmocha.Mocha;
import hxgnd.Error;
import hxgnd.Result;
using hxgnd.ResultTools;

class ResultSpec {
    @:describe
    public static function get() {
        Mocha.it("Success(1)", function(){
            Mocha.expect(Success(1).get()).to.be.equal(1);
        });
        Mocha.it("Failure", function(){
            Mocha.expect(function(){Failure(new Error("error test")).get();}).to.be.throwException();
        });
    }

    @:describe
    public static function isSuccess() {
        Mocha.it("Success(1)", function(){
            Mocha.expect(Success(1).isSuccess()).to.equal(true);
        });
        Mocha.it("Failure(1)", function(){
            Mocha.expect(Failure(new Error("error test")).isSuccess()).to.equal(false);
        });
    }

    @:describe
    public static function map() {
        var error = new Error("error test");
        function inc(x:Int) {
            return x + 1;
        }
        Mocha.it("Success(1)", function(){
            Mocha.expect(Success(1).map(inc).get()).to.equal(2);
        });
        Mocha.it("Success(1) to failure", function(){
            Mocha.expect(Success("1").map(function(x){throw error;})).to.enumEqual(Failure(error));
        });
        Mocha.it("Failure(1)", function(){
            Mocha.expect(Failure(error).map(inc)).to.enumEqual(Failure(error));
        });
    }

    @:describe
    public static function flatten() {
        var error = new Error("error test");
        Mocha.it("Success(Success(3))", function(){
            Mocha.expect(Success(Success(3)).flatten().get()).to.equal(3);
        });
        Mocha.it("Success(Failure(error))", function(){
            Mocha.expect(Success(Failure(error)).flatten()).to.enumEqual(Failure(error));
        });
        Mocha.it("Failure(error))", function(){
            var result: Result<Result<Int>> = Failure(error);
            Mocha.expect(result.flatten()).to.enumEqual(Failure(error));
        });
    }

    @:describe
    public static function flatMap() {
        var error = new Error("error test");
        Mocha.it("Success to Success", function(){
            Mocha.expect(Success(1).flatMap(function(x){return Success(x+1);}).get()).to.equal(2);
        });
        Mocha.it("Success(1) to Failure", function(){
            Mocha.expect(Success("1").flatMap(function(x){return Failure(error);})).to.enumEqual(Failure(error));
        });
        Mocha.it("Success(1) to Failure with throwing", function(){
            Mocha.expect(Success("1").flatMap(function(x){throw error;})).to.enumEqual(Failure(error));
        });
        var failure: Result<Int> = Failure(error);
        Mocha.it("Failure(1)", function(){
            Mocha.expect(failure.flatMap(function(x){throw "hoge";})).to.enumEqual(Failure(error));
        });
        Mocha.it("Failure(1) then Failure", function(){
            Mocha.expect(failure.flatMap(function(x){return Failure(new Error("hoge"));})).to.enumEqual(Failure(error));
        });
    }

    @:describe
    public static function failureMap() {
        var error = new Error("error test");
        Mocha.it("Success(3)", function(){
            Mocha.expect(Success(3).failureMap(function(ex){return Success(4);}).get()).to.equal(3);
        });
        Mocha.it("Success(3) then throw", function(){
            Mocha.expect(Success(3).failureMap(function(ex){throw error;}).get()).to.equal(3);
        });
        Mocha.it("Failure to Success", function(){
            Mocha.expect(Failure(error).failureMap(function(ex){return Success(ex);}).get()).to.equal(error);
        });
        Mocha.it("Failure then throw", function(){
            var failure: Result<Int> = Failure(error);
            var error2 = new Error("test error 2");
            Mocha.expect(failure.failureMap(function(ex){throw error2;})).to.enumEqual(Failure(error2));
        });
    }

    @:describe
    public static function iter() {
        var error = new Error("error test");
        Mocha.it("Success(3)", function(){
            var buf = null;
            Success(3).iter(function(x){buf = x;});
            Mocha.expect(buf).to.equal(3);
        });
        Mocha.it("Failure", function(){
            var buf = null;
            Failure(error).iter(function(x){buf = x;});
            Mocha.expect(buf).to.equal(null);
        });
    }

    @:describe
    public static function failureIter() {
        var error = new Error("error test");
        Mocha.it("Success(3)", function(){
            var buf = null;
            Success(3).failureIter(function(x){buf = x;});
            Mocha.expect(buf).to.equal(null);
        });
        Mocha.it("Failure", function(){
            var buf = null;
            Failure(error).failureIter(function(x){buf = x;});
            Mocha.expect(buf).to.equal(error);
        });
    }
}
