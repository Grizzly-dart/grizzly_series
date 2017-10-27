part of grizzly.series.array;

class Double1DView extends Object
    with IterableMixin<double>
    implements Numeric1DView<double> {
  Float64List _data;

  Double1DView(Iterable<double> iterable)
      : _data = new Float64List.fromList(iterable.toList());

  Double1DView.make(this._data);

  Double1DView.sized(int length, {double data: 0.0})
      : _data = new Float64List(length) {
    for (int i = 0; i < length; i++) {
      _data[i] = data;
    }
  }

  factory Double1DView.shapedLike(Iterable d, {double data: 0.0}) =>
      new Double1DView.sized(d.length, data: data);

  Double1DView.single(double data) : _data = new Float64List(1) {
    _data[0] = data;
  }

  Double1DView.gen(int length, double maker(int index))
      : _data = new Float64List(length) {
    for (int i = 0; i < length; i++) {
      _data[i] = maker(i);
    }
  }

  factory Double1DView.fromNum(Iterable<num> iterable) {
    final list = new Float64List(iterable.length);
    final Iterator<num> ite = iterable.iterator;
    ite.moveNext();
    for (int i = 0; i < list.length; i++) {
      list[i] = ite.current.toDouble();
      ite.moveNext();
    }
    return new Double1DView.make(list);
  }

  Double1DView makeView(Iterable<double> newData) => new Double1DView(newData);

  Double1DFix makeFix(Iterable<double> newData) => new Double1DFix(newData);

  Double1D makeArray(Iterable<double> newData) => new Double1D(newData);

  Iterator<double> get iterator => _data.iterator;

  Index1D get shape => new Index1D(_data.length);

  double operator [](int i) => _data[i];

  Double1D slice(int start, [int end]) =>
      new Double1D(_data.sublist(start, end));

  double get min {
    double ret;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];

      if (d == null) continue;

      if (ret == null || d < ret) ret = d;
    }
    return ret;
  }

  double get max {
    double ret;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];

      if (d == null) continue;

      if (ret == null || d > ret) ret = d;
    }
    return ret;
  }

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

  double get sum {
    double sum = 0.0;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];
      if (d == null) continue;
      sum += d;
    }
    return sum;
  }

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

  Double1D get cumsum {
    final Double1D ret = new Double1D(new Float64List(_data.length));
    double sum = 0.0;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];
      if (d == null) {
        ret[i] = sum;
        continue;
      }
      sum += d;
      ret[i] = sum;
    }
    return ret;
  }

  Double1D get cumprod {
    final Double1D ret = new Double1D(new Float64List(_data.length));
    double prod = 1.0;
    for (int i = 0; i < _data.length; i++) {
      final double d = _data[i];
      if (d == null) {
        ret[i] = prod;
        continue;
      }
      prod *= d;
      ret[i] = prod;
    }
    return ret;
  }

  double get variance {
    if (length == 0) return 0.0;

    final double mean = this.mean;
    double ret = 0.0;
    for (int i = 0; i < length; i++) {
      final double val = _data[i] - mean;
      ret += val * val;
    }
    return ret / length;
  }

  double get std => math.sqrt(variance);

  Double1DFix operator +(/* num | Iterable<num> */ other) => addition(other);

  Double1DFix addition(/* num | Iterable<num> */ other) {
    Double1D ret = new Double1D.sized(length);

    if (other is Numeric1D) {
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
    } else if (other is Double1D) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other[i];
      }
    }
    return ret;
  }

  Double1DFix operator -(/* num | Iterable<num> */ other) => subtract(other);

  Double1DFix subtract(/* num | Iterable<num> */ other) {
    Double1D ret = new Double1D.sized(length);

    if (other is Numeric1D) {
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
    } else if (other is Numeric1D) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other[i];
      }
    }
    return ret;
  }

  Double1DFix operator *(/* num | Iterable<num> */ other) => multiply(other);

  Double1DFix multiply(/* num | Iterable<num> */ other) {
    Double1D ret = new Double1D.sized(length);

    if (other is Numeric1D) {
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
    } else if (other is Numeric1D) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other[i];
      }
    }
    return ret;
  }

  Double1DFix operator /(/* num | Iterable<num> */ other) => divide(other);

  Double1DFix divide(/* E | Iterable<E> */ other) {
    Double1D ret = new Double1D.sized(length);

    if (other is Numeric1D) {
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
    } else if (other is Numeric1D) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other[i];
      }
    }
    return ret;
  }

  Int1DFix operator ~/(/* num | Iterable<num> */ other) {
    if (other is Numeric1D) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
    } else if (other is num) {
      // Nothing here
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new Int1D.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other.elementAt(i).toInt();
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    final ret = new Int1D.sized(length);
    if (other is num) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other;
      }
    } else if (other is Numeric1D) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other[i];
      }
    }
    return ret;
  }

  Int1DFix truncDiv(/* num | Iterable<num> */ other) => this ~/ other;

  Double1DFix sqrt() {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) ret[i] = math.sqrt(_data[i]);
    return ret;
  }

  @override
  Double1D get log {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) ret[i] = math.log(_data[i]);
    return ret;
  }

  @override
  Double1D get log10 {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) ret[i] = math.log(_data[i]) / math.LN10;
    return ret;
  }

  @override
  Double1D logN(double n) {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) ret[i] = math.log(_data[i]) / math.log(n);
    return ret;
  }

  @override
  Double1D get exp {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) ret[i] = math.exp(_data[i]);
    return ret;
  }

  Double1DFix floorToDouble() {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].floorToDouble();
    }
    return ret;
  }

  Double1DFix ceilToDouble() {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].ceilToDouble();
    }
    return ret;
  }

  Int1D floor() {
    final ret = new Int1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].floor();
    }
    return ret;
  }

  Int1D ceil() {
    final ret = new Int1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].ceil();
    }
    return ret;
  }

  /// Returns a new  [Double1D] containing first [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Double1D head([int count = 10]) {
    if (length <= count) return makeArray(_data);
    return makeArray(_data.sublist(0, count));
  }

  /// Returns a new  [Double1D] containing last [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Double1D tail([int count = 10]) {
    if (length <= count) return makeArray(_data);
    return makeArray(_data.sublist(length - count));
  }

  /// Returns a new  [Array] containing random [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Double1D sample([int count = 10]) => makeArray(_sample<double>(_data, count));

  Double2D to2D() => new Double2D.make([new Double1D(_data)]);

  Double1D get toDouble => new Double1D(_data);

  Double2D repeat({int repeat: 1, bool transpose: false}) {
    if (!transpose) {
      return new Double2D.repeatColumn(_data, repeat + 1);
    } else {
      return new Double2D.repeatRow(_data, repeat + 1);
    }
  }

  Double2D get transpose {
    final ret = new Double2D.sized(length, 1);
    for (int i = 0; i < length; i++) {
      ret[i][0] = _data[i];
    }
    return ret;
  }

  double dot(Iterable<num> other) {
    if (length != other.length) throw new Exception('Lengths must match!');

    double ret = 0.0;
    for (int i = 0; i < length; i++) {
      ret += _data[i] * other.elementAt(i);
    }
    return ret;
  }

  Int1D toInt() {
    final ret = new Int1D.sized(length);
    for (int i = 0; i < length; i++) {
      ret[i] = _data[i].toInt();
    }
    return ret;
  }

  Double1DView get view => this;

  @override
  IntSeries<double> valueCounts(
      {bool sortByValue: false,
      bool ascending: false,
      bool dropNull: false,
      dynamic name: ''}) {
    final groups = new Map<double, List<int>>();
    for (int i = 0; i < length; i++) {
      final double v = _data[i];
      if (!groups.containsKey(v)) groups[v] = <int>[0];
      groups[v][0]++;
    }
    final ret = new IntSeries<double>.fromMap(groups, name: name);
    // Sort
    if (sortByValue) {
      ret.sortByIndex(ascending: ascending, inplace: true);
    } else {
      ret.sortByValue(ascending: ascending, inplace: true);
    }
    return ret;
  }

  double cov(Numeric1DView y) {
    if (y.length != length) throw new Exception('Size mismatch!');
    if (length == 0) return 0.0;
    final double meanX = mean;
    final double meanY = y.mean;
    double sum = 0.0;
    for (int i = 0; i < length; i++) {
      sum += (_data[i] - meanX) * (y[i] - meanY);
    }
    return sum / length;
  }

  Double1D covMatrix(Numeric2DView y) {
    if (y.numRows != length) throw new Exception('Size mismatch!');
    final double meanX = mean;
    final Double1D meanY = y.col.mean;
    Double1D sum = new Double1D.sized(y.numCols);
    for (int i = 0; i < length; i++) {
      sum += (y.col[i] - meanY) * (_data[i] - meanX);
    }
    return sum / length;
  }

  double corrcoef(Numeric1DView y) {
    if (y.length != length) throw new Exception('Size mismatch!');
    return cov(y) / (std * y.std);
  }

  Double1D corrcoefMatrix(Numeric2DView y) {
    if (y.numRows != length) throw new Exception('Size mismatch!');
    return covMatrix(y) / (y.std * std);
  }

  bool isAllClose(Iterable<num> v, {double absTol: 1e-8}) {
    if (length != v.length) return false;
    for (int i = 0; i < length; i++) {
      if ((_data[i] - v.elementAt(i)).abs() > absTol) return false;
    }
    return true;
  }

  bool isAllCloseScalar(num v, {double absTol: 1e-8}) {
    for (int i = 0; i < length; i++) {
      if ((_data[i] - v).abs() > absTol) return false;
    }
    return true;
  }
}
