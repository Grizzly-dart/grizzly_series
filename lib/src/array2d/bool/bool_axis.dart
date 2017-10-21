part of grizzly.series.array2d;

class Bool1DFixLazy extends Bool1DFix {
  Bool1DFixLazy(Bool2DFix inner, int colIndex)
      : super(new ColList<bool>(inner, colIndex));
}

class Bool1DViewLazy extends Bool1DView {
  Bool1DViewLazy(Bool2DView inner, int colIndex)
      : super(new ColList<bool>(inner, colIndex));
}

class Bool2DCol extends Object
    with Bool2DAxisMixin
    implements Axis2D<bool>, Bool2DColFix {
  final Bool2D inner;

  Bool2DCol(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  Bool1DFix operator [](int col) => new Bool1DFixLazy(inner, col);

  operator []=(int index, Iterable<bool> col) {
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

  void add(Iterable<bool> col) {
    if (col.length != inner.numRows)
      throw new ArgumentError.value(col, 'col', 'Size mismatch');
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(col.elementAt(i));
    }
  }

  void addScalar(bool v) {
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(v);
    }
  }

  void insert(int index, Iterable<bool> col) {
    if (col.length != inner.numRows)
      throw new ArgumentError.value(col, 'col', 'Size mismatch');
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].insert(index, col.elementAt(i));
    }
  }

  void insertScalar(int index, bool v) {
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].insert(index, v);
    }
  }
}

class Bool2DColFix extends Object
    with Bool2DAxisMixin
    implements Axis2DFix<bool>, Bool2DColView {
  final Bool2DFix inner;

  Bool2DColFix(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  Bool1DFix operator [](int col) => new Bool1DFixLazy(inner, col);

  operator []=(int index, Iterable<bool> col) {
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

class Bool2DColView extends Object
    with Bool2DAxisMixin
    implements Axis2DView<bool> {
  final Bool2DView inner;

  Bool2DColView(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  Bool1DView operator [](int col) => new Bool1DViewLazy(inner, col);
}

class Bool2DRow extends Object
    with Bool2DAxisMixin
    implements Axis2D<bool>, Bool2DRowFix {
  final Bool2D inner;

  Bool2DRow(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  Bool1DFix operator [](int row) => inner[row];

  operator []=(int index, Iterable<bool> row) => inner[index] = row;

  void add(Iterable<bool> row) => inner.add(row);

  void addScalar(bool v) => inner.addScalar(v);

  void insert(int index, Iterable<bool> row) => inner.insert(index, row);

  void insertScalar(int index, bool v) => inner.insertScalar(index, v);
}

class Bool2DRowFix extends Object
    with Bool2DAxisMixin
    implements Axis2DFix<bool>, Bool2DRowView {
  final Bool2DFix inner;

  Bool2DRowFix(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  Bool1DFix operator [](int row) => inner[row];

  operator []=(int index, Iterable<bool> row) => inner[index] = row;
}

class Bool2DRowView extends Object
    with Bool2DAxisMixin
    implements Axis2DView<bool> {
  final Bool2DView inner;

  Bool2DRowView(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  Bool1DView operator [](int row) => inner[row];
}

abstract class Bool2DAxisMixin implements Axis2DView<bool> {
  Bool1DView operator [](int r);

  Double1D get mean {
    if (length == 0) return new Double1D.sized(0);
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].mean;
    }
    return ret;
  }

  Int1D get sum {
    if (length == 0) return new Int1D.sized(0);
    final ret = new Int1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].sum;
    }
    return ret;
  }

  /// Minimum along y-axis
  Bool1D get min {
    final ret = new Bool1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].min;
    }
    return ret;
  }

  /// Maximum along y-axis
  Bool1D get max {
    final ret = new Bool1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].max;
    }
    return ret;
  }
}
