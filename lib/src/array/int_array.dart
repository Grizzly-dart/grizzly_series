part of grizzly.series.array;

class IntArray extends Object
    with IterableMixin<int>
    implements NumericArray<int>, Array<int> {
  final Int64List _data;

  IntArray(this._data);

  IntArray.sized(int length, {int data: 0}) : _data = new Int64List(length) {
    for (int i = 0; i < length; i++) {
      _data[i] = data;
    }
  }

  IntArray.single(int data) : _data = new Int64List(1) {
    _data[0] = data;
  }

  IntArray.from(Iterable<int> data) : _data = new Int64List.fromList(data);

  IntArray makeFrom(Iterable<int> newData) => new IntArray(newData);

  @override
  Iterator<int> get iterator => _data.iterator;

  Index1D get shape => new Index1D(_data.length);

  int operator [](int i) => _data[i];

  operator []=(int i, int val) {
    if (i > _data.length) {
      throw new RangeError.range(i, 0, _data.length, 'i', 'Out of range!');
    }

    if (i == _data.length) {
      _data.add(val);
      return;
    }

    _data[i] = val;
  }

  bool operator ==(other) {
    if (other is! Array<int>) return false;

    if (other is Array<int>) {
      if (length != other.length) return false;

      for (int i = 0; i < length; i++) {
        if (_data[i] != other[i]) return false;
      }

      return true;
    }

    return false;
  }

  void add(int a) {
    _data.add(a);
  }

  @override
  int get min {
    int ret;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];

      if (d == null) continue;

      if (ret == null || d < ret) ret = d;
    }
    return ret;
  }

  @override
  int get max {
    int ret;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];

      if (d == null) continue;

      if (ret == null || d > ret) ret = d;
    }
    return ret;
  }

  @override
  Extent<int> get extent {
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
  int get argMin {
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
  int get argMax {
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

  IntPair<int> pairAt(int index) => intPair<int>(index, _data[index]);

  Iterable<IntPair<int>> enumerate() =>
      Ranger.indices(_data.length).map((i) => intPair<int>(i, _data[i]));

  @override
  int get ptp {
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
  double get mean {
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
  int get sum {
    int sum = 0;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) continue;
      sum += d;
    }
    return sum;
  }

  @override
  int get prod {
    int prod = 1;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) continue;
      prod *= d;
    }
    return prod;
  }

  double average(Iterable<num> weights) {
    if (weights.length != length) {
      throw new Exception('Weights have mismatching length!');
    }
    if (_data.length == 0) return 0.0;

    double sum = 0.0;
    num denom = 0.0;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      final num w = weights.elementAt(i);
      if (d == null) continue;
      if (w == null) continue;
      sum += d * w;
      denom += w;
    }
    return sum / denom;
  }

  @override
  IntArray get cumsum {
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
  IntArray get cumprod {
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
  double get variance {
    //TODO
    throw new UnimplementedError();
  }

  @override
  double get std {
    //TODO
    throw new UnimplementedError();
  }

  IntArray operator +(/* num | Iterable<num> */ other) {
    if (other is IntArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is int) {
      // Nothing here
    } else if (other is num) {
      other = other.toInt();
    } else if (other is Iterable<int>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new IntArray.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new IntArray.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    final ret = new IntArray.sized(length);
    if (other is int) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other;
      }
    } else if (other is IntArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other[i];
      }
    }
    return ret;
  }

  IntArray addition(/* int | Iterable<int> */ other, {bool copy: false}) {
    if (copy) return this + other;

    if (other is IntArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is int) {
      // Nothing here
    } else if (other is num) {
      other = other.toInt();
    } else if (other is Iterable<int>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        _data[i] += other.elementAt(i);
      }
      return this;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        _data[i] += other.elementAt(i).toInt();
      }
      return this;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is int) {
      for (int i = 0; i < length; i++) {
        _data[i] += other;
      }
    } else if (other is IntArray) {
      for (int i = 0; i < length; i++) {
        _data[i] += other[i];
      }
    }
    return this;
  }

  IntArray operator -(/* int | Iterable<int> */ other) {
    if (other is IntArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is int) {
      // Nothing here
    } else if (other is num) {
      other = other.toInt();
    } else if (other is Iterable<int>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new IntArray.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new IntArray.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    final ret = new IntArray.sized(length);
    if (other is int) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other;
      }
    } else if (other is IntArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other[i];
      }
    }
    return ret;
  }

  IntArray subtract(/* int | Iterable<int> */ other, {bool copy: false}) {
    if (copy) return this - other;

    if (other is IntArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is int) {
      // Nothing here
    } else if (other is num) {
      other = other.toInt();
    } else if (other is Iterable<int>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        _data[i] -= other.elementAt(i);
      }
      return this;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        _data[i] -= other.elementAt(i).toInt();
      }
      return this;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is int) {
      for (int i = 0; i < length; i++) {
        _data[i] -= other;
      }
    } else if (other is IntArray) {
      for (int i = 0; i < length; i++) {
        _data[i] -= other[i];
      }
    }
    return this;
  }

  IntArray operator *(/* int | Iterable<int> */ other) {
    if (other is IntArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is int) {
      // Nothing here
    } else if (other is num) {
      other = other.toInt();
    } else if (other is Iterable<int>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new IntArray.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new IntArray.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    final ret = new IntArray.sized(length);
    if (other is int) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other;
      }
    } else if (other is IntArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other[i];
      }
    }
    return ret;
  }

  IntArray multiple(/* int | Iterable<int> */ other, {bool copy: false}) {
    if (copy) return this * other;

    if (other is IntArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is int) {
      // Nothing here
    } else if (other is num) {
      other = other.toInt();
    } else if (other is Iterable<int>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        _data[i] *= other.elementAt(i);
      }
      return this;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        _data[i] *= other.elementAt(i).toInt();
      }
      return this;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is int) {
      for (int i = 0; i < length; i++) {
        _data[i] *= other;
      }
    } else if (other is IntArray) {
      for (int i = 0; i < length; i++) {
        _data[i] *= other[i];
      }
    }
    return this;
  }

  DoubleArray operator /(/* int | Iterable<int> */ other) {
    if (other is IntArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is int) {
      // Nothing here
    } else if (other is num) {
      other = other;
    } else if (other is Iterable<int>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new DoubleArray.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new DoubleArray.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other.elementAt(i);
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    final ret = new DoubleArray.sized(length);
    if (other is int) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other;
      }
    } else if (other is IntArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other[i];
      }
    }
    return ret;
  }

  NumericArray<double> divide(/* E | Iterable<E> */ other, {bool copy: false}) {
    if (copy) return this / other;

    throw new Exception('Operation not supported!');
  }

  IntArray operator ~/(/* int | Iterable<int> */ other) {
    if (other is IntArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is int) {
      // Nothing here
    } else if (other is num) {
      other = other.toInt();
    } else if (other is Iterable<int>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new IntArray.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new IntArray.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    final ret = new IntArray.sized(length);
    if (other is int) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other;
      }
    } else if (other is IntArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other[i];
      }
    }
    return ret;
  }

  IntArray truncDiv(/* int | Iterable<int> */ other, {bool copy: false}) {
    if (copy) return this ~/ other;

    if (other is IntArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is int) {
      // Nothing here
    } else if (other is num) {
      other = other.toInt();
    } else if (other is Iterable<int>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        _data[i] ~/= other.elementAt(i);
      }
      return this;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        _data[i] ~/= other.elementAt(i).toInt();
      }
      return this;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is int) {
      for (int i = 0; i < length; i++) {
        _data[i] ~/= other;
      }
    } else if (other is IntArray) {
      for (int i = 0; i < length; i++) {
        _data[i] ~/= other[i];
      }
    }
    return this;
  }

  DoubleArray toDouble() {
    final ret = new DoubleArray.sized(length);

    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].toDouble();
    }

    return ret;
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

  Int2DArray to2D() => new Int2DArray.from([_data]);

  Int2DArray repeat({int repeat: 1, bool transpose: false}) {
    if (!transpose) {
      return new Int2DArray.columns(_data, repeat + 1);
    } else {
      return new Int2DArray.rows(_data, repeat + 1);
    }
  }

  Int2DArray transpose() {
    final ret = new Int2DArray.sized(length, 1);

    for (int i = 0; i < length; i++) {
      ret[i][0] = _data[i];
    }

    return ret;
  }
}
