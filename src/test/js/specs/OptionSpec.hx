package specs;

import hxmocha.Mocha;
import hxgnd.Option;
import hxgnd.Result;

using hxgnd.OptionTools;

class OptionSpec {
    @:describe
    public static function get() {
        Mocha.it("Some(1)", function () {
            Mocha.expect(Some(1).get()).to.equal(1);
        });
        Mocha.it("Some([1,2,3])", function () {
            Mocha.expect(Some([1,2,3]).get()).to.eql([1,2,3]);
        });
        Mocha.it("None", function () {
            Mocha.expect(function () {None.get();}).to.throwException();
        });
    }

    @:describe
    public static function isEmpty() {
        Mocha.it("Some(1)", function () {
            Mocha.expect(Some(1).isEmpty()).to.equal(false);
        });
        Mocha.it("None", function () {
            Mocha.expect(None.isEmpty()).to.equal(true);
        });
    }

    static function inc(x: Int) {
        return x + 1;
    }

    static function toString(x: Int) {
        return Std.string(x);
    }

    static function shouldNone<A>(v: Option<A>) {  // Noneのassertの仕方が分からなかったので、文字列にした
        Mocha.expect(Std.string(v)).to.equal("None");
    }

    @:describe
    public static function map() {
        Mocha.it("Some(3)", function () {
            Mocha.expect(Some(3).map(inc).get()).to.equal(4);
        });
        Mocha.it("Some(3) to String", function () {
            Mocha.expect(Some(3).map(toString).get()).to.equal("3");
        });
        Mocha.it("None", function () {
            shouldNone(None.map(inc));
        });
    }

    @:describe
    public static function filter() {
        function isEven(x:Int) {
            return x % 2 == 0;
        }
        Mocha.it("Some(4) to Some", function () {
            Mocha.expect(Some(4).filter(isEven).get()).to.equal(4);
        });
        Mocha.it("Some(5) to None", function () {
            shouldNone(Some(5).filter(isEven));
        });
        Mocha.it("None to None", function () {
            shouldNone(None.filter(isEven));
        });
    }

    @:describe
    public static function orElse() {
        Mocha.it("Some orElse Some", function () {
            Mocha.expect(Some(3).orElse(function () {return Some(5);}).get()).to.equal(3);
        });
        Mocha.it("Some orElse None", function () {
            Mocha.expect(Some(3).orElse(function () {return None;}).get()).to.equal(3);
        });
        Mocha.it("None orElse Some", function () {
            Mocha.expect(None.orElse(function () {return Some(5);}).get()).to.equal(5);
        });
        Mocha.it("None orElse None", function () {
            shouldNone(None.orElse(function () {return None;}));
        });
    }

    @:describe
    public static function or() {
        Mocha.it("Some or Some", function () {
            Mocha.expect(Some(3).or(Some(5)).get()).to.equal(3);
        });
        Mocha.it("Some or None", function () {
            Mocha.expect(Some(3).or(None).get()).to.equal(3);
        });
        Mocha.it("None or Some", function () {
            Mocha.expect(None.or(Some(5)).get()).to.equal(5);
        });
        Mocha.it("None or None", function () {
            shouldNone(None.or(None));
        });
    }

    @:describe
    public static function toResult() {
        var error = new hxgnd.Error("test error");
        Mocha.it("to Success", function () {
            Mocha.expect(Some(3).toResult(error)).to.enumEqual(Success(3));
        });
        Mocha.it("to Failure", function () {
            Mocha.expect(None.toResult(error)).to.enumEqual(Failure(error));
        });
    }

    @:describe
    public static function toArray() {
        Mocha.it("Some to Array", function () {
            Mocha.expect(Some(3).toArray()).to.eql([3]);
        });
        Mocha.it("None to Array", function () {
            Mocha.expect(None.toArray()).to.eql([]);
        });
    }

    @:describe
    public static function getOrDefault() {
        Mocha.it("Some", function () {
            Mocha.expect(Some(3).getOrDefault(10)).to.equal(3);
        });
        Mocha.it("None", function () {
            Mocha.expect(None.getOrDefault(10)).to.equal(10);
        });
    }

    @:describe
    public static function getOrElse() {
        function ten() { return 10; }

        Mocha.it("Some", function () {
            Mocha.expect(Some(3).getOrElse(ten)).to.equal(3);
        });
        Mocha.it("None", function () {
            Mocha.expect(None.getOrElse(ten)).to.equal(10);
        });
    }

    @:describe
    public static function flatMap() {
        Mocha.it("Some to Some", function () {
            Mocha.expect(Some(3).flatMap(function(x){return Some(x + 1);}).get()).to.equal(4);
        });
        Mocha.it("Some to None", function () {
            shouldNone(Some(3).flatMap(function(x){return None;}));
        });
        Mocha.it("None to Some", function () {
            shouldNone(None.flatMap(function(x){return Some(3);}));
        });
        Mocha.it("None to None", function () {
            shouldNone(None.flatMap(function(x){return None;}));
        });
    }

    @:describe
    public static function iter() {
        Mocha.it("Some", function () {
            var buf = null;
            Some(3).iter(function(x){buf = x;});
            Mocha.expect(buf).to.equal(3);
        });
        Mocha.it("None", function () {
            var buf = null;
            None.iter(function(x){buf = x;});
            Mocha.expect(buf).to.equal(null);
        });
    }
}
