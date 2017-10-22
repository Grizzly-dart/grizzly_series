part of grizzly.series.array2d;

class String2DFix extends Object
    with IterableMixin<ArrayFix<String>>, String2DMixin
    implements Array2DFix<String>, String2DView {
  final List<String1DFix> _data;

  String2DFix(Iterable<Iterable<String>> data) : _data = <String1D>[] {
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

  String2DFix.make(this._data);

  Iterator<ArrayFix<String>> get iterator => _data.iterator;

  ArrayFix<String> firstWhere(covariant bool test(String1DFix element),
          {covariant String1DFix orElse()}) =>
      super.firstWhere(test, orElse: orElse);

  ArrayFix<String> lastWhere(covariant bool test(String1DFix element),
          {covariant String1DFix orElse()}) =>
      super.lastWhere(test, orElse: orElse);

  ArrayFix<String> reduce(
          covariant String1DFix combine(
              ArrayView<String> value, ArrayView<String> element)) =>
      super.reduce(combine);

  covariant String2DColFix _col;

  String2DColFix get col => _col ??= new String2DColFix(this);

  covariant String2DRowFix _row;

  String2DRowFix get row => _row ??= new String2DRowFix(this);

  String1DFix operator [](int i) => _data[i].fixed;

  operator []=(final int i, Iterable<String> val) {
    if (i >= numRows) {
      throw new RangeError.range(i, 0, numRows - 1, 'i', 'Out of range!');
    }

    if (numRows == 0) {
      final arr = new String1D(val);
      _data.add(arr);
      return;
    }

    if (val.length != numCols) {
      throw new Exception('Invalid size!');
    }

    final arr = new String1D(val);

    _data[i] = arr;
  }

  /// Sets all elements in the array to given value [v]
  void set(String v) {
    for (int c = 0; c < length; c++) {
      for (int r = 0; r < numCols; r++) {
        _data[c][r] = v;
      }
    }
  }

  String2DView _view;

  String2DView get view => _view ??= new String2DView.make(_data);

  String2DFix get fixed => this;
}
