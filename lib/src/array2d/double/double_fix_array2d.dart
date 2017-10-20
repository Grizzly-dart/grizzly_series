part of grizzly.series.array2d;

class Double2DFix extends Object
    with IterableMixin<ArrayFix<double>>, Double2DMixin
    implements Numeric2DFix<double>, Double2DView {
  final List<Double1DFix> _data;

  Double2DFix(Iterable<Iterable<double>> data) : _data = <Double1D>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<double> item in data) {
        if (item.length != len) {
          throw new Exception('All rows must have same number of columns!');
        }
      }

      for (Iterable<double> item in data) {
        _data.add(new Double1D(item));
      }
    }
  }

  Double2DFix.make(this._data);

  Iterator<Numeric1DFix<double>> get iterator => _data.iterator;

  Numeric1DFix<double> firstWhere(covariant bool test(Double1DFix element),
          {covariant Double1DFix orElse()}) =>
      super.firstWhere(test, orElse: orElse);

  Numeric1DFix<double> lastWhere(covariant bool test(Double1DFix element),
          {covariant Double1DFix orElse()}) =>
      super.lastWhere(test, orElse: orElse);

  Numeric1DFix<double> reduce(
          covariant Double1DFix combine(
              ArrayFix<double> value, ArrayFix<double> element)) =>
      super.reduce(combine);

  covariant Double2DColFix _col;

  Double2DColFix get col => _col ??= new Double2DColFix(this);

  covariant Double2DRowFix _row;

  Double2DRowFix get row => _row ??= new Double2DRowFix(this);

  Double1DFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<double> val) {
    if (i >= numRows) {
      throw new RangeError.range(i, 0, numRows - 1, 'i', 'Out of range!');
    }

    if (numRows == 0) {
      final arr = new Double1D(val);
      _data.add(arr);
      return;
    }

    if (val.length != numCols) {
      throw new Exception('Invalid size!');
    }

    final arr = new Double1D(val);

    _data[i] = arr;
  }

  /// Sets all elements in the array to given value [v]
  void set(double v) {
    for (int c = 0; c < length; c++) {
      for (int r = 0; r < numCols; r++) {
        _data[c][r] = v;
      }
    }
  }

  void clip({double min, double max}) {
    if (numRows == 0) return;

    if (min != null && max != null) {
      for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final double d = _data[i][j];

          if (d < min) _data[i][j] = min;
          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
    if (min != null) {
      for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < _data.first.length; j++) {
          final double d = _data[i][j];

          if (d < min) _data[i][j] = min;
        }
      }
      return;
    }
    if (max != null) {
      for (int j = 0; j < _data.first.length; j++) {
        for (int i = 0; i < numRows; i++) {
          final double d = _data[i][j];

          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
  }

  Double2DView _view;

  Double2DView get view => _view ??= new Double2DView.make(_data);

  Double2DFix get fixed => this;
}
