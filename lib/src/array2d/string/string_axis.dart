part of grizzly.series.array2d;

class String1DFixLazy extends String1DFix {
  String1DFixLazy(String2DFix inner, int colIndex)
      : super(new ColList<String>(inner, colIndex));
}

class String1DViewLazy extends String1DView {
  String1DViewLazy(String2DView inner, int colIndex)
      : super(new ColList<String>(inner, colIndex));
}

class String2DCol extends Object
    with String2DAxisMixin
    implements Axis2D<String>, String2DColFix {
  final String2D inner;

  String2DCol(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  String1DFix operator [](int col) => new String1DFixLazy(inner, col);

  operator []=(int index, Iterable<String> col) {
    if (index >= inner.numCols) {
      throw new RangeError.range(index, 0, inner.numCols - 1, 'index');
    }
    if (col.length != inner.numRows) {
      throw new ArgumentError.value(col, 'col', 'Size mismatch!');
    }
    for (int i = 0; i < inner.numRows; i++) {
      inner[i][index] = col.elementAt(i);
    }
  }

  void add(Iterable<String> col) {
    if (col.length != inner.numRows)
      throw new ArgumentError.value(col, 'col', 'Size mismatch');
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(col.elementAt(i));
    }
  }

  void addScalar(String v) {
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(v);
    }
  }

  void insert(int index, Iterable<String> col) {
    if (col.length != inner.numRows)
      throw new ArgumentError.value(col, 'col', 'Size mismatch');
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].insert(index, col.elementAt(i));
    }
  }

  void insertScalar(int index, String v) {
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].insert(index, v);
    }
  }
}

class String2DColFix extends Object
    with String2DAxisMixin
    implements Axis2DFix<String>, String2DColView {
  final String2DFix inner;

  String2DColFix(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  String1DFix operator [](int col) => new String1DFixLazy(inner, col);

  operator []=(int index, Iterable<String> col) {
    if (index >= inner.numCols) {
      throw new RangeError.range(index, 0, inner.numCols - 1, 'index');
    }
    if (col.length != inner.numRows) {
      throw new ArgumentError.value(col, 'col', 'Size mismatch!');
    }
    for (int i = 0; i < inner.numRows; i++) {
      inner[i][index] = col.elementAt(i);
    }
  }
}

class String2DColView extends Object
    with String2DAxisMixin
    implements Axis2DView<String> {
  final String2DView inner;

  String2DColView(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  String1DView operator [](int col) => new String1DViewLazy(inner, col);
}

class String2DRow extends Object
    with String2DAxisMixin
    implements Axis2D<String>, String2DRowFix {
  final String2D inner;

  String2DRow(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  String1DFix operator [](int row) => inner[row];

  operator []=(int index, Iterable<String> row) => inner[index] = row;

  void add(Iterable<String> row) => inner.add(row);

  void addScalar(String v) => inner.addScalar(v);

  void insert(int index, Iterable<String> row) => inner.insert(index, row);

  void insertScalar(int index, String v) => inner.insertScalar(index, v);
}

class String2DRowFix extends Object
    with String2DAxisMixin
    implements Axis2DFix<String>, String2DRowView {
  final String2DFix inner;

  String2DRowFix(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  String1DFix operator [](int row) => inner[row];

  operator []=(int index, Iterable<String> row) => inner[index] = row;
}

class String2DRowView extends Object
    with String2DAxisMixin
    implements Axis2DView<String> {
  final String2DView inner;

  String2DRowView(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  String1DView operator [](int row) => inner[row];
}

abstract class String2DAxisMixin implements Axis2DView<String> {
  String1DView operator [](int r);

  /// Minimum along y-axis
  String1D get min {
    final ret = new String1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].min;
    }
    return ret;
  }

  /// Maximum along y-axis
  String1D get max {
    final ret = new String1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].max;
    }
    return ret;
  }
}
