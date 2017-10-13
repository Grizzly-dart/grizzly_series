part of grizzly.series.array2d;

class Index2D implements Index {
  final int x;

  final int y;

  const Index2D(this.x, this.y);

  int get dim => 2;

  int operator [](int d) {
    if (d >= dim)
      throw new RangeError.range(d, 0, dim - 1, 'd', 'Out of range!');
    if (d == 0) return x;
    return y;
  }

  List<int> toList() => <int>[x, y];

  bool operator ==(other) {
    if (other is! Index2D) return false;

    if (other is Index2D) {
      return other.x == this.x && other.y == this.y;
    }

    return false;
  }

  bool operator >(@checked Index2D other) => x > other.x && y > other.y;

  bool operator <(@checked Index2D other) => x < other.x && y < other.y;

  bool operator >=(@checked Index2D other) => x >= other.x && y >= other.y;

  bool operator <=(@checked Index2D other) => x <= other.x && y <= other.y;

  Index2D makeWithY(int y) => new Index2D(x, y);

  Index2D makeWithX(int x) => new Index2D(x, y);

  static const Index2D zero = const Index2D(0, 0);
}

Index2D idx2D(int x, int y) => new Index2D(x, y);
