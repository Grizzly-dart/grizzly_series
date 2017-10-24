part of grizzly.series.array2d;

class Int2DFix extends Object
    with IterableMixin<Int1DFix>, Int2DBase
    implements Numeric2DFix<int>, Int2DView {
  final List<Int1DFix> _data;

  Int2DFix(Iterable<Iterable<int>> data) : _data = <Int1D>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<int> item in data) {
        if (item.length != len) {
          throw new Exception('All rows must have same number of columns!');
        }
      }

      for (Iterable<int> item in data) {
        _data.add(new Int1D(item));
      }
    }
  }

  Int2DFix.make(this._data);

  Int2DFix.sized(int rows, int columns, {int data: 0})
      : _data = new List<Int1D>.generate(rows, (_) => new Int1D.sized(columns));

  Int2DFix.shaped(Index2D shape, {int data: 0})
      : _data = new List<Int1D>.generate(
            shape.row, (_) => new Int1D.sized(shape.column, data: data));

  factory Int2DFix.shapedLike(Array2DView like, {int data: 0}) =>
      new Int2DFix.sized(like.numRows, like.numCols, data: data);

  Int2DFix.repeatRow(Iterable<int> row, [int numRows = 1])
      : _data = new List<Int1D>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Int1D(row);
    }
  }

  Int2DFix.repeatCol(Iterable<int> column, [int numCols = 1])
      : _data = new List<Int1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Int1D.sized(numCols, data: column.elementAt(i));
    }
  }

  Int2DFix.aRow(Iterable<int> row) : _data = new List<Int1D>(1) {
    _data[0] = new Int1D(row);
  }

  Int2DFix.aCol(Iterable<int> column) : _data = new List<Int1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Int1D.single(column.elementAt(i));
    }
  }

  /// Create [Int2D] from column major
  factory Int2DFix.columns(Iterable<Iterable<int>> columns) {
    if (columns.length == 0) {
      return new Int2DFix.sized(0, 0);
    }

    if (!columns.every((i) => i.length == columns.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new Int2DFix.sized(columns.first.length, columns.length);
    for (int c = 0; c < ret.numCols; c++) {
      final Iterator<int> col = columns.elementAt(c).iterator;
      col.moveNext();
      for (int r = 0; r < ret.numRows; r++) {
        ret[r][c] = col.current;
        col.moveNext();
      }
    }
    return ret;
  }

  factory Int2DFix.genRows(int numRows, Iterable<int> rowMaker(int index)) {
    final rows = <Int1D>[];
    int colLen;
    for (int i = 0; i < numRows; i++) {
      final v = rowMaker(i);
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Int2DFix.make(rows);
  }

  factory Int2DFix.genColumns(int numCols, Iterable<int> colMaker(int index)) {
    final List<Iterable<int>> cols = <Iterable<int>>[];
    int rowLen;
    for (int i = 0; i < numCols; i++) {
      final v = colMaker(i);
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new Int2DFix.columns(cols);
  }

  factory Int2DFix.gen(Index2D shape, int colMaker(int row, int col)) {
    final ret = new Int2DFix.shaped(shape);
    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = colMaker(r, c);
      }
    }
    return ret;
  }

  static Int2DFix buildRows<T>(
      Iterable<T> iterable, Iterable<int> rowMaker(T v)) {
    final rows = <Int1D>[];
    int colLen;
    for (int i = 0; i < iterable.length; i++) {
      final v = rowMaker(iterable.elementAt(i));
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Int2DFix.make(rows);
  }

  static Int2DFix buildColumns<T>(
      Iterable<T> iterable, Iterable<int> colMaker(T v)) {
    final List<Iterable<int>> cols = <Iterable<int>>[];
    int rowLen;
    for (int i = 0; i < iterable.length; i++) {
      final v = colMaker(iterable.elementAt(i));
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new Int2DFix.columns(cols);
  }

  static Int2DFix build<T>(Iterable<Iterable<T>> data, int colMaker(T v)) {
    if (data.length == 0) {
      return new Int2DFix.sized(0, 0);
    }

    if (!data.every((i) => i.length == data.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new Int2DFix.sized(data.length, data.first.length);
    for (int r = 0; r < ret.numRows; r++) {
      final Iterator<T> row = data.elementAt(r).iterator;
      row.moveNext();
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = colMaker(row.current);
        row.moveNext();
      }
    }
    return ret;
  }

  Int1DFix firstWhere(covariant bool test(Int1DFix element),
          {covariant Int1DFix orElse()}) =>
      super.firstWhere(test, orElse: orElse);

  Int1DFix lastWhere(covariant bool test(Int1DFix element),
          {covariant Int1DFix orElse()}) =>
      super.lastWhere(test, orElse: orElse);

  Int1DFix reduce(
          covariant Int1DFix combine(
              ArrayView<int> value, ArrayView<int> element)) =>
      super.reduce(combine);

  @override
  Iterator<Int1DFix> get iterator => _data.iterator;

  covariant Int2DColFix _col;

  Int2DColFix get col => _col ??= new Int2DColFix(this);

  covariant Int2DRowFix _row;

  Int2DRowFix get row => _row ??= new Int2DRowFix(this);

  Int1DFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<int> val) {
    if (i > numRows) {
      throw new RangeError.range(i, 0, numRows - 1, 'i', 'Out of range!');
    }

    if (numRows == 0) {
      final arr = new Int1D(val);
      _data.add(arr);
      return;
    }

    if (val.length != numCols) {
      throw new Exception('Invalid size!');
    }

    final arr = new Int1D(val);

    if (i == numRows) {
      _data.add(arr);
      return;
    }

    _data[i] = arr;
  }

  /// Sets all elements in the array to given value [v]
  void set(int v) {
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        _data[r][c] = v;
      }
    }
  }

  @override
  void assign(Array2DView<int> other) {
    if (other.shape != shape)
      throw new ArgumentError.value(other, 'other', 'Size mismatch!');

    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        _data[r][c] = other[r][c];
      }
    }
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

  Int2DView _view;

  Int2DView get view => _view ??= new Int2DView.make(_data);

  Int2DFix get fixed => this;
}
