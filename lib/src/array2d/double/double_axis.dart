part of grizzly.series.array2d;

class Double1DFixLazy extends Double1DFix {
  Double1DFixLazy(Double2DFix inner, int colIndex)
      : super(new ColList<double>(inner, colIndex));
}

class Double1DViewLazy extends Double1DView {
  Double1DViewLazy(Double2DView inner, int colIndex)
      : super(new ColList<double>(inner, colIndex));
}

class Double2DCol extends Object
    with Double2DAxisMixin
    implements Numeric2DAxis<double>, Double2DColFix {
  final Double2D inner;

  Double2DCol(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  Double1DFix operator [](int col) => new Double1DFixLazy(inner, col);

  operator []=(int index, Iterable<double> col) {
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

  void add(Iterable<double> col) {
    if (col.length != inner.numRows)
      throw new ArgumentError.value(col, 'col', 'Size mismatch');
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(col.elementAt(i));
    }
  }

  void addScalar(double v) {
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].add(v);
    }
  }

  void insert(int index, Iterable<double> col) {
    if (col.length != inner.numRows)
      throw new ArgumentError.value(col, 'col', 'Size mismatch');
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].insert(index, col.elementAt(i));
    }
  }

  void insertScalar(int index, double v) {
    for (int i = 0; i < inner.numRows; i++) {
      inner._data[i].insert(index, v);
    }
  }
}

class Double2DColFix extends Object
    with Double2DAxisMixin
    implements Numeric2DAxisFix<double>, Double2DColView {
  final Double2DFix inner;

  Double2DColFix(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  Double1DFix operator [](int col) => new Double1DFixLazy(inner, col);

  operator []=(int index, Iterable<double> col) {
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

class Double2DColView extends Object
    with Double2DAxisMixin
    implements Numeric2DAxisView<double> {
  final Double2DView inner;

  Double2DColView(this.inner);

  int get length => inner.numCols;

  int get otherDLength => inner.numRows;

  Double1DView operator [](int col) => new Double1DViewLazy(inner, col);
}

class Double2DRow extends Object
    with Double2DAxisMixin
    implements Numeric2DAxis<double>, Double2DRowFix {
  final Double2D inner;

  Double2DRow(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  Double1DFix operator [](int row) => inner[row];

  operator []=(int index, Iterable<double> row) => inner[index] = row;

  void add(Iterable<double> row) => inner.add(row);

  void addScalar(double v) => inner.addScalar(v);

  void insert(int index, Iterable<double> row) => inner.insert(index, row);

  void insertScalar(int index, double v) => inner.insertScalar(index, v);
}

class Double2DRowFix extends Object
    with Double2DAxisMixin
    implements Numeric2DAxisFix<double>, Double2DRowView {
  final Double2DFix inner;

  Double2DRowFix(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  Double1DFix operator [](int row) => inner[row];

  operator []=(int index, Iterable<double> row) => inner[index] = row;
}

class Double2DRowView extends Object
    with Double2DAxisMixin
    implements Numeric2DAxisView<double> {
  final Double2DView inner;

  Double2DRowView(this.inner);

  int get length => inner.numRows;

  int get otherDLength => inner.numCols;

  Double1DView operator [](int row) => inner[row];
}

abstract class Double2DAxisMixin implements Numeric2DAxisView<double> {
  Double1D get mean {
    if (length == 0) return new Double1D.sized(0);

    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].mean;
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

  Double1D get sum {
    if (length == 0) return new Double1D.sized(0);

    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].sum;
    }
    return ret;
  }

  /// Minimum along y-axis
  Double1D get min {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].min;
    }
    return ret;
  }

  /// Maximum along y-axis
  Double1D get max {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = this[i].max;
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