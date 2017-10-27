part of grizzly.series.array2d;

class Bool2D extends Object
    with IterableMixin<Array<bool>>, Bool2DMixin
    implements Array2D<bool>, Bool2DFix {
  final List<Bool1D> _data;

  Bool2D(Iterable<Iterable<bool>> data) : _data = <Bool1D>[] {
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

  Bool2D.make(this._data);

  Bool2D.sized(int numRows, int numCols, {bool data: false})
      : _data = new List<Bool1D>.generate(
            numRows, (_) => new Bool1D.sized(numCols, data: data));

  Bool2D.shaped(Index2D shape, {bool data: false})
      : _data = new List<Bool1D>.generate(
            shape.row, (_) => new Bool1D.sized(shape.column, data: data));

  factory Bool2D.shapedLike(Array2DView like, {bool data: false}) =>
      new Bool2D.sized(like.numRows, like.numCols, data: data);

  factory Bool2D.diagonal(Iterable<bool> diagonal) {
    final ret = new Bool2D.sized(diagonal.length, diagonal.length);
    for (int i = 0; i < diagonal.length; i++) {
      ret[i][i] = diagonal.elementAt(i);
    }
    return ret;
  }

  Bool2D.repeatRow(Iterable<bool> row, [int numRows = 1])
      : _data = new List<Bool1D>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Bool1D(row);
    }
  }

  Bool2D.repeatColumn(Iterable<bool> column, [int numCols = 1])
      : _data = new List<Bool1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Bool1D.sized(numCols, data: column.elementAt(i));
    }
  }

  Bool2D.aRow(Iterable<bool> row) : _data = new List<Bool1D>(1) {
    _data[0] = new Bool1D(row);
  }

  Bool2D.aColumn(Iterable<bool> column)
      : _data = new List<Bool1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Bool1D.single(column.elementAt(i));
    }
  }

  /// Create [Int2D] from column major
  factory Bool2D.columns(Iterable<Iterable<bool>> columns) {
    if (columns.length == 0) {
      return new Bool2D.sized(0, 0);
    }

    if (!columns.every((i) => i.length == columns.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new Bool2D.sized(columns.first.length, columns.length);
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

  factory Bool2D.genRows(int numRows, Iterable<bool> rowMaker(int index)) {
    final rows = <Bool1D>[];
    int colLen;
    for (int i = 0; i < numRows; i++) {
      final v = rowMaker(i);
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Bool2D.make(rows);
  }

  factory Bool2D.genColumns(int numCols, Iterable<bool> colMaker(int index)) {
    final List<Iterable<bool>> cols = <Iterable<bool>>[];
    int rowLen;
    for (int i = 0; i < numCols; i++) {
      final v = colMaker(i);
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new Bool2D.columns(cols);
  }

  factory Bool2D.gen(Index2D shape, bool maker(int row, int col)) {
    final ret = new Bool2D.shaped(shape);
    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = maker(r, c);
      }
    }
    return ret;
  }

  static Bool2D buildRows<T>(
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
    return new Bool2D.make(rows);
  }

  static Bool2D buildColumns<T>(
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
    return new Bool2D.columns(cols);
  }

  static Bool2D build<T>(Iterable<Iterable<T>> data, bool maker(T v)) {
    if (data.length == 0) {
      return new Bool2D.sized(0, 0);
    }

    if (!data.every((i) => i.length == data.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new Bool2D.sized(data.length, data.first.length);
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

  Array<bool> firstWhere(covariant bool test(Bool1D element),
          {covariant Bool1D orElse()}) =>
      super.firstWhere(test, orElse: orElse);

  Array<bool> lastWhere(covariant bool test(Bool1D element),
          {covariant Bool1D orElse()}) =>
      super.lastWhere(test, orElse: orElse);

  Array<bool> reduce(
          covariant Bool1D combine(
              ArrayView<bool> value, ArrayView<bool> element)) =>
      super.reduce(combine);

  covariant Bool2DCol _col;

  Bool2DCol get col => _col ??= new Bool2DCol(this);

  covariant Bool2DRow _row;

  Bool2DRow get row => _row ??= new Bool2DRow(this);

  Iterator<Bool1D> get iterator => _data.iterator;

  Bool1DFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<bool> val) {
    if (i > numRows) {
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

    if (i == numRows) {
      _data.add(arr);
      return;
    }

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

  @override
  void assign(Array2DView<bool> other) {
    if (other.shape != shape)
      throw new ArgumentError.value(other, 'other', 'Size mismatch!');

    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        _data[r][c] = other[r][c];
      }
    }
  }

  @override
  void add(Iterable<bool> row) => this[numRows] = row;

  @override
  void addScalar(bool v) => this[numRows] = new List.filled(numCols, v);

  @override
  void insert(int index, Iterable<bool> row) {
    if (index > numRows) throw new RangeError.range(index, 0, numRows);
    if (row.length != numCols)
      throw new ArgumentError.value(row, 'row', 'Size mismatch!');
    _data.insert(index, new Bool1D(row));
  }

  @override
  void insertScalar(int index, bool v) {
    if (index > numRows) throw new RangeError.range(index, 0, numRows);
    _data.insert(index, new Bool1D.sized(numCols, data: v));
  }

  Bool2DView _view;

  Bool2DView get view => _view ??= new Bool2DView.make(_data);

  Bool2DFix _fixed;

  Bool2DFix get fixed => _fixed ??= new Bool2DFix.make(_data);
}
