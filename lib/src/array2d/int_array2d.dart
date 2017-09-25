part of grizzly.series.array2d;

class Int2dArray extends Object
    with IterableMixin<Array<int>>
    implements Array2D<int> {
  final List<IntArray> _data = <IntArray>[];

  Int2dArray.from(Iterable<Iterable<int>> data) {
    if(data.length != 0) {
      final int len = data.first.length;
      for(Iterable<int> item in data) {
        if(item.length != len) {
          throw new Exception('All columns must have same number of rows!');
        }
      }

      for(Iterable<int> item in data) {
        _data.add(new IntArray.from(item));
      }
    }
  }

  Int2dArray makeFrom(Iterable<Iterable<int>> newData) =>
      new Int2dArray.from(newData);

  int get _yLength {
    if (_data.length == 0) return 0;
    return _data.first.length;
  }

  Index2D get shape => new Index2D(_data.length, _yLength);

  // TODO return view
  IntArray operator [](int i) => _data[i];

  operator []=(final int i, Array<int> val) {
    if (i > _data.length) {
      throw new RangeError.range(i, 0, _data.length, 'i', 'Out of range!');
    }

    if (_data.length == 0) {
      final arr = new IntArray.from(val);
      _data.add(arr);
      return;
    }

    if (val.length != _yLength) {
      throw new Exception('Invalid size!');
    }

    final arr = new IntArray.from(val);

    if (i == _data.length) {
      _data.add(arr);
      return;
    }

    _data[i] = arr;
  }

  @override
  Iterator<IntArray> get iterator => _data.iterator;

  @override
  int get min {
    if (_data.length == 0) return null;
    int min;
    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) min = d;
      }
    }
    return min;
  }

  @override
  int get max {
    if (_data.length == 0) return null;
    int max;
    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
    }
    return max;
  }

  Extent<int> get extent {
    if (_data.length == 0) return null;
    int min;
    int max;
    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
        if (min == null || d < min) min = d;
      }
    }
    return new Extent<int>(min, max);
  }

  Index2D get argMin {
    if (_data.length == 0) return null;
    Index2D ret;
    int min;
    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) {
          min = d;
          ret = idx2D(i, j);
        }
      }
    }
    return ret;
  }

  Index2D get argMax {
    if (_data.length == 0) return null;
    Index2D ret;
    int max;
    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) {
          max = d;
          ret = idx2D(i, j);
        }
      }
    }
    return ret;
  }

  void clip({int min, int max}) {
    if (_data.length == 0) return;

    if (min != null && max != null) {
      for (int j = 0; j < _data.first.length; j++) {
        for (int i = 0; i < _data.length; i++) {
          final int d = _data[i][j];

          if (d < min) _data[i][j] = min;
          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
    if (min != null) {
      for (int j = 0; j < _data.first.length; j++) {
        for (int i = 0; i < _data.length; i++) {
          final int d = _data[i][j];

          if (d < min) _data[i][j] = min;
        }
      }
      return;
    }
    if (max != null) {
      for (int j = 0; j < _data.first.length; j++) {
        for (int i = 0; i < _data.length; i++) {
          final int d = _data[i][j];

          if (d > max) _data[i][j] = max;
        }
      }
      return;
    }
  }

  IntPair<IntArray> pairAt(int index) =>
      intPair<IntArray>(index, _data[index]);

  Iterable<IntPair<IntArray>> enumerate() =>
      Ranger.indices(_data.length).map((i) => intPair<IntArray>(i, _data[i]));

  Array2D<int> head([int count = 10]) {
    // TODO
    throw new UnimplementedError();
  }

  Array2D<int> tail([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  Array2D<int> sample([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  /// Minimum along x-axis
  IntArray get minX {
    final ret = new IntArray.sized(_data.length);
    for (int i = 0; i < _data.length; i++) {
      ret[i] = _data[i].min;
    }
    return ret;
  }

  /// Minimum along y-axis
  IntArray get minY {
    if (_data.length == 0) return new IntArray.sized(0);

    final ret = new IntArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      int min;
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) min = d;
      }
      ret[j] = min;
    }

    return ret;
  }

  /// Maximum along x-axis
  IntArray get maxX {
    final ret = new IntArray.sized(_data.length);
    for (int i = 0; i < _data.length; i++) {
      ret[i] = _data[i].max;
    }
    return ret;
  }

  /// Maximum along y-axis
  IntArray get maxY {
    if (_data.length == 0) return new IntArray.sized(0);

    final ret = new IntArray.sized(_data.first.length);

    for (int j = 0; j < _data.first.length; j++) {
      int max;
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
      ret[j] = max;
    }

    return ret;
  }
}
