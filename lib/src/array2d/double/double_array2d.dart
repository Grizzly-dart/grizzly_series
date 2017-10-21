part of grizzly.series.array2d;

class Double2D extends Object
    with IterableMixin<Array<double>>, Double2DMixin
    implements Numeric2D<double>, Double2DFix {
  final List<Double1D> _data;

  Double2D(Iterable<Iterable<double>> data) : _data = <Double1D>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<double> item in data) {
        if (item.length != len) {
          throw new Exception('All rows must have same number of columns!');
        }
      }

      for (Iterable<double> item in data) {
        _data.add(new Double1D(item));
      }
    }
  }

  Double2D.make(this._data);

  Double2D.sized(int numRows, int numCols, {double data: 0.0})
      : _data = new List<Double1D>.generate(
            numRows, (_) => new Double1D.sized(numCols, data: data));

  Double2D.shaped(Index2D shape, {double data: 0.0})
      : _data = new List<Double1D>.generate(
            shape.row, (_) => new Double1D.sized(shape.column, data: data));

  factory Double2D.shapedLike(Array2DView like, {double data: 0.0}) =>
      new Double2D.sized(like.numRows, like.numCols, data: data);

  factory Double2D.diagonal(Iterable<double> diagonal) {
    final ret = new Double2D.sized(diagonal.length, diagonal.length);
    for (int i = 0; i < diagonal.length; i++) {
      ret[i][i] = diagonal.elementAt(i);
    }
    return ret;
  }

  Double2D.fromNum(Iterable<Iterable<num>> data) : _data = <Double1D>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<num> item in data) {
        if (item.length != len) {
          throw new Exception('All rows must have same number of columns!');
        }
      }

      for (Iterable<num> item in data) {
        _data.add(new Double1D.fromNum(item));
      }
    }
  }

  Double2D.repeatRow(Iterable<double> row, [int numRows = 1])
      : _data = new List<Double1D>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Double1D(row);
    }
  }

  Double2D.repeatColumn(Iterable<double> column, [int numCols = 1])
      : _data = new List<Double1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Double1D.sized(numCols, data: column.elementAt(i));
    }
  }

  Double2D.aRow(Iterable<double> row) : _data = new List<Double1D>(1) {
    _data[0] = new Double1D(row);
  }

  Double2D.aColumn(Iterable<double> column)
      : _data = new List<Double1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Double1D.single(column.elementAt(i));
    }
  }

  /// Create [Int2D] from column major
  factory Double2D.columns(Iterable<Iterable<double>> columns) {
    if (columns.length == 0) {
      return new Double2D.sized(0, 0);
    }

    if (!columns.every((i) => i.length == columns.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new Double2D.sized(columns.first.length, columns.length);
    for (int c = 0; c < ret.numCols; c++) {
      final Iterator<double> col = columns.elementAt(c).iterator;
      col.moveNext();
      for (int r = 0; r < ret.numRows; r++) {
        ret[r][c] = col.current;
        col.moveNext();
      }
    }
    return ret;
  }

  factory Double2D.genRows(int numRows, Iterable<double> rowMaker(int index)) {
    final rows = <Double1D>[];
    int colLen;
    for (int i = 0; i < numRows; i++) {
      final v = rowMaker(i);
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Double2D.make(rows);
  }

  factory Double2D.genColumns(
      int numCols, Iterable<double> colMaker(int index)) {
    final List<Iterable<double>> cols = <Iterable<double>>[];
    int rowLen;
    for (int i = 0; i < numCols; i++) {
      final v = colMaker(i);
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new Double2D.columns(cols);
  }

  factory Double2D.gen(Index2D shape, double maker(int row, int col)) {
    final ret = new Double2D.shaped(shape);
    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = maker(r, c);
      }
    }
    return ret;
  }

  static Double2D buildRows<T>(
      Iterable<T> iterable, Iterable<double> rowMaker(T v)) {
    final rows = <Double1D>[];
    int colLen;
    for (int i = 0; i < iterable.length; i++) {
      final v = rowMaker(iterable.elementAt(i));
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Double2D.make(rows);
  }

  static Double2D buildColumns<T>(
      Iterable<T> iterable, Iterable<double> colMaker(T v)) {
    final List<Iterable<double>> cols = <Iterable<double>>[];
    int rowLen;
    for (int i = 0; i < iterable.length; i++) {
      final v = colMaker(iterable.elementAt(i));
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new Double2D.columns(cols);
  }

  static Double2D build<T>(Iterable<Iterable<T>> data, double maker(T v)) {
    if (data.length == 0) {
      return new Double2D.sized(0, 0);
    }

    if (!data.every((i) => i.length == data.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new Double2D.sized(data.length, data.first.length);
    for (int r = 0; r < ret.numRows; r++) {
      final Iterator<T> row = data.elementAt(r).iterator;
      row.moveNext();
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = maker(row.current);
        row.moveNext();
      }
    }
    return ret;
  }

  Numeric1D<double> firstWhere(covariant bool test(Double1D element),
          {covariant Double1D orElse()}) =>
      super.firstWhere(test, orElse: orElse);

  Numeric1D<double> lastWhere(covariant bool test(Double1D element),
          {covariant Double1D orElse()}) =>
      super.lastWhere(test, orElse: orElse);

  Numeric1D<double> reduce(
          covariant Double1D combine(
              ArrayView<double> value, ArrayView<double> element)) =>
      super.reduce(combine);

  covariant Double2DCol _col;

  Double2DCol get col => _col ??= new Double2DCol(this);

  covariant Double2DRow _row;

  Double2DRow get row => _row ??= new Double2DRow(this);

  Double1DFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<double> val) {
    if (i > numRows) {
      throw new RangeError.range(i, 0, numRows - 1, 'i', 'Out of range!');
    }

    if (numRows == 0) {
      final arr = new Double1D(val);
      _data.add(arr);
      return;
    }

    if (val.length != numCols) {
      throw new Exception('Invalid size!');
    }

    final arr = new Double1D(val);

    if (i == numRows) {
      _data.add(arr);
      return;
    }

    _data[i] = arr;
  }

  /// Sets all elements in the array to given value [v]
  void set(double v) {
    for (int c = 0; c < length; c++) {
      for (int r = 0; r < numCols; r++) {
        _data[c][r] = v;
      }
    }
  }

  @override
  void add(Iterable<double> row) => this[numRows] = row;

  @override
  void addScalar(double v) => this[numRows] = new List.filled(numCols, v);

  @override
  void insert(int index, Iterable<double> row) {
    if (index > numRows) throw new RangeError.range(index, 0, numRows);
    if (row.length != numCols)
      throw new ArgumentError.value(row, 'row', 'Size mismatch!');
    _data.insert(index, new Double1D(row));
  }

  @override
  void insertScalar(int index, double v) {
    if (index > numRows) throw new RangeError.range(index, 0, numRows);
    _data.insert(index, new Double1D.sized(numCols, data: v));
  }

  Iterator<Double1D> get iterator => _data.iterator;

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

  Double2DView _view;

  Double2DView get view => _view ??= new Double2DView.make(_data);

  Double2DFix _fixed;

  Double2DFix get fixed => _fixed ??= new Double2DFix.make(_data);
}
