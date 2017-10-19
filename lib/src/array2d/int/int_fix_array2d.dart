part of grizzly.series.array2d;

class Int2DFix extends Object
    with IterableMixin<Int1DFix>, Int2DBase
    implements Numeric2DFix<int>, Int2DView {
  final List<Int1DFix> _data;

  Int2DFix(Iterable<Iterable<int>> data) : _data = <Int1D>[] {
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

  Int2DFix.make(this._data);

  Int1DFix firstWhere(covariant bool test(Int1DFix element),
          {covariant Int1DFix orElse()}) =>
      super.firstWhere(test, orElse: orElse);

  Int1DFix lastWhere(covariant bool test(Int1DFix element),
          {covariant Int1DFix orElse()}) =>
      super.lastWhere(test, orElse: orElse);

  Int1DFix reduce(
          covariant Int1DFix combine(
              ArrayFix<int> value, ArrayFix<int> element)) =>
      super.reduce(combine);

  @override
  Iterator<Int1DFix> get iterator => _data.iterator;

  covariant Int2DColFix _col;

  Int2DColFix get col => _col ??= new Int2DColFix(this);

  covariant Int2DRowFix _row;

  Int2DRowFix get row => _row ??= new Int2DRowFix(this);

  Int1DFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<int> val) {
    if (i > numRows) {
      throw new RangeError.range(i, 0, numRows - 1, 'i', 'Out of range!');
    }

    if (numRows == 0) {
      final arr = new Int1D(val);
      _data.add(arr);
      return;
    }

    if (val.length != numCols) {
      throw new Exception('Invalid size!');
    }

    final arr = new Int1D(val);

    if (i == numRows) {
      _data.add(arr);
      return;
    }

    _data[i] = arr;
  }

  /// Sets all elements in the array to given value [v]
  void set(int v) {
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        _data[r][c] = v;
      }
    }
  }

  void clip({int min, int max}) {
    if (numRows == 0) return;

    if (min != null && max != null) {
      for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final int d = _data[i][j];

          if (d < min) _data[i][j] = min;
          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
    if (min != null) {
      for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final int d = _data[i][j];

          if (d < min) _data[i][j] = min;
        }
      }
      return;
    }
    if (max != null) {
      for (int j = 0; j < _data.first.length; j++) {
        for (int i = 0; i < numRows; i++) {
          final int d = _data[i][j];

          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
  }

  Int2DView _view;

  Int2DView get view => _view ??= new Int2DView.make(_data);

  Int2DFix get fixed => this;
}
