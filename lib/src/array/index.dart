part of grizzly.series.array;

Index1D idx1D(int x) => new Index1D(x);

abstract class Index {
  /// Number of dimensions
  int get dim;

  /// Get index at dimension [d]
  int operator [](int d);

  bool operator ==(other);

  bool operator >(Index other);

  bool operator <(Index other);

  bool operator >=(Index other);

  bool operator <=(Index other);

  List<int> toList();
}

class Index1D implements Index {
  final int x;

  const Index1D(this.x);

  int get dim => 1;

  int operator [](int d) {
    if (d >= dim) throw new RangeError.range(d, 0, 0, 'd', 'Out of range!');
    return x;
  }

  List<int> toList() => <int>[x];

  bool operator ==(other) {
    if (other is! Index1D) return false;

    if (other is Index1D) {
      return other.x == this.x;
    }

    return false;
  }

  bool operator >(@checked Index1D other) => x > other.x;

  bool operator <(@checked Index1D other) => x < other.x;

  bool operator >=(@checked Index1D other) => x >= other.x;

  bool operator <=(@checked Index1D other) => x <= other.x;
}
