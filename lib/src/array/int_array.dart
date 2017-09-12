part of grizzly.series.array;

class IntArray extends Object
    with IterableMixin<int>
    implements NumericArray<int> {
  final Int64List _data;

  IntArray(this._data);

  IntArray.from(Iterable<int> data) : _data = new Int64List.fromList(data);

  IntArray makeFrom(Iterable<int> newData) => new IntArray(newData);

  @override
  Iterator<int> get iterator => _data.iterator;

  @override
  int min() {
    int ret;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];

      if (d == null) continue;

      if (ret == null || d < ret) ret = d;
    }
    return ret;
  }

  @override
  int max() {
    int ret;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];

      if (d == null) continue;

      if (ret == null || d > ret) ret = d;
    }
    return ret;
  }

  @override
  Extent<int> extent() {
    int min;
    int max;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];

      if (d == null) continue;

      if (max == null || d > max) max = d;
      if (min == null || d < min) min = d;
    }
    return new Extent<int>(min, max);
  }

  @override
  int argMin() {
    int ret;
    int min;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];

      if (d == null) continue;

      if (min == null || d < min) {
        min = d;
        ret = i;
      }
    }
    return ret;
  }

  @override
  int argMax() {
    int ret;
    int max;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];

      if (d == null) continue;

      if (max == null || d > max) {
        max = d;
        ret = i;
      }
    }
    return ret;
  }

  @override
  void clip({int min, int max}) {
    if (min != null && max != null) {
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i];

        if (d < min) _data[i] = min;
        if (d > max) _data[i] = max;
      }
      return;
    }
    if (min != null) {
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i];

        if (d < min) _data[i] = min;
      }
      return;
    }
    if (max != null) {
      for (int i = 0; i < _data.length; i++) {
        final int d = _data[i];

        if (d > max) _data[i] = max;
      }
      return;
    }
  }

  IntPair<int> pairAt(int index) => new IntPair<int>(index, _data[index]);

  Iterable<IntPair<int>> enumerate() =>
      Ranger.indices(_data.length).map((i) => intPair<int>(i, _data[i]));

  @override
  int ptp() {
    int min;
    int max;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];

      if (d == null) continue;

      if (max == null || d > max) max = d;
      if (min == null || d < min) min = d;
    }

    if (min == null) return null;
    return max - min;
  }

  @override
  double mean() {
    if (_data.length == 0) return 0.0;

    int sum = 0;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) continue;
      sum += d;
    }
    return sum / _data.length;
  }

  @override
  int sum() {
    int sum = 0;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) continue;
      sum += d;
    }
    return sum;
  }

  @override
  int prod() {
    int prod = 1;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) continue;
      prod *= d;
    }
    return prod;
  }

  @override
  IntArray cumsum() {
    final ret = new IntArray(new Int64List(_data.length));
    int sum = 0;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) {
        _data[i] = sum;
        continue;
      }
      sum += d;
      _data[i] = sum;
    }
    return ret;
  }

  @override
  IntArray cumprod() {
    final ret = new IntArray(new Int64List(_data.length));
    int prod = 1;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) {
        _data[i] = prod;
        continue;
      }
      prod *= d;
      _data[i] = prod;
    }
    return ret;
  }

  @override
  double variance() {
    //TODO
    throw new UnimplementedError();
  }

  @override
  double std() {
    //TODO
    throw new UnimplementedError();
  }

  /// Returns a new  [IntArray] containing first [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  IntArray head([int count = 10]) {
    if (length <= count) return makeFrom(_data);
    return makeFrom(_data.sublist(0, count));
  }

  /// Returns a new  [IntArray] containing last [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  IntArray tail([int count = 10]) {
    if (length <= count) return makeFrom(_data);
    return makeFrom(_data.sublist(length - count));
  }

  /// Returns a new  [Array] containing random [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  IntArray sample([int count = 10]) => makeFrom(_sample<int>(_data, count));
}
