part of grizzly.series.array2d;

class ColList<T> extends Object with ListMixin<T> implements List<T> {
  final Array2DView<T> inner;

  final int colIdx;

  ColList(this.inner, this.colIdx);

  @override
  T operator [](int index) => inner[index][colIdx];

  @override
  void operator []=(int index, T value) {
    // TODO check range
    if (inner is Array2DFix<T>) {
      (inner as Array2DFix<T>)[index][colIdx] = value;
    } else {
      throw new UnsupportedError('Array2DView is not modifiable!');
    }
  }

  @override
  int get length => inner.numRows;

  @override
  set length(int newLength) {
    throw new UnsupportedError('Changing lenght not supported!');
  }
}

class Int1DFixLazy extends Int1DFix {
  Int1DFixLazy(Int2DFix inner, int colIndex)
      : super(new ColList<int>(inner, colIndex));
}

class Int1DViewLazy extends Int1DView {
  Int1DViewLazy(Int2DView inner, int colIndex)
      : super(new ColList<int>(inner, colIndex));
}

class Int2DCol extends Object
    with IntAxis2DViewMixin
    implements Numeric2DAxis<int>, Int2DColFix {
  final Int2D inner;

  Int2DCol(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  Int1DFix operator [](int col) => new Int1DFixLazy(inner, col);

  operator []=(int index, Iterable<int> col) {
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

  void add(Iterable<int> col) {
    if (col.length != inner.numRows)
      throw new ArgumentError.value(col, 'col', 'Size mismatch');
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(col.elementAt(i));
    }
  }

  void addScalar(int v) {
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(v);
    }
  }

  void insert(int index, Iterable<int> col) {
    if (col.length != inner.numRows)
      throw new ArgumentError.value(col, 'col', 'Size mismatch');
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].insert(index, col.elementAt(i));
    }
  }

  void insertScalar(int index, int v) {
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].insert(index, v);
    }
  }
}

class Int2DColFix extends Object
    with IntAxis2DViewMixin
    implements Numeric2DAxisFix<int>, Int2DColView {
  final Int2DFix inner;

  Int2DColFix(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  Int1DFix operator [](int col) => new Int1DFixLazy(inner, col);

  operator []=(int index, Iterable<int> col) {
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

class Int2DColView extends Object
    with IntAxis2DViewMixin
    implements Numeric2DAxisView<int> {
  final Int2DView inner;

  Int2DColView(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  Int1DView operator [](int col) => new Int1DViewLazy(inner, col);
}

class Int2DRow extends Object
    with IntAxis2DViewMixin
    implements Numeric2DAxis<int>, Int2DRowFix {
  final Int2D inner;

  Int2DRow(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  Int1DFix operator [](int row) => inner[row];

  operator []=(int index, Iterable<int> row) => inner[index] = row;

  void add(Iterable<int> row) => inner.add(row);

  void addScalar(int v) => inner.addScalar(v);

  void insert(int index, Iterable<int> row) => inner.insert(index, row);

  void insertScalar(int index, int v) => inner.insertScalar(index, v);
}

class Int2DRowFix extends Object
    with IntAxis2DViewMixin
    implements Numeric2DAxisFix<int>, Int2DRowView {
  final Int2DFix inner;

  Int2DRowFix(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  Int1DFix operator [](int row) => inner[row];

  operator []=(int index, Iterable<int> row) => inner[index] = row;
}

class Int2DRowView extends Object
    with IntAxis2DViewMixin
    implements Numeric2DAxisView<int> {
  final Int2DView inner;

  Int2DRowView(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  Int1DView operator [](int row) => inner[row];
}

abstract class IntAxis2DViewMixin implements Numeric2DAxisView<int> {
  /// Minimum along y-axis
  Int1D get min {
    final ret = new Int1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].min;
    }
    return ret;
  }

  /// Maximum along y-axis
  Int1D get max {
    final ret = new Int1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].max;
    }
    return ret;
  }

  Double1D get mean {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].mean;
    }
    return ret;
  }

  Int1D get sum {
    final ret = new Int1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].sum;
    }
    return ret;
  }

  Double1D average(Iterable<num> weights) {
    if (length == 0) return new Double1D.sized(0);

    if (weights.length != otherDLength) {
      throw new Exception('Weights have mismatching length!');
    }

    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].average(weights);
    }
    return ret;
  }

  Double1D get std {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].std;
    }
    return ret;
  }

  Double1D get variance {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].variance;
    }
    return ret;
  }
}
