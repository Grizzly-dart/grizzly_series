part of grizzly.series.array2d;

class Int2DArray extends Object
    with IterableMixin<Array<int>>
    implements Numeric2DArray<int> {
  final List<IntArray> _data;

  Int2DArray(Iterable<Iterable<int>> data) : _data = <IntArray>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<int> item in data) {
        if (item.length != len) {
          throw new Exception('All rows must have same number of columns!');
        }
      }

      for (Iterable<int> item in data) {
        _data.add(new IntArray(item));
      }
    }
  }

  Int2DArray.sized(int rows, int columns, {int data: 0})
      : _data = new List<IntArray>.generate(
            rows, (_) => new IntArray.sized(columns));

  Int2DArray.shaped(Index2D shape, {int data: 0})
      : _data = new List<IntArray>.generate(
            shape.row, (_) => new IntArray.sized(shape.column, data: data));

  factory Int2DArray.shapedLike(Array2D like, {int data: 0}) =>
      new Int2DArray.sized(like.numCols, like.numRows, data: data);

  Int2DArray.make(this._data);

  Int2DArray.transposed(Iterable<Iterable<int>> data) : _data = <IntArray>[] {
    /* TODO
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<int> item in data) {
        if (item.length != len) {
          throw new Exception('All columns must have same number of rows!');
        }
      }

      for (Iterable<int> item in data) {
        _data.add(new IntArray.from(item));
      }
    }
    */
  }

  Int2DArray.rows(Iterable<int> row, [int numRows = 1])
      : _data = new List<IntArray>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new IntArray(row);
    }
  }

  Int2DArray.columns(Iterable<int> column, [int numCols = 1])
      : _data = new List<IntArray>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new IntArray.sized(numCols, data: column.elementAt(i));
    }
  }

  Int2DArray.row(Iterable<int> row) : _data = new List<IntArray>(1) {
    _data[0] = new IntArray(row);
  }

  Int2DArray.column(Iterable<int> column)
      : _data = new List<IntArray>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new IntArray.single(column.elementAt(i));
    }
  }

  Int2DArray makeFrom(Iterable<Iterable<int>> newData) =>
      new Int2DArray(newData);

  int get numCols {
    if (numRows == 0) return 0;
    return _data.first.length;
  }

  int get numRows => length;

  Index2D get shape => new Index2D(numRows, numCols);

  IntArrayFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<int> val) {
    if (i > numRows) {
      throw new RangeError.range(i, 0, numRows - 1, 'i', 'Out of range!');
    }

    if (numRows == 0) {
      final arr = new IntArray(val);
      _data.add(arr);
      return;
    }

    if (val.length != numCols) {
      throw new Exception('Invalid size!');
    }

    final arr = new IntArray(val);

    if (i == numRows) {
      _data.add(arr);
      return;
    }

    _data[i] = arr;
  }

  Int2DArray slice(Index2D start, [Index2D end]) {
    final Index2D myShape = shape;
    if (end == null) {
      end = myShape;
    } else {
      if (end < Index2D.zero)
        throw new ArgumentError.value(end, 'end', 'Index out of range!');
      if (end >= myShape)
        throw new ArgumentError.value(end, 'end', 'Index out of range!');
      if (start > end)
        throw new ArgumentError.value(
            end, 'end', 'Must be greater than start!');
    }
    if (start < Index2D.zero)
      throw new ArgumentError.value(start, 'start', 'Index out of range!');
    if (start >= myShape)
      throw new ArgumentError.value(start, 'start', 'Index out of range!');

    final list = <IntArray>[];

    for (int c = start.row; c < end.row; c++) {
      list.add(_data[c].slice(start.column, end.column));
    }

    return new Int2DArray.make(list);
  }

  @override
  Iterator<IntArray> get iterator => _data.iterator;

  Int2DColumns _col;

  Int2DColumns get col => _col ??= new Int2DColumns(this);

  /// Sets all elements in the array to given value [v]
  void set(int v) {
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        _data[r][c] = v;
      }
    }
  }

  @override
  int get min {
    if (numRows == 0) return null;
    int min;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) min = d;
      }
    }
    return min;
  }

  @override
  int get max {
    if (numRows == 0) return null;
    int max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
    }
    return max;
  }

  Extent<int> get extent {
    if (numRows == 0) return null;
    int min;
    int max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
        if (min == null || d < min) min = d;
      }
    }
    return new Extent<int>(min, max);
  }

  Index2D get argMin {
    if (numRows == 0) return null;
    Index2D ret;
    int min;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) {
          min = d;
          ret = idx2D(i, j);
        }
      }
    }
    return ret;
  }

  Index2D get argMax {
    if (numRows == 0) return null;
    Index2D ret;
    int max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) {
          max = d;
          ret = idx2D(i, j);
        }
      }
    }
    return ret;
  }

  void clip({int min, int max}) {
    if (numRows == 0) return;

    if (min != null && max != null) {
      for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final int d = _data[i][j];

          if (d < min) _data[i][j] = min;
          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
    if (min != null) {
      for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final int d = _data[i][j];

          if (d < min) _data[i][j] = min;
        }
      }
      return;
    }
    if (max != null) {
      for (int j = 0; j < _data.first.length; j++) {
        for (int i = 0; i < numRows; i++) {
          final int d = _data[i][j];

          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
  }

  // TODO return lazy
  // TODO return view
  IntPair<IntArray> pairAt(int index) => intPair<IntArray>(index, _data[index]);

  // TODO return lazy
  // TODO return view
  Iterable<IntPair<IntArray>> enumerate() =>
      Ranger.indices(numRows).map((i) => intPair<IntArray>(i, _data[i]));

  double get mean {
    if (numRows == 0) return 0.0;

    int sum = 0;
    for (int i = 0; i < numRows; i++) {
      sum += _data[i].sum;
    }

    return sum / (length * numCols);
  }

  DoubleArray get meanRow {
    if (numRows == 0) return new DoubleArray.sized(0);

    final ret = new DoubleArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      double sum = 0.0;

      for (int i = 0; i < numRows; i++) {
        final int d = _data[i][j];
        if (d == null) continue;
        sum += d;
      }

      ret[j] = sum / length;
    }

    return ret;
  }

  DoubleArray get meanCol {
    if (numRows == 0) return new DoubleArray.sized(0);

    final ret = new DoubleArray.sized(length);

    for (int i = 0; i < numRows; i++) {
      ret[i] = _data[i].mean;
    }

    return ret;
  }

  double average(Iterable<Iterable<num>> weights) {
    if (weights.length != length)
      throw new ArgumentError.value(weights, 'weights', 'Size mismatch');
    if (numRows == 0) return 0.0;

    final int yL = numCols;

    double sum = 0.0;
    num denom = 0.0;
    for (int i = 0; i < numRows; i++) {
      final weightsI = weights.elementAt(i);

      if (weightsI.length != yL) {
        throw new Exception('Weights have mismatching length!');
      }

      for (int j = 0; j < _data.first.length; j++) {
        final int d = _data[i][j];
        final num w = weightsI.elementAt(j);
        if (d == null) continue;
        if (w == null) continue;
        sum += d * w;
        denom += w;
      }
    }
    return sum / denom;
  }

  DoubleArray averageRow(Iterable<num> weights) {
    if (weights.length != length) {
      throw new Exception('Weights have mismatching length!');
    }

    if (numRows == 0) return new DoubleArray.sized(0);

    final ret = new DoubleArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      double sum = 0.0;
      num denom = 0.0;

      for (int i = 0; i < numRows; i++) {
        final int d = _data[i][j];
        final num w = weights.elementAt(i);
        if (d == null) continue;
        if (w == null) continue;
        sum += d * w;
        denom += w;
      }

      ret[j] = sum / denom;
    }

    return ret;
  }

  DoubleArray averageCol(Iterable<num> weights) {
    if (numRows == 0) return new DoubleArray.sized(0);

    if (weights.length != _data.first.length) {
      throw new Exception('Weights have mismatching length!');
    }

    final ret = new DoubleArray.sized(length);

    for (int i = 0; i < numRows; i++) {
      double sum = 0.0;
      num denom = 0.0;

      for (int j = 0; j < _data.first.length; j++) {
        final int d = _data[i][j];
        final num w = weights.elementAt(j);
        if (d == null) continue;
        if (w == null) continue;
        sum += d * w;
        denom += w;
      }

      ret[i] = sum / denom;
    }
    return ret;
  }

  Int2DArray dot(Numeric2DArray other) {
    if (numCols != other.numRows)
      throw new ArgumentError.value(other, 'other', 'Invalid shape!');

    final ret = new Int2DArray.sized(numRows, other.numCols);

    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        ret[r][c] = _data[r].dot(other.col[c]);
      }
    }

    return ret;
  }

  Array2D<int> head([int count = 10]) {
    // TODO
    throw new UnimplementedError();
  }

  Array2D<int> tail([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  Array2D<int> sample([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  /// Minimum along x-axis
  IntArray get minRow {
    if (numRows == 0) return new IntArray.sized(0);

    final ret = new IntArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      int min;
      for (int i = 0; i < numRows; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) min = d;
      }
      ret[j] = min;
    }

    return ret;
  }

  /// Minimum along y-axis
  IntArray get minCol {
    final ret = new IntArray.sized(numRows);
    for (int i = 0; i < numRows; i++) {
      ret[i] = _data[i].min;
    }
    return ret;
  }

  /// Maximum along x-axis
  IntArray get maxRow {
    if (numRows == 0) return new IntArray.sized(0);

    final ret = new IntArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      int max;
      for (int i = 0; i < numRows; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
      ret[j] = max;
    }

    return ret;
  }

  /// Maximum along y-axis
  IntArray get maxCol {
    final ret = new IntArray.sized(numRows);
    for (int i = 0; i < numRows; i++) {
      ret[i] = _data[i].max;
    }
    return ret;
  }

  Int2DArray get transpose {
    final ret = new Int2DArray.sized(numCols, length);

    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < numRows; i++) {
        ret[j][i] = _data[i][j];
      }
    }

    return ret;
  }

  Double2DArray get toDouble => new Double2DArray.fromNum(this);
}

class Int2DColumns implements Array2DColumns<int> {
  final Int2DArray inner;

  Int2DColumns(this.inner);

  IntArray operator [](int r) {
    final ret = new IntArray.sized(inner.numRows);

    for (int i = 0; i < inner.numRows; i++) {
      ret[i] = inner[i][r];
    }

    return ret;
  }

  operator []=(int index, Iterable<int> col) {
    if (index >= inner.numCols) {
      throw new RangeError.range(index, 0, inner.numCols - 1, 'index');
    }
    if (col.length != inner.numRows) {
      throw new ArgumentError.value(col, 'col', 'Size mismatch!');
    }
    for (int i = 0; i < inner.numRows; i++) {
      inner[i][index] = col.elementAt(i);
    }
  }

  void add(Iterable<int> col) {
    if (col.length != inner.numRows)
      throw new ArgumentError.value(col, 'col', 'Size mismatch');
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(col.elementAt(i));
    }
  }

  void addScalar(int v) {
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(v);
    }
  }
}
