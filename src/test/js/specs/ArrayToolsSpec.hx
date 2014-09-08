package specs;

import hxmocha.Mocha;
using hxgnd.ArrayTools;
import hxgnd.Option;
using hxgnd.OptionTools;

class ArrayToolsSpec {
    @:describe
    public static function groupBy() {
        Mocha.it("empty", function () {
            var arr = [];
            var result = arr.groupBy(function(x){return "a"+Std.string(x % 2);});
            Mocha.expect(result).to.eql({});
        });
        Mocha.it("grouping odd or even", function () {
            var arr = [1,4,18,31];
            var result = arr.groupBy(function(x){return "a"+Std.string(x % 2);});
            Mocha.expect(result.a1).to.eql([1,31]);
            Mocha.expect(result.a0).to.eql([4,18]);
        });
        Mocha.it("grouping num letters", function () {
            var arr = ["dog", "cat", "fish", "tiger", "lion"];
            var result = arr.groupBy(function(x){return "a"+x.length;});
            Mocha.expect(result.a3).to.eql(["dog", "cat"]);
            Mocha.expect(result.a4).to.eql(["fish", "lion"]);
            Mocha.expect(result.a5).to.eql(["tiger"]);
        });
    }

    @:describe
    public static function findOption(){
        function isEven(x){return x % 2 == 0;}

        Mocha.it("empty", function(){
            var arr = [];
            var result = arr.findOption(isEven);
            Mocha.expect(result.isEmpty()).to.be.ok();
        });
        Mocha.it("found one", function(){
            var arr = [42];
            var result = arr.findOption(isEven);
            Mocha.expect(result.get()).to.equal(42);
        });
        Mocha.it("found second element", function(){
            var arr = [41,42,43];
            var result = arr.findOption(isEven);
            Mocha.expect(result.get()).to.equal(42);
        });
        Mocha.it("found third element", function(){
            var arr = [39,41,42];
            var result = arr.findOption(isEven);
            Mocha.expect(result.get()).to.equal(42);
        });
        Mocha.it("contain two but return first", function(){
            var arr = [39,42,44];
            var result = arr.findOption(isEven);
            Mocha.expect(result.get()).to.equal(42);
        });
        Mocha.it("not found", function(){
            var arr = [39,49,47];
            var result = arr.findOption(isEven);
            Mocha.expect(result.isEmpty()).to.be.ok();
        });
    }

    @describe
    public static function headOption(){
        Mocha.it("empty", function(){
            Mocha.expect([].headOption().isEmpty()).to.be.ok();
        });
        Mocha.it("one element", function(){
            Mocha.expect([1].headOption().get()).to.be.equal(1);
        });
        Mocha.it("two elements", function(){
            Mocha.expect([1,2].headOption().get()).to.be.equal(1);
        });
    }

    @describe
    public static function lastOption(){
        Mocha.it("empty", function(){
            Mocha.expect([].lastOption().isEmpty()).to.be.ok();
        });
        Mocha.it("one element", function(){
            Mocha.expect([1].lastOption().get()).to.be.equal(1);
        });
        Mocha.it("two elements", function(){
            Mocha.expect([1,2].lastOption().get()).to.be.equal(2);
        });
    }

    @describe
    public static function flatten(){
        Mocha.it("empty", function(){
            Mocha.expect([].flatten()).to.be.eql([]);
        });
        Mocha.it("nested empty array", function(){
            Mocha.expect([[]].flatten()).to.be.eql([]);
        });
        Mocha.it("nested empty three arrays", function(){
            Mocha.expect([[], [],[]].flatten()).to.be.eql([]);
        });
        Mocha.it("just one element", function(){
            Mocha.expect([[1]].flatten()).to.be.eql([1]);
        });
        Mocha.it("one array", function(){
            Mocha.expect([[1,2,3]].flatten()).to.be.eql([1,2,3]);
        });
        Mocha.it("two array", function(){
            Mocha.expect([[1,2,3], [4,5]].flatten()).to.be.eql([1,2,3, 4,5]);
        });
        Mocha.it("include empty array", function(){
            Mocha.expect([[1,2,3], [], [4,5]].flatten()).to.be.eql([1,2,3, 4,5]);
        });
        Mocha.it("nested array", function(){
            Mocha.expect([[[1,2,3], [4,5]], [[6,7]]].flatten()).to.be.eql([[1,2,3], [4,5], [6,7]]);
        });
    }

    @describe
    public static function span(){
        function isEven(x){ return x % 2 == 0;}
        Mocha.it("empty", function(){
            Mocha.expect([].span(isEven)).to.be.eql({first: [], rest: []});
        });
        Mocha.it("match fisrt", function(){
            Mocha.expect([2,3,4].span(isEven)).to.be.eql({first: [], rest: [2,3,4]});
        });
        Mocha.it("match second", function(){
            Mocha.expect([1,2,3].span(isEven)).to.be.eql({first: [1], rest: [2,3]});
        });
        Mocha.it("match last", function(){
            Mocha.expect([1,3,4].span(isEven)).to.be.eql({first: [1, 3], rest: [4]});
        });
        Mocha.it("match nothing", function(){
            Mocha.expect([1,3,5].span(isEven)).to.be.eql({first: [1, 3, 5], rest: []});
        });
        Mocha.it("just one element and match", function(){
            Mocha.expect([2].span(isEven)).to.be.eql({first: [], rest: [2]});
        });
        Mocha.it("just one element and not match", function(){
            Mocha.expect([1].span(isEven)).to.be.eql({first: [1], rest: []});
        });
    }
}
