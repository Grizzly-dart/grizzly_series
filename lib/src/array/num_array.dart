part of grizzly.series.array;

class NumArray extends Object
    with IterableMixin<num>
    implements NumericArray<num> {
  final Float64List _data;

  NumArray(this._data);

  @override
  Iterator<double> get iterator => _data.iterator;

  @override
  num min() {
    num ret;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];

      if (d == null) continue;

      if (ret == null || d < ret) ret = d;
    }
    return ret;
  }

  @override
  num max() {
    num ret;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];

      if (d == null) continue;

      if (ret == null || d > ret) ret = d;
    }
    return ret;
  }

  @override
  Extent<num> extent() {
    num min;
    num max;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];

      if (d == null) continue;

      if (max == null || d > max) max = d;
      if (min == null || d < min) min = d;
    }
    return new Extent(min, max);
  }

  @override
  int argMin() {
    int ret;
    num min;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];

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
    num max;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];

      if (d == null) continue;

      if (max == null || d > max) {
        max = d;
        ret = i;
      }
    }
    return ret;
  }

  @override
  void clip({num min, num max}) {
    if (min != null && max != null) {
      for (int i = 0; i < _data.length; i++) {
        final num d = _data[i];

        if (d < min) _data[i] = min;
        if (d > max) _data[i] = max;
      }
      return;
    }
    if (min != null) {
      for (int i = 0; i < _data.length; i++) {
        final num d = _data[i];

        if (d < min) _data[i] = min;
      }
      return;
    }
    if (max != null) {
      for (int i = 0; i < _data.length; i++) {
        final num d = _data[i];

        if (d > max) _data[i] = max;
      }
      return;
    }
  }

  @override
  num ptp() {
    num min;
    num max;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];

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

    num sum = 0;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];
      if (d == null) continue;
      sum += d;
    }
    return sum / _data.length;
  }

  @override
  num sum() {
    num sum = 0;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];
      if (d == null) continue;
      sum += d;
    }
    return sum;
  }

  @override
  num prod() {
    int prod = 1;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];
      if (d == null) continue;
      prod *= d;
    }
    return prod;
  }

  @override
  NumArray cumsum() {
    final NumArray ret = new NumArray(new Float64List(_data.length));
    num sum = 0;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];
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
  NumArray cumprod() {
	  final NumArray ret = new NumArray(new Float64List(_data.length));
    num prod = 1;
    for (int i = 0; i < _data.length; i++) {
      final num d = _data[i];
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
  	throw new Exception('Unimplemented!');
  }

  @override
  double std() {
	  throw new Exception('Unimplemented!');
  }
}
