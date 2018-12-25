package hxgnd;

import buddy.BuddySuite;
import hxgnd.Enumerator;
import hxgnd.internal.ForEacherImpl;
using buddy.Should;

class EnumeratorTest extends BuddySuite {
    public function new() {
        describe("EnumeratorSource", {
            it("should be ArrayForEacher", {
                var src: EnumeratorSource<Int> = [1, 2, 3];
                src.should.beType(ArrayForEacher);
            });

            it("should be IntIteratorForEacher", {
                var src: EnumeratorSource<Int> = 0...3;
                src.should.beType(IntIteratorForEacher);
            });

            it("should be IteratorForEacher", {
                var src: EnumeratorSource<Int> = [1, 2, 3].iterator();
                src.should.beType(IteratorForEacher);
            });

            it("should be IterableForEacher", {
                var src: EnumeratorSource<Int> = ([1, 2, 3]: Iterable<Int>);
                src.should.beType(IteratorForEacher);
            });
        });
    }
}