part of grizzly.series.array2d;

class Bool2DFix extends Object
    with IterableMixin<ArrayFix<bool>>, Bool2DMixin
    implements Array2DFix<bool>, Bool2DView {
  final List<Bool1DFix> _data;

  Bool2DFix(Iterable<Iterable<bool>> data) : _data = <Bool1D>[] {
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

  Bool2DFix.make(this._data);

  Iterator<ArrayFix<bool>> get iterator => _data.iterator;

  ArrayFix<bool> firstWhere(covariant bool test(Bool1DFix element),
          {covariant Bool1DFix orElse()}) =>
      super.firstWhere(test, orElse: orElse);

  ArrayFix<bool> lastWhere(covariant bool test(Bool1DFix element),
          {covariant Bool1DFix orElse()}) =>
      super.lastWhere(test, orElse: orElse);

  ArrayFix<bool> reduce(
          covariant Bool1DFix combine(
              ArrayView<bool> value, ArrayView<bool> element)) =>
      super.reduce(combine);

  covariant Bool2DColFix _col;

  Bool2DColFix get col => _col ??= new Bool2DColFix(this);

  covariant Bool2DRowFix _row;

  Bool2DRowFix get row => _row ??= new Bool2DRowFix(this);

  Bool1DFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<bool> val) {
    if (i >= numRows) {
      throw new RangeError.range(i, 0, numRows - 1, 'i', 'Out of range!');
    }

    if (numRows == 0) {
      final arr = new Bool1D(val);
      _data.add(arr);
      return;
    }

    if (val.length != numCols) {
      throw new Exception('Invalid size!');
    }

    final arr = new Bool1D(val);

    _data[i] = arr;
  }

  /// Sets all elements in the array to given value [v]
  void set(bool v) {
    for (int c = 0; c < length; c++) {
      for (int r = 0; r < numCols; r++) {
        _data[c][r] = v;
      }
    }
  }

  Bool2DView _view;

  Bool2DView get view => _view ??= new Bool2DView.make(_data);

  Bool2DFix get fixed => this;
}
