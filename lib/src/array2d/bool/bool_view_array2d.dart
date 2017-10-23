part of grizzly.series.array2d;

class Bool2DView extends Object
    with IterableMixin<ArrayView<bool>>, Bool2DMixin
    implements Array2DView<bool> {
  final List<Bool1DView> _data;

  Bool2DView(Iterable<Iterable<bool>> data) : _data = <Bool1D>[] {
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

  Bool2DView.make(this._data);

  Bool2DView.sized(int numRows, int numCols, {bool data: false})
      : _data = new List<Bool1D>.generate(
            numRows, (_) => new Bool1D.sized(numCols, data: data));

  Bool2DView.shaped(Index2D shape, {bool data: false})
      : _data = new List<Bool1D>.generate(
            shape.row, (_) => new Bool1D.sized(shape.column, data: data));

  factory Bool2DView.shapedLike(Array2DView like, {bool data: false}) =>
      new Bool2DView.sized(like.numRows, like.numCols, data: data);

  factory Bool2DView.diagonal(Iterable<bool> diagonal) {
    final ret = new Bool2DFix.sized(diagonal.length, diagonal.length);
    for (int i = 0; i < diagonal.length; i++) {
      ret[i][i] = diagonal.elementAt(i);
    }
    return ret.view;
  }

  Bool2DView.repeatRow(Iterable<bool> row, [int numRows = 1])
      : _data = new List<Bool1D>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Bool1D(row);
    }
  }

  Bool2DView.repeatColumn(Iterable<bool> column, [int numCols = 1])
      : _data = new List<Bool1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Bool1D.sized(numCols, data: column.elementAt(i));
    }
  }

  Bool2DView.aRow(Iterable<bool> row) : _data = new List<Bool1D>(1) {
    _data[0] = new Bool1D(row);
  }

  Bool2DView.aColumn(Iterable<bool> column)
      : _data = new List<Bool1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Bool1D.single(column.elementAt(i));
    }
  }

  /// Create [Int2D] from column major
  factory Bool2DView.columns(Iterable<Iterable<bool>> columns) {
    if (columns.length == 0) {
      return new Bool2DView.sized(0, 0);
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
    return ret.view;
  }

  factory Bool2DView.genRows(int numRows, Iterable<bool> rowMaker(int index)) {
    final rows = <Bool1D>[];
    int colLen;
    for (int i = 0; i < numRows; i++) {
      final v = rowMaker(i);
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Bool2DView.make(rows);
  }

  factory Bool2DView.genColumns(
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
    return new Bool2DView.columns(cols);
  }

  factory Bool2DView.gen(Index2D shape, bool maker(int row, int col)) {
    final ret = new Bool2DFix.shaped(shape);
    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = maker(r, c);
      }
    }
    return ret.view;
  }

  static Bool2DView buildRows<T>(
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
    return new Bool2DView.make(rows);
  }

  static Bool2DView buildColumns<T>(
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
    return new Bool2DView.columns(cols);
  }

  static Bool2DView build<T>(Iterable<Iterable<T>> data, bool maker(T v)) {
    if (data.length == 0) {
      return new Bool2DView.sized(0, 0);
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
    return ret.view;
  }

  Iterator<ArrayView<bool>> get iterator => _data.iterator;

  covariant Bool2DColView _col;

  Bool2DColView get col => _col ??= new Bool2DColView(this);

  covariant Bool2DRowView _row;

  Bool2DRowView get row => _row ??= new Bool2DRowView(this);

  Bool2DView get view => this;
}

abstract class Bool2DMixin implements Array2DView<bool> {
  List<Bool1DView> get _data;

  int get length;

  Bool2DColView get col;

  Bool2DRowView get row;

  Bool2DView get view;

  Bool2DView makeView(Iterable<Iterable<bool>> newData) =>
      new Bool2DView(newData);

  Bool2DFix makeFix(Iterable<Iterable<bool>> newData) => new Bool2DFix(newData);

  Bool2D make(Iterable<Iterable<bool>> newData) => new Bool2D(newData);

  int get numCols {
    if (numRows == 0) return 0;
    return _data.first.length;
  }

  int get numRows => length;

  Index2D get shape => new Index2D(numRows, numCols);

  bool get isSquare => numRows == numCols;

  Bool1DView operator [](int i) => _data[i].view;

  Bool2D slice(Index2D start, [Index2D end]) {
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

    final list = <Bool1D>[];

    for (int c = start.row; c < end.row; c++) {
      list.add(_data[c].slice(start.column, end.column));
    }

    return new Bool2D.make(list);
  }

  bool get min {
    bool min;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final bool d = _data[i][j];
        if (d == null) continue;
        if (!d)
          return false;
        else
          min = true;
      }
    }
    return min;
  }

  bool get max {
    bool max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final bool d = _data[i][j];
        if (d == null) continue;
        if (d)
          return true;
        else
          max = false;
      }
    }
    return max;
  }

  Index2D get argMin {
    Index2D ret;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final bool d = _data[i][j];
        if (d == null) continue;
        if (!d)
          return idx2D(i, j);
        else
          ret ??= idx2D(i, j);
      }
    }
    return ret;
  }

  Index2D get argMax {
    Index2D ret;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final bool d = _data[i][j];
        if (d == null) continue;
        if (d)
          return idx2D(i, j);
        else
          ret ??= idx2D(i, j);
      }
    }
    return ret;
  }

  double get mean {
    if (numRows == 0) return 0.0;
    double sum = 0.0;
    for (int i = 0; i < numRows; i++) {
      sum += _data[i].sum;
    }
    return sum / (numRows * numCols);
  }

  double get sum {
    if (numRows == 0) return 0.0;
    double sum = 0.0;
    for (int i = 0; i < numRows; i++) {
      sum += _data[i].sum;
    }
    return sum;
  }

  Array2D<bool> head([int count = 10]) {
    // TODO
    throw new UnimplementedError();
  }

  Array2D<bool> tail([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  Array2D<bool> sample([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  Bool2D get transpose {
    final ret = new Bool2D.sized(numCols, length);
    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < numRows; i++) {
        ret[j][i] = _data[i][j];
      }
    }
    return ret;
  }

  Bool1D get diagonal {
    int dim = numCols;
    if (dim > numRows) dim = numRows;

    final ret = new Bool1D.sized(dim);
    for (int i = 0; i < dim; i++) {
      ret[i] = _data[i][i];
    }
    return ret;
  }

  String toString() {
    final sb = new StringBuffer();
    //TODO print as table
    sb.writeln('Double[$numRows][$numCols] [');
    for (int r = 0; r < numRows; r++) {
      sb.write('[');
      for (int c = 0; c < numCols; c++) {
        sb.write('${_data[r][c]}\t\t');
      }
      sb.writeln('],');
    }
    sb.writeln(']');

    return sb.toString();
  }

  IntSeries<bool> valueCounts(
      {bool sortByValue: false,
      bool ascending: false,
      bool dropNull: false,
      dynamic name: ''}) {
    final groups = new Map<bool, List<int>>();
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        final bool v = _data[r][c];
        if (!groups.containsKey(v)) groups[v] = <int>[0];
        groups[v][0]++;
      }
    }
    final ret = new IntSeries<bool>.fromMap(groups, name: name);
    // Sort
    if (sortByValue) {
      ret.sortByIndex(ascending: ascending, inplace: true);
    } else {
      ret.sortByValue(ascending: ascending, inplace: true);
    }
    return ret;
  }

  bool get allTrue {
    for (int i = 0; i < length; i++) {
      if (!_data[i].allTrue) return false;
    }
    return true;
  }

  bool get allFalse {
    for (int i = 0; i < length; i++) {
      if (!_data[i].allFalse) return false;
    }
    return true;
  }

  bool get anyTrue {
    for (int i = 0; i < length; i++) {
      if (_data[i].anyTrue) return true;
    }
    return false;
  }

  bool get anyFalse {
    for (int i = 0; i < length; i++) {
      if (_data[i].anyFalse) return true;
    }
    return false;
  }
}
