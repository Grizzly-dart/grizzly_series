part of grizzly.series.array2d;

class Index2D implements Index {
  /// Row this index is indexing
  final int row;

  /// Column this index is indexing
  final int col;

  /// Constructs a new 2D index with given [row] and [col]
  const Index2D(this.row, this.col);

  /// Number of dimensions of this [Index]
  int get dim => 2;

  /// Gets the index with the given dimension [d]
  int operator [](int d) {
    if (d >= dim)
      throw new RangeError.range(d, 0, dim - 1, 'd', 'Out of range!');
    if (d == 0) return row;
    return col;
  }

  List<int> toList() => <int>[row, col];

  bool operator ==(other) {
    if (other is! Index2D) return false;

    if (other is Index2D) {
      return other.row == this.row && other.col == this.col;
    }

    return false;
  }

  bool operator >(@checked Index2D other) => row > other.row && col > other.col;

  bool operator <(@checked Index2D other) => row < other.row && col < other.col;

  bool operator >=(@checked Index2D other) =>
      row >= other.row && col >= other.col;

  bool operator <=(@checked Index2D other) =>
      row <= other.row && col <= other.col;

  /// Returns the transpose of the index
  Index2D get transpose => new Index2D(col, row);

  /// Creates a new 2D Index with given [col] and existing [row]
  Index2D withColumn(int col) => new Index2D(row, col);

  /// Creates a new 2D Index with given [row] and existing [col]
  Index2D withRow(int row) => new Index2D(row, col);

  /// Returns a 2D index with 0th row and 0th column
  static const Index2D zero = const Index2D(0, 0);
}

/// Convenience method to create a new 2D index with given [row] and [col]
Index2D idx2D(int row, int col) => new Index2D(row, col);
