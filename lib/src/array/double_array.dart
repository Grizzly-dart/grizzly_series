part of grizzly.series.array;

class DoubleArray extends Object
    with IterableMixin<double>
    implements NumericArray<double> {
  final Float64List _data;

  DoubleArray(this._data);

  DoubleArray.from(Iterable<double> iterable)
      : _data = new Float64List.fromList(iterable);

  DoubleArray makeFrom(Iterable<double> newData) => new DoubleArray(newData);

  @override
  Iterator<double> get iterator => _data.iterator;

  @override
  double min() {
    double ret;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];

      if (d == null) continue;

      if (ret == null || d < ret) ret = d;
    }
    return ret;
  }

  @override
  double max() {
    double ret;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];

      if (d == null) continue;

      if (ret == null || d > ret) ret = d;
    }
    return ret;
  }

  @override
  Extent<double> extent() {
    double min;
    double max;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];

      if (d == null) continue;

      if (max == null || d > max) max = d;
      if (min == null || d < min) min = d;
    }
    return new Extent<double>(min, max);
  }

  @override
  int argMin() {
    int ret;
    double min;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];

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
    double max;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];

      if (d == null) continue;

      if (max == null || d > max) {
        max = d;
        ret = i;
      }
    }
    return ret;
  }

  @override
  void clip({double min, double max}) {
    if (min != null && max != null) {
      for (int i = 0; i < _data.length; i++) {
        final double d = _data[i];

        if (d < min) _data[i] = min;
        if (d > max) _data[i] = max;
      }
      return;
    }
    if (min != null) {
      for (int i = 0; i < _data.length; i++) {
        final double d = _data[i];

        if (d < min) _data[i] = min;
      }
      return;
    }
    if (max != null) {
      for (int i = 0; i < _data.length; i++) {
        final double d = _data[i];

        if (d > max) _data[i] = max;
      }
      return;
    }
  }

  IntPair<double> pairAt(int index) => new IntPair<double>(index, _data[index]);

  Iterable<IntPair<double>> enumerate() =>
      Ranger.indices(_data.length).map((i) => intPair<double>(i, _data[i]));

  @override
  double ptp() {
    double min;
    double max;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];

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

    double sum = 0.0;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];
      if (d == null) continue;
      sum += d;
    }
    return sum / _data.length;
  }

  @override
  double sum() {
    double sum = 0.0;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];
      if (d == null) continue;
      sum += d;
    }
    return sum;
  }

  @override
  double prod() {
    double prod = 1.0;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];
      if (d == null) continue;
      prod *= d;
    }
    return prod;
  }

  @override
  DoubleArray cumsum() {
    final DoubleArray ret = new DoubleArray(new Float64List(_data.length));
    double sum = 0.0;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];
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
  DoubleArray cumprod() {
    final DoubleArray ret = new DoubleArray(new Float64List(_data.length));
    double prod = 1.0;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];
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

  /// Returns a new  [DoubleArray] containing first [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  DoubleArray head([int count = 10]) {
    if (length <= count) return makeFrom(_data);
    return makeFrom(_data.sublist(0, count));
  }

  /// Returns a new  [DoubleArray] containing last [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  DoubleArray tail([int count = 10]) {
    if (length <= count) return makeFrom(_data);
    return makeFrom(_data.sublist(length - count));
  }

  /// Returns a new  [Array] containing random [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  DoubleArray sample([int count = 10]) =>
      makeFrom(_sample<double>(_data, count));
}
