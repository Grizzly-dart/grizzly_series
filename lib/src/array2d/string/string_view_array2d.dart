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
      list.add(_data[c].slice(start.column, end.column));
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
