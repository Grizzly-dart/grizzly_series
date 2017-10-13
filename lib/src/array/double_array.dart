part of grizzly.series.array;

class DoubleArray extends DoubleArrayFix implements NumericArray<double> {
  DoubleArray(Iterable<double> data) : super(data);

  DoubleArray.sized(int length, {double data: 0.0})
      : super.sized(length, data: data);

  DoubleArray.single(double data) : super.single(data);

  DoubleArray.make(Iterable<double> iterable) : super.make(iterable);

  factory DoubleArray.fromNum(Iterable<num> iterable) {
    final list = new Float64List(iterable.length);

    final Iterator<num> ite = iterable.iterator;
    ite.moveNext();

    for (int i = 0; i < list.length; i++) {
      list[i] = ite.current.toDouble();
      ite.moveNext();
    }

    return new DoubleArray.make(list);
  }

  operator []=(int i, double val) {
    if (i > _data.length) {
      throw new RangeError.range(i, 0, _data.length, 'i', 'Out of range!');
    }

    if (i == _data.length) {
      _data.add(val);
      return;
    }

    _data[i] = val;
  }

  void add(double a) {
    _data.add(a);
  }

  DoubleArrayFix get fixed => new DoubleArrayFix.make(_data);
}

class DoubleArrayFix extends DoubleArrayView
    implements NumericArrayFix<double> {
  DoubleArrayFix(Iterable<double> data) : super(data);

  DoubleArrayFix.sized(int length, {double data: 0.0})
      : super.sized(length, data: data);

  DoubleArrayFix.single(double data) : super.single(data);

  DoubleArrayFix.make(Iterable<double> iterable) : super.make(iterable);

  factory DoubleArrayFix.fromNum(Iterable<num> iterable) {
    final list = new Float64List(iterable.length);

    final Iterator<num> ite = iterable.iterator;
    ite.moveNext();

    for (int i = 0; i < list.length; i++) {
      list[i] = ite.current.toDouble();
      ite.moveNext();
    }

    return new DoubleArrayFix.make(list);
  }

  operator []=(int i, double val) {
    if (i >= _data.length) {
      throw new RangeError.range(i, 0, _data.length, 'i', 'Out of range!');
    }

    _data[i] = val;
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

  DoubleArray addition(/* num | Iterable<num> */ other, {bool self: false}) {
    DoubleArray ret = this;

    if (!self) ret = new DoubleArray.sized(length);

    if (other is NumericArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is num) {
      // Nothing here
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other.elementAt(i);
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is num) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other;
      }
    } else if (other is DoubleArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other[i];
      }
    }
    return ret;
  }

  DoubleArray subtract(/* num | Iterable<num> */ other, {bool self: false}) {
    DoubleArray ret = this;

    if (!self) ret = new DoubleArray.sized(length);

    if (other is NumericArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is num) {
      // Nothing here
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other.elementAt(i);
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is num) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other;
      }
    } else if (other is NumericArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other[i];
      }
    }
    return ret;
  }

  DoubleArray multiple(/* num | Iterable<num> */ other, {bool self: false}) {
    DoubleArray ret = this;

    if (!self) ret = new DoubleArray.sized(length);

    if (other is NumericArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is num) {
      // Nothing here
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other.elementAt(i);
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is num) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other;
      }
    } else if (other is NumericArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other[i];
      }
    }
    return ret;
  }

  DoubleArray divide(/* E | Iterable<E> */ other, {bool self: false}) {
    DoubleArray ret = this;

    if (!self) ret = new DoubleArray.sized(length);

    if (other is NumericArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is num) {
      // Nothing here
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other.elementAt(i);
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is num) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other;
      }
    } else if (other is NumericArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other[i];
      }
    }
    return ret;
  }

  IntArray truncDiv(/* num | Iterable<num> */ other, {bool self: false}) {
    if (!self) return this ~/ other;

    throw new Exception('Operation not supported!');
  }

  DoubleArray floorToDouble({bool self: false}) {
    if (self) {
      for (int i = 0; i < length; i++) {
        _data[i] = _data[i].floorToDouble();
      }
      return this;
    }

    return super.floorToDouble();
  }

  DoubleArray ceilToDouble({bool self: false}) {
    if (self) {
      for (int i = 0; i < length; i++) {
        _data[i] = _data[i].ceilToDouble();
      }
      return this;
    }

    return super.ceilToDouble();
  }

  DoubleArrayView get view => new DoubleArrayView.make(_data);
}

class DoubleArrayView extends Object
    with IterableMixin<double>
    implements NumericArrayView<double> {
  final Float64List _data;

  DoubleArrayView(Iterable<double> iterable)
      : _data = new Float64List.fromList(iterable);

  DoubleArrayView.make(this._data);

  DoubleArrayView.sized(int length, {double data: 0.0})
      : _data = new Float64List(length) {
    for (int i = 0; i < length; i++) {
      _data[i] = data;
    }
  }

  DoubleArrayView.single(double data) : _data = new Float64List(1) {
    _data[0] = data;
  }

  factory DoubleArrayView.fromNum(Iterable<num> iterable) {
    final list = new Float64List(iterable.length);

    final Iterator<num> ite = iterable.iterator;
    ite.moveNext();

    for (int i = 0; i < list.length; i++) {
      list[i] = ite.current.toDouble();
      ite.moveNext();
    }

    return new DoubleArrayView.make(list);
  }

  DoubleArray makeFrom(Iterable<double> newData) => new DoubleArray(newData);

  @override
  Iterator<double> get iterator => _data.iterator;

  Index1D get shape => new Index1D(_data.length);

  double operator [](int i) => _data[i];

  DoubleArray slice(int start, [int end]) =>
      new DoubleArray(_data.sublist(start, end));

  @override
  double get min {
    double ret;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];

      if (d == null) continue;

      if (ret == null || d < ret) ret = d;
    }
    return ret;
  }

  @override
  double get max {
    double ret;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];

      if (d == null) continue;

      if (ret == null || d > ret) ret = d;
    }
    return ret;
  }

  @override
  Extent<double> get extent {
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
  int get argMin {
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
  int get argMax {
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

  IntPair<double> pairAt(int index) => new IntPair<double>(index, _data[index]);

  Iterable<IntPair<double>> enumerate() =>
      Ranger.indices(_data.length).map((i) => intPair<double>(i, _data[i]));

  @override
  double get ptp {
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
  double get mean {
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
  double get sum {
    double sum = 0.0;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];
      if (d == null) continue;
      sum += d;
    }
    return sum;
  }

  @override
  double get prod {
    double prod = 1.0;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];
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
      final double d = _data[i];
      final int w = weights.elementAt(i);
      if (d == null) continue;
      if (w == null) continue;
      sum += d * w;
      denom += w;
    }
    return sum / denom;
  }

  @override
  DoubleArray get cumsum {
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
  DoubleArray get cumprod {
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
  double get variance {
    //TODO
    throw new UnimplementedError();
  }

  @override
  double get std {
    //TODO
    throw new UnimplementedError();
  }

  DoubleArray operator +(/* num | Iterable<num> */ other) => addition(other);

  DoubleArray addition(/* num | Iterable<num> */ other) {
    DoubleArray ret = new DoubleArray.sized(length);

    if (other is NumericArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is num) {
      // Nothing here
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other.elementAt(i);
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is num) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other;
      }
    } else if (other is DoubleArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other[i];
      }
    }
    return ret;
  }

  DoubleArray operator -(/* num | Iterable<num> */ other) => subtract(other);

  DoubleArray subtract(/* num | Iterable<num> */ other) {
    DoubleArray ret = new DoubleArray.sized(length);

    if (other is NumericArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is num) {
      // Nothing here
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other.elementAt(i);
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is num) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other;
      }
    } else if (other is NumericArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other[i];
      }
    }
    return ret;
  }

  DoubleArray operator *(/* num | Iterable<num> */ other) => multiple(other);

  DoubleArray multiple(/* num | Iterable<num> */ other) {
    DoubleArray ret = new DoubleArray.sized(length);

    if (other is NumericArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is num) {
      // Nothing here
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other.elementAt(i);
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is num) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other;
      }
    } else if (other is NumericArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other[i];
      }
    }
    return ret;
  }

  DoubleArray operator /(/* num | Iterable<num> */ other) => divide(other);

  DoubleArray divide(/* E | Iterable<E> */ other) {
    DoubleArray ret = new DoubleArray.sized(length);

    if (other is NumericArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is num) {
      // Nothing here
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other.elementAt(i);
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    if (other is num) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other;
      }
    } else if (other is NumericArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other[i];
      }
    }
    return ret;
  }

  IntArray operator ~/(/* num | Iterable<num> */ other) {
    if (other is NumericArray) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is num) {
      // Nothing here
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
    if (other is num) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other;
      }
    } else if (other is NumericArray) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other[i];
      }
    }
    return ret;
  }

  IntArray truncDiv(/* num | Iterable<num> */ other) => this ~/ other;

  IntArray floor() {
    final ret = new IntArray.sized(length);

    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].floor();
    }

    return ret;
  }

  IntArray ceil() {
    final ret = new IntArray.sized(length);

    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].ceil();
    }

    return ret;
  }

  DoubleArray floorToDouble() {
    final ret = new DoubleArray.sized(length);

    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].floorToDouble();
    }

    return ret;
  }

  DoubleArray ceilToDouble() {
    final ret = new DoubleArray.sized(length);

    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].ceilToDouble();
    }

    return ret;
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

  Double2DArray to2D() => new Double2DArray.make([new DoubleArray(_data)]);

  Double2DArray repeat({int repeat: 1, bool transpose: false}) {
    if (!transpose) {
      return new Double2DArray.columns(_data, repeat + 1);
    } else {
      return new Double2DArray.rows(_data, repeat + 1);
    }
  }

  Double2DArray transpose() {
    final ret = new Double2DArray.sized(length, 1);

    for (int i = 0; i < length; i++) {
      ret[i][0] = _data[i];
    }

    return ret;
  }

  double dot(NumericArrayView other) {
    if (length != other.length) throw new Exception('Lengths must match!');
    double ret = 0.0;

    for (int i = 0; i < length; i++) {
      ret += _data[i] * other[i];
    }

    return ret;
  }

  IntArray toInt() {
    final ret = new IntArray.sized(length);

    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].toInt();
    }

    return ret;
  }
}
