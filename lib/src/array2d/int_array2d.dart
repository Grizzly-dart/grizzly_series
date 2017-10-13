part of grizzly.series.array2d;

class Int2DArray extends Object
    with IterableMixin<Array<int>>
    implements Numeric2DArray<int> {
  final List<IntArray> _data;

  Int2DArray.sized(int columns, int rows, {int data: 0})
      : _data = new List<IntArray>.generate(
            columns, (_) => new IntArray.sized(rows));

  Int2DArray.shaped(Index2D shape, {int data: 0})
      : _data = new List<IntArray>.generate(
            shape.x, (_) => new IntArray.sized(shape.y, data: data));

  factory Int2DArray.shapedLike(Array2D like, {int data: 0}) =>
      new Int2DArray.sized(like.numCols, like.numRows, data: data);

  Int2DArray.from(Iterable<Iterable<int>> data) : _data = <IntArray>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<int> item in data) {
        if (item.length != len) {
          throw new Exception('All columns must have same number of rows!');
        }
      }

      for (Iterable<int> item in data) {
        _data.add(new IntArray(item));
      }
    }
  }

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

  Int2DArray.columns(Iterable<int> column, int columns)
      : _data = new List<IntArray>(columns) {
    for (int i = 0; i < length; i++) {
      _data[i] = new IntArray(column);
    }
  }

  Int2DArray.rows(Iterable<int> row, int rows)
      : _data = new List<IntArray>(row.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new IntArray.sized(rows, data: row.elementAt(i));
    }
  }

  Int2DArray.row(Iterable<int> column) : _data = new List<IntArray>(1) {
    _data[0] = new IntArray(column);
  }

  Int2DArray.column(Iterable<int> row)
      : _data = new List<IntArray>(row.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new IntArray.single(row.elementAt(i));
    }
  }

  Int2DArray makeFrom(Iterable<Iterable<int>> newData) =>
      new Int2DArray.from(newData);

  int get _yLength {
    if (_data.length == 0) return 0;
    return _data.first.length;
  }

  int get numCols => length;

  int get numRows => _yLength;

  Index2D get shape => new Index2D(_data.length, _yLength);

  IntArrayFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Array<int> val) {
    if (i > _data.length) {
      throw new RangeError.range(i, 0, _data.length, 'i', 'Out of range!');
    }

    if (_data.length == 0) {
      final arr = new IntArray(val);
      _data.add(arr);
      return;
    }

    if (val.length != _yLength) {
      throw new Exception('Invalid size!');
    }

    final arr = new IntArray(val);

    if (i == _data.length) {
      _data.add(arr);
      return;
    }

    _data[i] = arr;
  }

  @override
  Iterator<IntArray> get iterator => _data.iterator;

  IntArray getRow(int r) {
    final ret = new IntArray.sized(numCols);

    for(int i = 0; i < numCols; i++) {
      ret[i] = _data[i][r];
    }

    return ret;
  }

  void addRow(Iterable<int> row) {
    if (row.length != length) {
      throw new Exception('Size mismatch!');
    }
    for (int i = 0; i < _data.length; i++) {
      _data[i].add(row.elementAt(i));
    }
  }

  void addRowScalar(int v) {
    for (int i = 0; i < _data.length; i++) {
      _data[i].add(v);
    }
  }

  void assign(int index, Iterable<int> v, {bool column: false}) {
    if (column) {
      if (index < 0 || index >= length) {
        throw new RangeError.range(index, 0, length - 1, 'index');
      }
      if (v.length != _yLength) {
        throw new Exception('Size mismatch!');
      }
      for (int i = 0; i < _yLength; i++) {
        _data[index][i] = v.elementAt(i);
      }
    } else {
      if (index < 0 || index >= _yLength) {
        throw new RangeError.range(index, 0, length - 1, 'index');
      }
      if (v.length != length) {
        throw new Exception('Size mismatch!');
      }
      for (int i = 0; i < length; i++) {
        _data[i][index] = v.elementAt(i);
      }
    }
  }

  void assignScalar(int index, int v, {bool column: false}) {
    if (column) {
      if (index < 0 || index >= length) {
        throw new RangeError.range(index, 0, length - 1, 'index');
      }
      for (int i = 0; i < _yLength; i++) {
        _data[index][i] = v;
      }
    } else {
      if (index < 0 || index >= _yLength) {
        throw new RangeError.range(index, 0, length - 1, 'index');
      }
      for (int i = 0; i < length; i++) {
        _data[i][index] = v;
      }
    }
  }

  /// Sets all elements in the array to given value [v]
  void set(int v) {
    for (int c = 0; c < length; c++) {
      for (int r = 0; r < _yLength; r++) {
        _data[c][r] = v;
      }
    }
  }

  @override
  int get min {
    if (_data.length == 0) return null;
    int min;
    for (int i = 0; i < _data.length; i++) {
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
    if (_data.length == 0) return null;
    int max;
    for (int i = 0; i < _data.length; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
    }
    return max;
  }

  Extent<int> get extent {
    if (_data.length == 0) return null;
    int min;
    int max;
    for (int i = 0; i < _data.length; i++) {
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
    if (_data.length == 0) return null;
    Index2D ret;
    int min;
    for (int i = 0; i < _data.length; i++) {
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
    if (_data.length == 0) return null;
    Index2D ret;
    int max;
    for (int i = 0; i < _data.length; i++) {
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
    if (_data.length == 0) return;

    if (min != null && max != null) {
      for (int i = 0; i < _data.length; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final int d = _data[i][j];

          if (d < min) _data[i][j] = min;
          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
    if (min != null) {
      for (int i = 0; i < _data.length; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final int d = _data[i][j];

          if (d < min) _data[i][j] = min;
        }
      }
      return;
    }
    if (max != null) {
      for (int j = 0; j < _data.first.length; j++) {
        for (int i = 0; i < _data.length; i++) {
          final int d = _data[i][j];

          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
  }

  IntPair<IntArray> pairAt(int index) => intPair<IntArray>(index, _data[index]);

  Iterable<IntPair<IntArray>> enumerate() =>
      Ranger.indices(_data.length).map((i) => intPair<IntArray>(i, _data[i]));

  double get mean {
    if (_data.length == 0) return 0.0;

    int sum = 0;
    for (int i = 0; i < _data.length; i++) {
      sum += _data[i].sum;
    }

    return sum / (length * _yLength);
  }

  DoubleArray get meanX {
    if (_data.length == 0) return new DoubleArray.sized(0);

    final ret = new DoubleArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      double sum = 0.0;

      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i][j];
        if (d == null) continue;
        sum += d;
      }

      ret[j] = sum / length;
    }

    return ret;
  }

  DoubleArray get meanY {
    if (_data.length == 0) return new DoubleArray.sized(0);

    final ret = new DoubleArray.sized(length);

    for (int i = 0; i < _data.length; i++) {
      ret[i] = _data[i].mean;
    }

    return ret;
  }

  double average(Iterable<Iterable<num>> weights) {
    if (weights.length != length) {
      throw new Exception('Weights have mismatching length!');
    }
    if (_data.length == 0) return 0.0;

    final int yL = _yLength;

    double sum = 0.0;
    num denom = 0.0;
    for (int i = 0; i < _data.length; i++) {
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

  DoubleArray averageX(Iterable<num> weights) {
    if (weights.length != length) {
      throw new Exception('Weights have mismatching length!');
    }

    if (_data.length == 0) return new DoubleArray.sized(0);

    final ret = new DoubleArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      double sum = 0.0;
      num denom = 0.0;

      for (int i = 0; i < _data.length; i++) {
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

  DoubleArray averageY(Iterable<num> weights) {
    if (_data.length == 0) return new DoubleArray.sized(0);

    if (weights.length != _data.first.length) {
      throw new Exception('Weights have mismatching length!');
    }

    final ret = new DoubleArray.sized(length);

    for (int i = 0; i < _data.length; i++) {
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

    final ret = new Int2DArray.sized(other.numCols, numRows);

    for(int r = 0; r < ret.numRows; r++) {
      for(int c = 0; c < numCols; c++) {
        ret[c][r] = getRow(r).dot(other[c]);
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
  IntArray get minX {
    if (_data.length == 0) return new IntArray.sized(0);

    final ret = new IntArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      int min;
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) min = d;
      }
      ret[j] = min;
    }

    return ret;
  }

  /// Minimum along y-axis
  IntArray get minY {
    final ret = new IntArray.sized(_data.length);
    for (int i = 0; i < _data.length; i++) {
      ret[i] = _data[i].min;
    }
    return ret;
  }

  /// Maximum along x-axis
  IntArray get maxX {
    if (_data.length == 0) return new IntArray.sized(0);

    final ret = new IntArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      int max;
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
      ret[j] = max;
    }

    return ret;
  }

  /// Maximum along y-axis
  IntArray get maxY {
    final ret = new IntArray.sized(_data.length);
    for (int i = 0; i < _data.length; i++) {
      ret[i] = _data[i].max;
    }
    return ret;
  }

  Int2DArray get transpose {
    final ret = new Int2DArray.sized(_yLength, length);

    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < _data.length; i++) {
        ret[j][i] = _data[i][j];
      }
    }

    return ret;
  }
}
