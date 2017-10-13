part of grizzly.series.array2d;

class Double2DArray extends Object
    with IterableMixin<Array<double>>
    implements Numeric2DArray<double> {
  final List<DoubleArray> _data;

  Double2DArray(Iterable<Iterable<double>> data) : _data = <DoubleArray>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<double> item in data) {
        if (item.length != len) {
          throw new Exception('All rows must have same number of columns!');
        }
      }

      for (Iterable<double> item in data) {
        _data.add(new DoubleArray(item));
      }
    }
  }

  Double2DArray.make(this._data);

  Double2DArray.sized(int numRows, int numCols, {double data: 0.0})
      : _data = new List<DoubleArray>.generate(
            numRows, (_) => new DoubleArray.sized(numCols, data: data));

  Double2DArray.shaped(Index2D shape, {double data: 0.0})
      : _data = new List<DoubleArray>.generate(
            shape.row, (_) => new DoubleArray.sized(shape.column, data: data));

  factory Double2DArray.shapedLike(Array2D like, {double data: 0.0}) =>
      new Double2DArray.sized(like.numRows, like.numCols, data: data);

  Double2DArray.fromNum(Iterable<Iterable<num>> data)
      : _data = <DoubleArray>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<num> item in data) {
        if (item.length != len) {
          throw new Exception('All rows must have same number of columns!');
        }
      }

      for (Iterable<num> item in data) {
        _data.add(new DoubleArray.fromNum(item));
      }
    }
  }

  Double2DArray.transposed(Iterable<Iterable<int>> data)
      : _data = <DoubleArray>[] {
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

  Double2DArray.rows(Iterable<double> row, [int numRows = 1])
      : _data = new List<DoubleArray>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new DoubleArray(row);
    }
  }

  Double2DArray.columns(Iterable<double> column, [int numCols = 1])
      : _data = new List<DoubleArray>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new DoubleArray.sized(numCols, data: column.elementAt(i));
    }
  }

  Double2DArray.row(Iterable<double> row) : _data = new List<DoubleArray>(1) {
    _data[0] = new DoubleArray(row);
  }

  Double2DArray.column(Iterable<double> column)
      : _data = new List<DoubleArray>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new DoubleArray.single(column.elementAt(i));
    }
  }

  Double2DArray makeFrom(Iterable<Iterable<double>> newData) =>
      new Double2DArray(newData);

  int get numCols {
    if (numRows == 0) return 0;
    return _data.first.length;
  }

  int get numRows => length;

  Index2D get shape => new Index2D(numRows, numCols);

  DoubleArrayFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<double> val) {
    if (i > numRows) {
      throw new RangeError.range(i, 0, numRows - 1, 'i', 'Out of range!');
    }

    if (numRows == 0) {
      final arr = new DoubleArray(val);
      _data.add(arr);
      return;
    }

    if (val.length != numCols) {
      throw new Exception('Invalid size!');
    }

    final arr = new DoubleArray(val);

    if (i == numRows) {
      _data.add(arr);
      return;
    }

    _data[i] = arr;
  }

  Double2DArray slice(Index2D start, [Index2D end]) {
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

    final list = <DoubleArray>[];

    for (int c = start.row; c < end.row; c++) {
      list.add(_data[c].slice(start.column, end.column));
    }

    return new Double2DArray.make(list);
  }

  @override
  Iterator<DoubleArray> get iterator => _data.iterator;

  Double2DColumns _cols;

  Double2DColumns get col => _cols ??= new Double2DColumns(this);

  /// Sets all elements in the array to given value [v]
  void set(double v) {
    for (int c = 0; c < length; c++) {
      for (int r = 0; r < numCols; r++) {
        _data[c][r] = v;
      }
    }
  }

  @override
  double get min {
    if (numRows == 0) return null;
    double min;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) min = d;
      }
    }
    return min;
  }

  @override
  double get max {
    if (numRows == 0) return null;
    double max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
    }
    return max;
  }

  Extent<double> get extent {
    if (numRows == 0) return null;
    double min;
    double max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
        if (min == null || d < min) min = d;
      }
    }
    return new Extent<double>(min, max);
  }

  Index2D get argMin {
    if (numRows == 0) return null;
    Index2D ret;
    double min;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

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
    double max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) {
          max = d;
          ret = idx2D(i, j);
        }
      }
    }
    return ret;
  }

  void clip({double min, double max}) {
    if (numRows == 0) return;

    if (min != null && max != null) {
      for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final double d = _data[i][j];

          if (d < min) _data[i][j] = min;
          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
    if (min != null) {
      for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final double d = _data[i][j];

          if (d < min) _data[i][j] = min;
        }
      }
      return;
    }
    if (max != null) {
      for (int j = 0; j < _data.first.length; j++) {
        for (int i = 0; i < numRows; i++) {
          final double d = _data[i][j];

          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
  }

  IntPair<DoubleArray> pairAt(int index) =>
      intPair<DoubleArray>(index, _data[index]);

  Iterable<IntPair<DoubleArray>> enumerate() =>
      Ranger.indices(numRows).map((i) => intPair<DoubleArray>(i, _data[i]));

  double get mean {
    if (numRows == 0) return 0.0;

    double sum = 0.0;
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
        final double d = _data[i][j];
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
    if (weights.length != length) {
      throw new Exception('Weights have mismatching length!');
    }
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
        final double d = _data[i][j];
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
        final double d = _data[i][j];
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
        final double d = _data[i][j];
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

  Double2DArray dot(Numeric2DArray other) {
    if (numCols != other.numRows)
      throw new ArgumentError.value(other, 'other', 'Invalid shape!');

    final ret = new Double2DArray.sized(numRows, other.numCols);

    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        ret[r][c] = _data[r].dot(other.col[c]);
      }
    }

    return ret;
  }

  Array2D<double> head([int count = 10]) {
    // TODO
    throw new UnimplementedError();
  }

  Array2D<double> tail([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  Array2D<double> sample([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  /// Minimum along x-axis
  DoubleArray get minRow {
    if (numRows == 0) return new DoubleArray.sized(0);

    final ret = new DoubleArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      double min;
      for (int i = 0; i < numRows; i++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) min = d;
      }
      ret[j] = min;
    }

    return ret;
  }

  /// Minimum along y-axis
  DoubleArray get minCol {
    final ret = new DoubleArray.sized(numRows);
    for (int i = 0; i < numRows; i++) {
      ret[i] = _data[i].min;
    }
    return ret;
  }

  /// Maximum along x-axis
  DoubleArray get maxRow {
    if (numRows == 0) return new DoubleArray.sized(0);

    final ret = new DoubleArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      double max;
      for (int i = 0; i < numRows; i++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
      ret[j] = max;
    }

    return ret;
  }

  /// Maximum along y-axis
  DoubleArray get maxCol {
    final ret = new DoubleArray.sized(numRows);
    for (int i = 0; i < numRows; i++) {
      ret[i] = _data[i].max;
    }
    return ret;
  }

  Double2DArray get transpose {
    final ret = new Double2DArray.sized(numCols, length);

    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < numRows; i++) {
        ret[j][i] = _data[i][j];
      }
    }

    return ret;
  }
}

class Double2DColumns implements Array2DColumns<double> {
  final Double2DArray inner;

  Double2DColumns(this.inner);

  DoubleArray operator [](int r) {
    final ret = new DoubleArray.sized(inner.numRows);

    for (int i = 0; i < inner.numRows; i++) {
      ret[i] = inner[i][r];
    }

    return ret;
  }

  operator []=(int index, Iterable<double> col) {
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

  void add(Iterable<double> col) {
    if (col.length != inner.numRows)
      throw new ArgumentError.value(col, 'col', 'Size mismatch');
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(col.elementAt(i));
    }
  }

  void addScalar(double v) {
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(v);
    }
  }
}
