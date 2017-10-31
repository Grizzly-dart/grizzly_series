part of grizzly.series.array2d;

class String2D extends Object
    with IterableMixin<Array<String>>, String2DMixin
    implements Array2D<String>, String2DFix {
  final List<String1D> _data;

  String2D(Iterable<Iterable<String>> data) : _data = <String1D>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<String> item in data) {
        if (item.length != len) {
          throw new Exception('All rows must have same number of columns!');
        }
      }

      for (Iterable<String> item in data) {
        _data.add(new String1D(item));
      }
    }
  }

  String2D.make(this._data);

  String2D.sized(int numRows, int numCols, {String data: ''})
      : _data = new List<String1D>.generate(
            numRows, (_) => new String1D.sized(numCols, data: data));

  String2D.shaped(Index2D shape, {String data: ''})
      : _data = new List<String1D>.generate(
            shape.row, (_) => new String1D.sized(shape.col, data: data));

  factory String2D.shapedLike(Array2DView like, {String data: ''}) =>
      new String2D.sized(like.numRows, like.numCols, data: data);

  factory String2D.diagonal(Iterable<String> diagonal) {
    final ret = new String2D.sized(diagonal.length, diagonal.length);
    for (int i = 0; i < diagonal.length; i++) {
      ret[i][i] = diagonal.elementAt(i);
    }
    return ret;
  }

  String2D.repeatRow(Iterable<String> row, [int numRows = 1])
      : _data = new List<String1D>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new String1D(row);
    }
  }

  String2D.repeatCol(Iterable<String> column, [int numCols = 1])
      : _data = new List<String1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new String1D.sized(numCols, data: column.elementAt(i));
    }
  }

  String2D.aRow(Iterable<String> row) : _data = new List<String1D>(1) {
    _data[0] = new String1D(row);
  }

  String2D.aCol(Iterable<String> column)
      : _data = new List<String1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new String1D.single(column.elementAt(i));
    }
  }

  /// Create [Int2D] from column major
  factory String2D.columns(Iterable<Iterable<String>> columns) {
    if (columns.length == 0) {
      return new String2D.sized(0, 0);
    }

    if (!columns.every((i) => i.length == columns.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new String2D.sized(columns.first.length, columns.length);
    for (int c = 0; c < ret.numCols; c++) {
      final Iterator<String> col = columns.elementAt(c).iterator;
      col.moveNext();
      for (int r = 0; r < ret.numRows; r++) {
        ret[r][c] = col.current;
        col.moveNext();
      }
    }
    return ret;
  }

  factory String2D.genRows(int numRows, Iterable<String> rowMaker(int index)) {
    final rows = <String1D>[];
    int colLen;
    for (int i = 0; i < numRows; i++) {
      final v = rowMaker(i);
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(new String1D(v));
    }
    return new String2D.make(rows);
  }

  factory String2D.genCols(int numCols, Iterable<String> colMaker(int index)) {
    final List<Iterable<String>> cols = <Iterable<String>>[];
    int rowLen;
    for (int i = 0; i < numCols; i++) {
      final v = colMaker(i);
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new String2D.columns(cols);
  }

  factory String2D.gen(Index2D shape, String maker(int row, int col)) {
    final ret = new String2D.shaped(shape);
    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = maker(r, c);
      }
    }
    return ret;
  }

  static String2D buildRows<T>(
      Iterable<T> iterable, Iterable<String> rowMaker(T v)) {
    final rows = <String1D>[];
    int colLen;
    for (int i = 0; i < iterable.length; i++) {
      final v = rowMaker(iterable.elementAt(i));
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(new String1D(v));
    }
    return new String2D.make(rows);
  }

  static String2D buildCols<T>(
      Iterable<T> iterable, Iterable<String> colMaker(T v)) {
    final List<Iterable<String>> cols = <Iterable<String>>[];
    int rowLen;
    for (int i = 0; i < iterable.length; i++) {
      final v = colMaker(iterable.elementAt(i));
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new String2D.columns(cols);
  }

  static String2D build<T>(Iterable<Iterable<T>> data, String maker(T v)) {
    if (data.length == 0) {
      return new String2D.sized(0, 0);
    }

    if (!data.every((i) => i.length == data.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new String2D.sized(data.length, data.first.length);
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

  Array<String> firstWhere(covariant bool test(String1D element),
          {covariant String1D orElse()}) =>
      super.firstWhere(test, orElse: orElse);

  Array<String> lastWhere(covariant bool test(String1D element),
          {covariant String1D orElse()}) =>
      super.lastWhere(test, orElse: orElse);

  Array<String> reduce(
          covariant String1D combine(
              ArrayView<String> value, ArrayView<String> element)) =>
      super.reduce(combine);

  covariant String2DCol _col;

  String2DCol get col => _col ??= new String2DCol(this);

  covariant String2DRow _row;

  String2DRow get row => _row ??= new String2DRow(this);

  Iterator<String1D> get iterator => _data.iterator;

  String1DFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<String> val) {
    if (i > numRows) {
      throw new RangeError.range(i, 0, numRows - 1, 'i', 'Out of range!');
    }

    if (numRows == 0) {
      final arr = new String1D(val);
      _data.add(arr);
      return;
    }

    if (val.length != numCols) {
      throw new Exception('Invalid size!');
    }

    final arr = new String1D(val);

    if (i == numRows) {
      _data.add(arr);
      return;
    }

    _data[i] = arr;
  }

  /// Sets all elements in the array to given value [v]
  void set(String v) {
    for (int c = 0; c < length; c++) {
      for (int r = 0; r < numCols; r++) {
        _data[c][r] = v;
      }
    }
  }

  @override
  void assign(Array2DView<String> other) {
    if (other.shape != shape)
      throw new ArgumentError.value(other, 'other', 'Size mismatch!');

    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        _data[r][c] = other[r][c];
      }
    }
  }

  @override
  void add(Iterable<String> row) => this[numRows] = row;

  @override
  void addScalar(String v) => this[numRows] = new List.filled(numCols, v);

  @override
  void insert(int index, Iterable<String> row) {
    if (index > numRows) throw new RangeError.range(index, 0, numRows);
    if (row.length != numCols)
      throw new ArgumentError.value(row, 'row', 'Size mismatch!');
    _data.insert(index, new String1D(row));
  }

  @override
  void insertScalar(int index, String v) {
    if (index > numRows) throw new RangeError.range(index, 0, numRows);
    _data.insert(index, new String1D.sized(numCols, data: v));
  }

  String2DView _view;

  String2DView get view => _view ??= new String2DView.make(_data);

  String2DFix _fixed;

  String2DFix get fixed => _fixed ??= new String2DFix.make(_data);
}
