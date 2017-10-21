part of grizzly.series.array2d;

class Index2D implements Index {
  final int row;

  final int column;

  const Index2D(this.row, this.column);

  int get dim => 2;

  int operator [](int d) {
    if (d >= dim)
      throw new RangeError.range(d, 0, dim - 1, 'd', 'Out of range!');
    if (d == 0) return row;
    return column;
  }

  List<int> toList() => <int>[row, column];

  bool operator ==(other) {
    if (other is! Index2D) return false;

    if (other is Index2D) {
      return other.row == this.row && other.column == this.column;
    }

    return false;
  }

  bool operator >(@checked Index2D other) =>
      row > other.row && column > other.column;

  bool operator <(@checked Index2D other) =>
      row < other.row && column < other.column;

  bool operator >=(@checked Index2D other) =>
      row >= other.row && column >= other.column;

  bool operator <=(@checked Index2D other) =>
      row <= other.row && column <= other.column;

  Index2D makeWithY(int y) => new Index2D(row, y);

  Index2D makeWithX(int x) => new Index2D(x, column);

  static const Index2D zero = const Index2D(0, 0);
}

Index2D idx2D(int x, int y) => new Index2D(x, y);
