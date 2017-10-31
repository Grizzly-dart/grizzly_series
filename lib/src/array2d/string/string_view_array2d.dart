part of grizzly.series.array2d;

class String2DView extends Object
    with IterableMixin<ArrayView<String>>, String2DMixin
    implements Array2DView<String> {
  final List<String1DView> _data;

  String2DView(Iterable<Iterable<String>> data) : _data = <String1D>[] {
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

  String2DView.make(this._data);

  String2DView.sized(int numRows, int numCols, {String data: ''})
      : _data = new List<String1D>.generate(
            numRows, (_) => new String1D.sized(numCols, data: data));

  String2DView.shaped(Index2D shape, {String data: ''})
      : _data = new List<String1D>.generate(
            shape.row, (_) => new String1D.sized(shape.col, data: data));

  factory String2DView.shapedLike(Array2DView like, {String data: ''}) =>
      new String2DView.sized(like.numRows, like.numCols, data: data);

  factory String2DView.diagonal(Iterable<String> diagonal) {
    final ret = new String2DFix.sized(diagonal.length, diagonal.length);
    for (int i = 0; i < diagonal.length; i++) {
      ret[i][i] = diagonal.elementAt(i);
    }
    return ret.view;
  }

  String2DView.repeatRow(Iterable<String> row, [int numRows = 1])
      : _data = new List<String1D>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new String1D(row);
    }
  }

  String2DView.repeatCol(Iterable<String> column, [int numCols = 1])
      : _data = new List<String1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new String1D.sized(numCols, data: column.elementAt(i));
    }
  }

  String2DView.aRow(Iterable<String> row) : _data = new List<String1D>(1) {
    _data[0] = new String1D(row);
  }

  String2DView.aCol(Iterable<String> column)
      : _data = new List<String1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new String1D.single(column.elementAt(i));
    }
  }

  /// Create [Int2D] from column major
  factory String2DView.columns(Iterable<Iterable<String>> columns) {
    if (columns.length == 0) {
      return new String2DView.sized(0, 0);
    }

    if (!columns.every((i) => i.length == columns.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new String2DFix.sized(columns.first.length, columns.length);
    for (int c = 0; c < ret.numCols; c++) {
      final Iterator<String> col = columns.elementAt(c).iterator;
      col.moveNext();
      for (int r = 0; r < ret.numRows; r++) {
        ret[r][c] = col.current;
        col.moveNext();
      }
    }
    return ret.view;
  }

  factory String2DView.genRows(
      int numRows, Iterable<String> rowMaker(int index)) {
    final rows = <String1DView>[];
    int colLen;
    for (int i = 0; i < numRows; i++) {
      final v = rowMaker(i);
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(new String1DView(v));
    }
    return new String2DView.make(rows);
  }

  factory String2DView.genCols(
      int numCols, Iterable<String> colMaker(int index)) {
    final List<Iterable<String>> cols = <Iterable<String>>[];
    int rowLen;
    for (int i = 0; i < numCols; i++) {
      final v = colMaker(i);
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new String2DView.columns(cols);
  }

  factory String2DView.gen(Index2D shape, String maker(int row, int col)) {
    final ret = new String2DFix.shaped(shape);
    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = maker(r, c);
      }
    }
    return ret.view;
  }

  static String2DView buildRows<T>(
      Iterable<T> iterable, Iterable<String> rowMaker(T v)) {
    final rows = <String1DView>[];
    int colLen;
    for (int i = 0; i < iterable.length; i++) {
      final v = rowMaker(iterable.elementAt(i));
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(new String1DView(v));
    }
    return new String2DView.make(rows);
  }

  static String2DView buildCols<T>(
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
    return new String2DView.columns(cols);
  }

  static String2DView build<T>(Iterable<Iterable<T>> data, String maker(T v)) {
    if (data.length == 0) {
      return new String2DView.sized(0, 0);
    }

    if (!data.every((i) => i.length == data.first.length)) {
      throw new Exception('Size mismatch!');
    }

    final ret = new String2DFix.sized(data.length, data.first.length);
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

  Iterator<ArrayView<String>> get iterator => _data.iterator;

  covariant String2DColView _col;

  String2DColView get col => _col ??= new String2DColView(this);

  covariant String2DRowView _row;

  String2DRowView get row => _row ??= new String2DRowView(this);

  String2DView get view => this;
}

abstract class String2DMixin implements Array2DView<String> {
  List<String1DView> get _data;

  int get length;

  String2DColView get col;

  String2DRowView get row;

  String2DView get view;

  String2DView makeView(Iterable<Iterable<String>> newData) =>
      new String2DView(newData);

  String2DFix makeFix(Iterable<Iterable<String>> newData) =>
      new String2DFix(newData);

  String2D make(Iterable<Iterable<String>> newData) => new String2D(newData);

  int get numCols {
    if (numRows == 0) return 0;
    return _data.first.length;
  }

  int get numRows => length;

  Index2D get shape => new Index2D(numRows, numCols);

  bool get isSquare => numRows == numCols;

  String1DView operator [](int i) => _data[i].view;

  String2D slice(Index2D start, [Index2D end]) {
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

    final list = <String1D>[];

    for (int c = start.row; c < end.row; c++) {
      list.add(_data[c].slice(start.col, end.col));
    }

    return new String2D.make(list);
  }

  String get min {
    String min;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final String d = _data[i][j];
        if (d == null) continue;
        if (min == null || d.compareTo(min) < 0) min = d;
      }
    }
    return min;
  }

  String get max {
    String max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final String d = _data[i][j];
        if (d == null) continue;
        if (max == null || d.compareTo(max) > 0) max = d;
      }
    }
    return max;
  }

  Index2D get argMin {
    Index2D ret;
    String min;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final String d = _data[i][j];
        if (d == null) continue;
        if (min == null || d.compareTo(min) < 0) {
          min = d;
          ret = idx2D(i, j);
        }
      }
    }
    return ret;
  }

  Index2D get argMax {
    Index2D ret;
    String max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final String d = _data[i][j];
        if (d == null) continue;
        if (max == null || d.compareTo(max) > 0) {
          max = d;
          ret = idx2D(i, j);
        }
      }
    }
    return ret;
  }

  Array2D<String> head([int count = 10]) {
    // TODO
    throw new UnimplementedError();
  }

  Array2D<String> tail([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  Array2D<String> sample([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  String2D get transpose {
    final ret = new String2D.sized(numCols, length);
    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < numRows; i++) {
        ret[j][i] = _data[i][j];
      }
    }
    return ret;
  }

  String1D get diagonal {
    int dim = numCols;
    if (dim > numRows) dim = numRows;

    final ret = new String1D.sized(dim);
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

  IntSeries<String> valueCounts(
      {bool sortByValue: false,
      bool ascending: false,
      bool dropNull: false,
      dynamic name: ''}) {
    final groups = new Map<String, List<int>>();
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        final String v = _data[r][c];
        if (!groups.containsKey(v)) groups[v] = <int>[0];
        groups[v][0]++;
      }
    }
    final ret = new IntSeries<String>.fromMap(groups, name: name);
    // Sort
    if (sortByValue) {
      ret.sortByIndex(ascending: ascending, inplace: true);
    } else {
      ret.sortByValue(ascending: ascending, inplace: true);
    }
    return ret;
  }
}
