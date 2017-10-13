part of grizzly.series.array;

class IntArray extends IntArrayFix implements NumericArray<int> {
  IntArray(Iterable<int> data) : super(data);

  IntArray.sized(int length, {int data: 0}) : super.sized(length, data: data);

  IntArray.single(int data) : super.single(data);

  IntArray.make(Int32List data) : super.make(data);

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

  void add(int a) {
    _data.add(a);
  }

  IntArrayFix get fixed => new IntArrayFix.make(_data);
}

class IntArrayFix extends IntArrayView implements NumericArrayFix<int> {
  IntArrayFix(Iterable<int> data) : super(data);

  IntArrayFix.sized(int length, {int data: 0}) : super.sized(length, data: data);

  IntArrayFix.single(int data) : super.single(data);

  IntArrayFix.make(Int32List data) : super.make(data);

  operator []=(int i, int val) {
    if (i > _data.length) {
      throw new RangeError.range(i, 0, _data.length, 'i', 'Out of range!');
    }

    _data[i] = val;
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

  IntArray addition(/* num | Iterable<num> */ other, {bool self: false}) {
    IntArray ret = this;
    if (!self) ret = new IntArray.sized(length);

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
        ret[i] = _data[i] + other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

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

  IntArray subtract(/* num | Iterable<num> */ other, {bool self: false}) {
    IntArray ret = this;
    if (!self) {
      ret = new IntArray.sized(length);
    }

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
        ret[i] = _data[i] - other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

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

  IntArray multiple(/* num | Iterable<num> */ other, {bool self: false}) {
    IntArray ret = this;

    if (!self) {
      ret = new IntArray.sized(length);
    }

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
        ret[i] = _data[i] * other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

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

  NumericArray<double> divide(/* E | Iterable<E> */ other, {bool self: false}) {
    if (!self) return this / other;

    throw new Exception('Operation not supported!');
  }

  IntArray truncDiv(/* num | Iterable<num> */ other, {bool self: false}) {
    IntArray ret = this;

    if (!self) {
      ret = new IntArray.sized(length);
    }

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
        ret[i] = _data[i] ~/ other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

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

  IntArrayView get view => new IntArrayView.make(_data);
}

class IntArrayView extends Object
    with IterableMixin<int>
    implements ReadOnlyNumericArray<int> {
  final Int32List _data;

  IntArrayView(Iterable<int> data) : _data = new Int32List.fromList(data);

  IntArrayView.make(this._data);

  IntArrayView.sized(int length, {int data: 0})
      : _data = new Int32List(length) {
    for (int i = 0; i < length; i++) {
      _data[i] = data;
    }
  }

  IntArrayView.single(int data) : _data = new Int32List(1) {
    _data[0] = data;
  }

  IntArray makeFrom(Iterable<int> newData) => new IntArray(newData);

  @override
  Iterator<int> get iterator => _data.iterator;

  Index1D get shape => new Index1D(_data.length);

  int operator [](int i) => _data[i];

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
    final ret = new IntArray(new Int32List(_data.length));
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
    final ret = new IntArray(new Int32List(_data.length));
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

  IntArray operator +(/* num | Iterable<num> */ other) => addition(other);

  IntArray addition(/* num | Iterable<num> */ other, {bool self: false}) {
    IntArray ret = new IntArray.sized(length);

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
        ret[i] = _data[i] + other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

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

  IntArray operator -(/* num | Iterable<num> */ other) => subtract(other);

  IntArray subtract(/* num | Iterable<num> */ other) {
    IntArray ret = new IntArray.sized(length);

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
        ret[i] = _data[i] - other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

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

  IntArray operator *(/* num | Iterable<num> */ other) => multiple(other);

  IntArray multiple(/* num | Iterable<num> */ other) {
    IntArray ret = new IntArray.sized(length);

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
        ret[i] = _data[i] * other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

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

  DoubleArray operator /(/* num | Iterable<num> */ other) {
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

  NumericArray<double> divide(/* E | Iterable<E> */ other) {
    return this / other;
  }

  IntArray operator ~/(/* num | Iterable<num> */ other) => truncDiv(other);

  IntArray truncDiv(/* num | Iterable<num> */ other) {
    IntArray ret = new IntArray.sized(length);

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
        ret[i] = _data[i] ~/ other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

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

  int dot(NumericArray other) {
    if (length != other.length) throw new Exception('Lengths must match!');
    num ret = 0;

    for (int i = 0; i < length; i++) {
      ret += _data[i] * other[i];
    }

    return ret.toInt();
  }

  DoubleArray toDouble() {
    final ret = new DoubleArray.sized(length);

    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].toDouble();
    }

    return ret;
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
}
