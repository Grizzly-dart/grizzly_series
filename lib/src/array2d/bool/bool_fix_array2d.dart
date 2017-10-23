part of grizzly.series.array2d;

class Bool2DFix extends Object
    with IterableMixin<ArrayFix<bool>>, Bool2DMixin
    implements Array2DFix<bool>, Bool2DView {
  final List<Bool1DFix> _data;

  Bool2DFix(Iterable<Iterable<bool>> data) : _data = <Bool1D>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<bool> item in data) {
        if (item.length != len) {
          throw new Exception('All rows must have same number of columns!');
        }
      }

      for (Iterable<bool> item in data) {
        _data.add(new Bool1D(item));
      }
    }
  }

  Bool2DFix.make(this._data);

  Bool2DFix.sized(int numRows, int numCols, {bool data: false})
      : _data = new List<Bool1D>.generate(
            numRows, (_) => new Bool1D.sized(numCols, data: data));

  Bool2DFix.shaped(Index2D shape, {bool data: false})
      : _data = new List<Bool1D>.generate(
            shape.row, (_) => new Bool1D.sized(shape.column, data: data));

  factory Bool2DFix.shapedLike(Array2DView like, {bool data: false}) =>
      new Bool2DFix.sized(like.numRows, like.numCols, data: data);

  factory Bool2DFix.diagonal(Iterable<bool> diagonal) {
    final ret = new Bool2DFix.sized(diagonal.length, diagonal.length);
    for (int i = 0; i < diagonal.length; i++) {
      ret[i][i] = diagonal.elementAt(i);
    }
    return ret;
  }

  Bool2DFix.repeatRow(Iterable<bool> row, [int numRows = 1])
      : _data = new List<Bool1D>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Bool1D(row);
    }
  }

  Bool2DFix.repeatColumn(Iterable<bool> column, [int numCols = 1])
      : _data = new List<Bool1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Bool1D.sized(numCols, data: column.elementAt(i));
    }
  }

  Bool2DFix.aRow(Iterable<bool> row) : _data = new List<Bool1D>(1) {
    _data[0] = new Bool1D(row);
  }

  Bool2DFix.aColumn(Iterable<bool> column)
      : _data = new List<Bool1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Bool1D.single(column.elementAt(i));
    }
  }

  /// Create [Int2D] from column major
  factory Bool2DFix.columns(Iterable<Iterable<bool>> columns) {
    if (columns.length == 0) {
      return new Bool2DFix.sized(0, 0);
    }

    if (!columns.every((i) => i.length == columns.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new Bool2DFix.sized(columns.first.length, columns.length);
    for (int c = 0; c < ret.numCols; c++) {
      final Iterator<bool> col = columns.elementAt(c).iterator;
      col.moveNext();
      for (int r = 0; r < ret.numRows; r++) {
        ret[r][c] = col.current;
        col.moveNext();
      }
    }
    return ret;
  }

  factory Bool2DFix.genRows(int numRows, Iterable<bool> rowMaker(int index)) {
    final rows = <Bool1D>[];
    int colLen;
    for (int i = 0; i < numRows; i++) {
      final v = rowMaker(i);
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Bool2DFix.make(rows);
  }

  factory Bool2DFix.genColumns(
      int numCols, Iterable<bool> colMaker(int index)) {
    final List<Iterable<bool>> cols = <Iterable<bool>>[];
    int rowLen;
    for (int i = 0; i < numCols; i++) {
      final v = colMaker(i);
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new Bool2DFix.columns(cols);
  }

  factory Bool2DFix.gen(Index2D shape, bool maker(int row, int col)) {
    final ret = new Bool2DFix.shaped(shape);
    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = maker(r, c);
      }
    }
    return ret;
  }

  static Bool2DFix buildRows<T>(
      Iterable<T> iterable, Iterable<bool> rowMaker(T v)) {
    final rows = <Bool1D>[];
    int colLen;
    for (int i = 0; i < iterable.length; i++) {
      final v = rowMaker(iterable.elementAt(i));
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Bool2DFix.make(rows);
  }

  static Bool2DFix buildColumns<T>(
      Iterable<T> iterable, Iterable<bool> colMaker(T v)) {
    final List<Iterable<bool>> cols = <Iterable<bool>>[];
    int rowLen;
    for (int i = 0; i < iterable.length; i++) {
      final v = colMaker(iterable.elementAt(i));
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new Bool2DFix.columns(cols);
  }

  static Bool2DFix build<T>(Iterable<Iterable<T>> data, bool maker(T v)) {
    if (data.length == 0) {
      return new Bool2DFix.sized(0, 0);
    }

    if (!data.every((i) => i.length == data.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new Bool2DFix.sized(data.length, data.first.length);
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

  Iterator<ArrayFix<bool>> get iterator => _data.iterator;

  ArrayFix<bool> firstWhere(covariant bool test(Bool1DFix element),
          {covariant Bool1DFix orElse()}) =>
      super.firstWhere(test, orElse: orElse);

  ArrayFix<bool> lastWhere(covariant bool test(Bool1DFix element),
          {covariant Bool1DFix orElse()}) =>
      super.lastWhere(test, orElse: orElse);

  ArrayFix<bool> reduce(
          covariant Bool1DFix combine(
              ArrayView<bool> value, ArrayView<bool> element)) =>
      super.reduce(combine);

  covariant Bool2DColFix _col;

  Bool2DColFix get col => _col ??= new Bool2DColFix(this);

  covariant Bool2DRowFix _row;

  Bool2DRowFix get row => _row ??= new Bool2DRowFix(this);

  Bool1DFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<bool> val) {
    if (i >= numRows) {
      throw new RangeError.range(i, 0, numRows - 1, 'i', 'Out of range!');
    }

    if (numRows == 0) {
      final arr = new Bool1D(val);
      _data.add(arr);
      return;
    }

    if (val.length != numCols) {
      throw new Exception('Invalid size!');
    }

    final arr = new Bool1D(val);

    _data[i] = arr;
  }

  /// Sets all elements in the array to given value [v]
  void set(bool v) {
    for (int c = 0; c < length; c++) {
      for (int r = 0; r < numCols; r++) {
        _data[c][r] = v;
      }
    }
  }

  Bool2DView _view;

  Bool2DView get view => _view ??= new Bool2DView.make(_data);

  Bool2DFix get fixed => this;
}
