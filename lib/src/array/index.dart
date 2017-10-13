part of grizzly.series.array;

Index1D idx1D(int x) => new Index1D(x);

abstract class Index {
  /// Number of dimensions
  int get dim;

  /// Get index at dimension [d]
  int operator [](int d);

  List<int> toList();
}

class Index1D {
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
}