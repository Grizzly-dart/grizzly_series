part of grizzly.series.array2d;

class Double2DArray extends Object
    with IterableMixin<Array<double>>
    implements Numeric2DArray<double> {
  final List<DoubleArray> _data;

  Double2DArray.sized(int x, int y)
      : _data =
            new List<DoubleArray>.generate(x, (_) => new DoubleArray.sized(y));

  Double2DArray.from(Iterable<Iterable<double>> data)
      : _data = <DoubleArray>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<double> item in data) {
        if (item.length != len) {
          throw new Exception('All columns must have same number of rows!');
        }
      }

      for (Iterable<double> item in data) {
        _data.add(new DoubleArray.from(item));
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

  Double2DArray.columns(Iterable<double> column, int columns)
      : _data = new List<DoubleArray>(columns) {
    for (int i = 0; i < length; i++) {
      _data[i] = new DoubleArray.from(column);
    }
  }

  Double2DArray.rows(Iterable<double> row, int rows)
      : _data = new List<DoubleArray>(row.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new DoubleArray.sized(rows, data: row.elementAt(i));
    }
  }

  Double2DArray.row(Iterable<double> column)
      : _data = new List<DoubleArray>(1) {
    _data[0] = new DoubleArray.from(column);
  }

  Double2DArray.column(Iterable<double> row)
      : _data = new List<DoubleArray>(row.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new DoubleArray.single(row.elementAt(i));
    }
  }

  Double2DArray makeFrom(Iterable<Iterable<double>> newData) =>
      new Double2DArray.from(newData);

  int get _yLength {
    if (_data.length == 0) return 0;
    return _data.first.length;
  }

  Index2D get shape => new Index2D(_data.length, _yLength);

  // TODO return view
  DoubleArray operator [](int i) => _data[i];

  operator []=(final int i, Array<double> val) {
    if (i > _data.length) {
      throw new RangeError.range(i, 0, _data.length, 'i', 'Out of range!');
    }

    if (_data.length == 0) {
      final arr = new DoubleArray.from(val);
      _data.add(arr);
      return;
    }

    if (val.length != _yLength) {
      throw new Exception('Invalid size!');
    }

    final arr = new DoubleArray.from(val);

    if (i == _data.length) {
      _data.add(arr);
      return;
    }

    _data[i] = arr;
  }

  @override
  Iterator<DoubleArray> get iterator => _data.iterator;

  void addRow(Iterable<double> row) {
    if (row.length != length) {
      throw new Exception('Size mismatch!');
    }
    for (int i = 0; i < _data.length; i++) {
      _data[i].add(row.elementAt(i));
    }
  }

  void addRowScalar(double v) {
    for (int i = 0; i < _data.length; i++) {
      _data[i].add(v);
    }
  }

  void assign(int index, Iterable<double> v, {bool column: false}) {
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

  void assignScalar(int index, double v, {bool column: false}) {
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

  @override
  double get min {
    if (_data.length == 0) return null;
    double min;
    for (int i = 0; i < _data.length; i++) {
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
    if (_data.length == 0) return null;
    double max;
    for (int i = 0; i < _data.length; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
    }
    return max;
  }

  Extent<double> get extent {
    if (_data.length == 0) return null;
    double min;
    double max;
    for (int i = 0; i < _data.length; i++) {
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
    if (_data.length == 0) return null;
    Index2D ret;
    double min;
    for (int i = 0; i < _data.length; i++) {
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
    if (_data.length == 0) return null;
    Index2D ret;
    double max;
    for (int i = 0; i < _data.length; i++) {
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
    if (_data.length == 0) return;

    if (min != null && max != null) {
      for (int i = 0; i < _data.length; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final double d = _data[i][j];

          if (d < min) _data[i][j] = min;
          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
    if (min != null) {
      for (int i = 0; i < _data.length; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final double d = _data[i][j];

          if (d < min) _data[i][j] = min;
        }
      }
      return;
    }
    if (max != null) {
      for (int j = 0; j < _data.first.length; j++) {
        for (int i = 0; i < _data.length; i++) {
          final double d = _data[i][j];

          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
  }

  IntPair<DoubleArray> pairAt(int index) =>
      intPair<DoubleArray>(index, _data[index]);

  Iterable<IntPair<DoubleArray>> enumerate() => Ranger
      .indices(_data.length)
      .map((i) => intPair<DoubleArray>(i, _data[i]));

  double get mean {
    if (_data.length == 0) return 0.0;

    double sum = 0.0;
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
        final double d = _data[i][j];
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
  DoubleArray get minX {
    if (_data.length == 0) return new DoubleArray.sized(0);

    final ret = new DoubleArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      double min;
      for (int i = 0; i < _data.length; i++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) min = d;
      }
      ret[j] = min;
    }

    return ret;
  }

  /// Minimum along y-axis
  DoubleArray get minY {
    final ret = new DoubleArray.sized(_data.length);
    for (int i = 0; i < _data.length; i++) {
      ret[i] = _data[i].min;
    }
    return ret;
  }

  /// Maximum along x-axis
  DoubleArray get maxX {
    if (_data.length == 0) return new DoubleArray.sized(0);

    final ret = new DoubleArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      double max;
      for (int i = 0; i < _data.length; i++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
      ret[j] = max;
    }

    return ret;
  }

  /// Maximum along y-axis
  DoubleArray get maxY {
    final ret = new DoubleArray.sized(_data.length);
    for (int i = 0; i < _data.length; i++) {
      ret[i] = _data[i].max;
    }
    return ret;
  }

  Double2DArray transpose() {
    final ret = new Double2DArray.sized(_yLength, length);

    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < _data.length; i++) {
        ret[j][i] = _data[i][j];
      }
    }

    return ret;
  }
}
