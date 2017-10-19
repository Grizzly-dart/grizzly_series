part of grizzly.series.array2d;

class Int2D extends Object
    with IterableMixin<Int1D>, Int2DBase
    implements Numeric2D<int>, Int2DFix {
  final List<Int1D> _data;

  Int2D(Iterable<Iterable<int>> data) : _data = <Int1D>[] {
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

  Int2D.make(this._data);

  Int2D.sized(int rows, int columns, {int data: 0})
      : _data = new List<Int1D>.generate(rows, (_) => new Int1D.sized(columns));

  Int2D.shaped(Index2D shape, {int data: 0})
      : _data = new List<Int1D>.generate(
            shape.row, (_) => new Int1D.sized(shape.column, data: data));

  factory Int2D.shapedLike(Array2D like, {int data: 0}) =>
      new Int2D.sized(like.numCols, like.numRows, data: data);

  Int2D.repeatRow(Iterable<int> row, [int numRows = 1])
      : _data = new List<Int1D>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Int1D(row);
    }
  }

  Int2D.repeatCol(Iterable<int> column, [int numCols = 1])
      : _data = new List<Int1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Int1D.sized(numCols, data: column.elementAt(i));
    }
  }

  Int2D.aRow(Iterable<int> row) : _data = new List<Int1D>(1) {
    _data[0] = new Int1D(row);
  }

  Int2D.aCol(Iterable<int> column) : _data = new List<Int1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Int1D.single(column.elementAt(i));
    }
  }

  /// Create [Int2D] from column major
  factory Int2D.columns(Iterable<Iterable<int>> columns) {
    if (columns.length == 0) {
      return new Int2D.sized(0, 0);
    }

    if (!columns.every((i) => i.length == columns.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new Int2D.sized(columns.first.length, columns.length);
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

  factory Int2D.genRows(int numRows, Iterable<int> rowMaker(int index)) {
    final rows = <Int1D>[];
    int colLen;
    for (int i = 0; i < numRows; i++) {
      final v = rowMaker(i);
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Int2D.make(rows);
  }

  factory Int2D.genColumns(int numCols, Iterable<int> colMaker(int index)) {
    final List<Iterable<int>> cols = <Iterable<int>>[];
    int rowLen;
    for (int i = 0; i < numCols; i++) {
      final v = colMaker(i);
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new Int2D.columns(cols);
  }

  factory Int2D.gen(Index2D shape, int colMaker(int row, int col)) {
    final ret = new Int2D.shaped(shape);
    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = colMaker(r, c);
      }
    }
    return ret;
  }

  static Int2D buildRows<T>(Iterable<T> iterable, Iterable<int> rowMaker(T v)) {
    final rows = <Int1D>[];
    int colLen;
    for (int i = 0; i < iterable.length; i++) {
      final v = rowMaker(iterable.elementAt(i));
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Int2D.make(rows);
  }

  static Int2D buildColumns<T>(
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
    return new Int2D.columns(cols);
  }

  static Int2D build<T>(Iterable<Iterable<T>> data, int colMaker(T v)) {
    if (data.length == 0) {
      return new Int2D.sized(0, 0);
    }

    if (!data.every((i) => i.length == data.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new Int2D.sized(data.length, data.first.length);
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

  Int1D firstWhere(covariant bool test(Int1D element),
          {covariant Int1D orElse()}) =>
      super.firstWhere(test, orElse: orElse);

  Int1D lastWhere(covariant bool test(Int1D element),
          {covariant Int1D orElse()}) =>
      super.lastWhere(test, orElse: orElse);

  Int1D reduce(covariant Int1D combine(Array<int> value, Array<int> element)) =>
      super.reduce(combine);

  @override
  Iterator<Int1D> get iterator => _data.iterator;

  covariant Int2DCol _col;

  Int2DCol get col => _col ??= new Int2DCol(this);

  covariant Int2DRow _row;

  Int2DRow get row => _row ??= new Int2DRow(this);

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
  void add(Iterable<int> row) => this[numRows] = row;

  @override
  void addScalar(int v) => this[numRows] = new List.filled(numCols, v);

  @override
  void insert(int index, Iterable<int> row) {
    // TODO
  }

  @override
  void insertScalar(int index, int v) {
    // TODO
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
  IntPair<Int1D> pairAt(int index) => intPair<Int1D>(index, _data[index]);

  // TODO return lazy
  // TODO return view
  Iterable<IntPair<Int1D>> enumerate() =>
      Ranger.indices(numRows).map((i) => intPair<Int1D>(i, _data[i]));

  Int2D operator +(/* int | Iterable<int> | Numeric2DArray */ other) {
    if (other is int) {
      Int2D ret = new Int2D(this);
      for (int r = 0; r < numRows; r++) {
        for (int c = 0; c < numCols; c++) {
          ret[r][c] += other;
        }
      }
      return ret;
    } else if (other is Iterable<int>) {
      if (other.length != numCols)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Int2D ret = new Int2D(this);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] + other;
      }
      return ret;
    } else if (other is Numeric2D) {
      if (shape != other.shape)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Int2D ret = new Int2D(this);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] + other[r];
      }
      return ret;
    }

    throw new ArgumentError.value(other, 'other', 'Unsupported type!');
  }

  Int2D operator -(/* int | Iterable<int> | Numeric2DArray */ other) {
    if (other is int) {
      Int2D ret = new Int2D(this);
      for (int r = 0; r < numRows; r++) {
        for (int c = 0; c < numCols; c++) {
          ret[r][c] -= other;
        }
      }
      return ret;
    } else if (other is Iterable<int>) {
      if (other.length != numCols)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Int2D ret = new Int2D(this);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] - other;
      }
      return ret;
    } else if (other is Numeric2D) {
      if (shape != other.shape)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Int2D ret = new Int2D(this);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] - other[r];
      }
      return ret;
    }

    throw new ArgumentError.value(other, 'other', 'Unsupported type!');
  }

  Int2D operator *(/* int | Iterable<int> | Numeric2DArray */ other) {
    if (other is int) {
      Int2D ret = new Int2D(this);
      for (int r = 0; r < numRows; r++) {
        for (int c = 0; c < numCols; c++) {
          ret[r][c] *= other;
        }
      }
      return ret;
    } else if (other is Iterable<int>) {
      if (other.length != numCols)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Int2D ret = new Int2D(this);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] * other;
      }
      return ret;
    } else if (other is Numeric2D) {
      return dot(other);
    }

    throw new ArgumentError.value(other, 'other', 'Unsupported type!');
  }

  Int2DView _view;

  Int2DView get view => _view ??= new Int2DView.make(_data);

  Int2DFix _fixed;

  Int2DFix get fixed => _fixed ??= new Int2DFix.make(_data);
}
