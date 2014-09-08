package hxgnd;

class Tuple2<A, B> {
  public var first(default, null): A;
  public var second(default, null): B;

  public function new(fst: A, snd: B) {
    this.first = fst;
    this.second = snd;
  }

  public function toString(): String {
    return 'Tuple2(' + this.first + ', ' + this.second + ')';
  }
}

class Tuple3<A, B, C> {
  public var first(default, null): A;
  public var second(default, null): B;
  public var third(default, null): C;

  public function new(fst: A, snd: B, thd: C) {
    this.first = fst;
    this.second = snd;
    this.third = thd;
  }

  public function toString(): String {
    return 'Tuple3('
      + this.first + ', '
      + this.second + ', '
      + this.third + ')';
  }
}
