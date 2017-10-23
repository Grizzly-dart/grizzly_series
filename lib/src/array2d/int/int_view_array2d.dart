part of grizzly.series.array2d;

class Int2DView extends Object
    with IterableMixin<ArrayView<int>>, Int2DBase
    implements Numeric2DView<int> {
  final List<Int1DView> _data;

  Int2DView(Iterable<Iterable<int>> data) : _data = <Int1D>[] {
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

  Int2DView.make(this._data);

  Int2DView.sized(int rows, int columns, {int data: 0})
      : _data = new List<Int1D>.generate(rows, (_) => new Int1D.sized(columns));

  Int2DView.shaped(Index2D shape, {int data: 0})
      : _data = new List<Int1D>.generate(
            shape.row, (_) => new Int1D.sized(shape.column, data: data));

  factory Int2DView.shapedLike(Array2DView like, {int data: 0}) =>
      new Int2DView.sized(like.numCols, like.numRows, data: data);

  Int2DView.repeatRow(Iterable<int> row, [int numRows = 1])
      : _data = new List<Int1D>(numRows) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Int1D(row);
    }
  }

  Int2DView.repeatCol(Iterable<int> column, [int numCols = 1])
      : _data = new List<Int1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Int1D.sized(numCols, data: column.elementAt(i));
    }
  }

  Int2DView.aRow(Iterable<int> row) : _data = new List<Int1D>(1) {
    _data[0] = new Int1D(row);
  }

  Int2DView.aCol(Iterable<int> column)
      : _data = new List<Int1D>(column.length) {
    for (int i = 0; i < length; i++) {
      _data[i] = new Int1D.single(column.elementAt(i));
    }
  }

  /// Create [Int2D] from column major
  factory Int2DView.columns(Iterable<Iterable<int>> columns) {
    if (columns.length == 0) {
      return new Int2DView.sized(0, 0);
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
    return ret.view;
  }

  factory Int2DView.genRows(int numRows, Iterable<int> rowMaker(int index)) {
    final rows = <Int1D>[];
    int colLen;
    for (int i = 0; i < numRows; i++) {
      final v = rowMaker(i);
      if (v == null) continue;
      colLen ??= v.length;
      if (colLen != v.length) throw new Exception('Size mismatch!');
      rows.add(v);
    }
    return new Int2DView.make(rows);
  }

  factory Int2DView.genColumns(int numCols, Iterable<int> colMaker(int index)) {
    final List<Iterable<int>> cols = <Iterable<int>>[];
    int rowLen;
    for (int i = 0; i < numCols; i++) {
      final v = colMaker(i);
      if (v == null) continue;
      rowLen ??= v.length;
      if (rowLen != v.length) throw new Exception('Size mismatch!');
      cols.add(v);
    }
    return new Int2DView.columns(cols);
  }

  factory Int2DView.gen(Index2D shape, int colMaker(int row, int col)) {
    final ret = new Int2D.shaped(shape);
    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = colMaker(r, c);
      }
    }
    return ret.view;
  }

  static Int2DView buildRows<T>(
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
    return new Int2DView.make(rows);
  }

  static Int2DView buildColumns<T>(
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
    return new Int2DView.columns(cols);
  }

  static Int2DView build<T>(Iterable<Iterable<T>> data, int colMaker(T v)) {
    if (data.length == 0) {
      return new Int2DView.sized(0, 0);
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
    return ret.view;
  }

  @override
  Iterator<Int1DView> get iterator => _data.iterator;

  Int2DColView _col;

  Int2DColView get col => _col ??= new Int2DColView(this);

  Int2DRowView _row;

  Int2DRowView get row => _row ??= new Int2DRowView(this);

  Int2DView get view => this;
}

abstract class Int2DBase {
  List<Int1DView> get _data;

  int get length;

  Int2DColView get col;

  Int2DRowView get row;

  Int2DView get view;

  Int2DView makeView(Iterable<Iterable<int>> newData) => new Int2DView(newData);

  Int2DFix makeFix(Iterable<Iterable<int>> newData) => new Int2DFix(newData);

  Int2D make(Iterable<Iterable<int>> newData) => new Int2D(newData);

  int get numCols {
    if (numRows == 0) return 0;
    return _data.first.length;
  }

  int get numRows => length;

  Index2D get shape => new Index2D(numRows, numCols);

  bool get isSquare => numRows == numCols;

  Int1DView operator [](int i) => _data[i];

  Int2D slice(Index2D start, [Index2D end]) {
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

    final list = <Int1D>[];

    for (int c = start.row; c < end.row; c++) {
      list.add(_data[c].slice(start.column, end.column));
    }

    return new Int2D.make(list);
  }

  int get min {
    if (numRows == 0) return null;
    int min;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final int d = _data[i][j];
        if (d == null) continue;
        if (min == null || d < min) min = d;
      }
    }
    return min;
  }

  int get max {
    if (numRows == 0) return null;
    int max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final int d = _data[i][j];
        if (d == null) continue;
        if (max == null || d > max) max = d;
      }
    }
    return max;
  }

  Extent<int> get extent {
    if (numRows == 0) return null;
    int min;
    int max;
    for (int i = 0; i < numRows; i++) {
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
    Index2D ret;
    int min;
    for (int i = 0; i < numRows; i++) {
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
    Index2D ret;
    int max;
    for (int i = 0; i < numRows; i++) {
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

  double get mean {
    if (numRows == 0) return 0.0;
    int sum = 0;
    for (int i = 0; i < numRows; i++) {
      sum += _data[i].sum;
    }
    return sum / (length * numCols);
  }

  double average(Iterable<Iterable<num>> weights) {
    if (weights.length != length)
      throw new ArgumentError.value(weights, 'weights', 'Size mismatch');
    if (numRows == 0) return 0.0;

    final int yL = numCols;

    double sum = 0.0;
    num denom = 0.0;
    for (int i = 0; i < numRows; i++) {
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

  int get sum {
    if (numRows == 0) return 0;
    int sum = 0;
    for (int i = 0; i < numRows; i++) {
      sum += _data[i].sum;
    }
    return sum;
  }

  Int2D dot(Numeric2D other) {
    if (numCols != other.numRows)
      throw new ArgumentError.value(other, 'other', 'Invalid shape!');

    final Int2D ret = new Int2D.sized(numRows, other.numCols);
    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = _data[r].dot(other.col[c]);
      }
    }
    return ret;
  }

  Int2D get transpose {
    final Int2D ret = new Int2D.sized(numCols, length);
    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < numRows; i++) {
        ret[j][i] = _data[i][j];
      }
    }
    return ret;
  }

  Int1D get diagonal {
    int dim = numCols;
    if (dim > numRows) dim = numRows;

    final ret = new Int1D.sized(dim);
    for (int i = 0; i < dim; i++) {
      ret[i] = _data[i][i];
    }
    return ret;
  }

  Double2D get toDouble => new Double2D.fromNum(_data);

  String toString() {
    final sb = new StringBuffer();

    //TODO print as table
    sb.writeln('Int2D[$numRows][$numCols] [');
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

  double get variance {
    if (numRows == 0) return 0.0;
    final double mean = this.mean;
    double sum = 0.0;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        final double v = _data[i][j] - mean;
        sum += v * v;
      }
    }
    return sum / (numRows * numCols);
  }

  double get std => math.sqrt(variance);

  IntSeries<int> valueCounts(
      {bool sortByValue: false,
      bool ascending: false,
      bool dropNull: false,
      dynamic name: ''}) {
    final groups = new Map<int, List<int>>();
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        final int v = _data[r][c];
        if (!groups.containsKey(v)) groups[v] = <int>[0];
        groups[v][0]++;
      }
    }
    final ret = new IntSeries<int>.fromMap(groups, name: name);
    // Sort
    if (sortByValue) {
      ret.sortByIndex(ascending: ascending, inplace: true);
    } else {
      ret.sortByValue(ascending: ascending, inplace: true);
    }
    return ret;
  }

  Double2D get covMatrix {
    final ret = new Double2D.sized(numCols, numCols);
    for (int c = 0; c < numCols; c++) {
      ret[c] = col[c].covMatrix(view);
    }
    return ret;
  }

  Double2D get corrcoefMatrix {
    final ret = new Double2D.sized(numCols, numCols);
    for (int c = 0; c < numCols; c++) {
      ret[c] = col[c].corrcoefMatrix(view);
    }
    return ret;
  }
}
