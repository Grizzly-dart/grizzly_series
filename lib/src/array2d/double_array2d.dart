part of grizzly.series.array2d;

/* TODO
class Double2DArray extends Object
    with IterableMixin<Array<double>>
    implements Numeric2DArray<double> {
  final List<DoubleArray> _data;

  @override
  Iterator<DoubleArray> get iterator => _data.iterator;

  Double2DColumns _cols;

  Double2DColumns get col => _cols ??= new Double2DColumns(this);


  IntPair<DoubleArray> pairAt(int index) =>
      intPair<DoubleArray>(index, _data[index]);

  Iterable<IntPair<DoubleArray>> enumerate() =>
      Ranger.indices(numRows).map((i) => intPair<DoubleArray>(i, _data[i]));
}

class Double2DColumns implements NumericArray2DColumns<double> {
  final Double2DArray inner;

  Double2DColumns(this.inner);

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
*/