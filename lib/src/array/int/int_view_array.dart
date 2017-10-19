part of grizzly.series.array;

class Int1DView extends Object
    with IterableMixin<int>
    implements Numeric1DView<int> {
  Int32List _data;

  Int1DView(Iterable<int> data) : _data = new Int32List.fromList(data);

  Int1DView.make(this._data);

  Int1DView.sized(int length, {int data: 0})
      : _data = new Int32List(length) {
    for (int i = 0; i < length; i++) {
      _data[i] = data;
    }
  }

  Int1DView.single(int data) : _data = new Int32List(1) {
    _data[0] = data;
  }

  Int1D makeFrom(Iterable<int> newData) => new Int1D(newData);

  Iterator<int> get iterator => _data.iterator;

  Index1D get shape => new Index1D(_data.length);

  int operator [](int i) => _data[i];

  Int1D slice(int start, [int end]) =>
      new Int1D(_data.sublist(start, end));

  int get min {
    int ret;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) continue;
      if (ret == null || d < ret) ret = d;
    }
    return ret;
  }

  int get max {
    int ret;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) continue;
      if (ret == null || d > ret) ret = d;
    }
    return ret;
  }

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

  int get sum {
    int sum = 0;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) continue;
      sum += d;
    }
    return sum;
  }

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

  Int1D get cumsum {
    final ret = new Int1D(new Int32List(_data.length));
    int sum = 0;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
      if (d == null) {
        ret[i] = sum;
        continue;
      }
      sum += d;
      ret[i] = sum;
    }
    return ret;
  }

  Int1D get cumprod {
    final ret = new Int1D(new Int32List(_data.length));
    int prod = 1;
    for (int i = 0; i < _data.length; i++) {
      final int d = _data[i];
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
    if(length == 0) return 0.0;

    final double mean = this.mean;
    double ret = 0.0;
    for(int i = 0; i < length; i++) {
      final double val = _data[i] - mean;
      ret += val * val;
    }
    return ret/length;
  }

  double get std => math.sqrt(variance);

  Int1DFix operator +(/* num | Iterable<num> */ other) => addition(other);

  Int1DFix addition(/* num | Iterable<num> */ other, {bool self: false}) {
    Int1D ret = new Int1D.sized(length);

    if (other is Int1D) {
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
    } else if (other is Int1D) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] + other[i];
      }
    }
    return ret;
  }

  Int1DFix operator -(/* num | Iterable<num> */ other) => subtract(other);

  Int1DFix subtract(/* num | Iterable<num> */ other) {
    Int1D ret = new Int1D.sized(length);

    if (other is Int1D) {
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
    } else if (other is Int1D) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] - other[i];
      }
    }
    return ret;
  }

  Int1DFix operator *(/* num | Iterable<num> */ other) => multiply(other);

  Int1DFix multiply(/* num | Iterable<num> */ other) {
    Int1D ret = new Int1D.sized(length);

    if (other is Int1D) {
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
    } else if (other is Int1D) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] * other[i];
      }
    }
    return ret;
  }

  Double1D operator /(/* num | Iterable<num> */ other) {
    if (other is Int1D) {
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
      final ret = new Double1D.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other.elementAt(i);
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != length) {
        throw new Exception('Length mismatch!');
      }
      final ret = new Double1D.sized(length);
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other.elementAt(i);
      }
      return ret;
    } else {
      throw new Exception('Expects num or Iterable<num>');
    }

    final ret = new Double1D.sized(length);
    if (other is int) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other;
      }
    } else if (other is Int1D) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] / other[i];
      }
    }
    return ret;
  }

  Double1D divide(/* E | Iterable<E> */ other) {
    return this / other;
  }

  Int1DFix operator ~/(/* num | Iterable<num> */ other) => truncDiv(other);

  Int1DFix truncDiv(/* num | Iterable<num> */ other) {
    Int1D ret = new Int1D.sized(length);

    if (other is Int1D) {
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
    } else if (other is Int1D) {
      for (int i = 0; i < length; i++) {
        ret[i] = _data[i] ~/ other[i];
      }
    }
    return ret;
  }

  Double1D sqrt() {
    final ret = new Double1D.sized(length);
    for (int i = 0; i < length; i++) ret[i] = math.sqrt(_data[i]);
    return ret;
  }

  /// Returns a new  [Int1D] containing first [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Int1D head([int count = 10]) {
    if (length <= count) return makeFrom(_data);
    return makeFrom(_data.sublist(0, count));
  }

  /// Returns a new  [Int1D] containing last [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Int1D tail([int count = 10]) {
    if (length <= count) return makeFrom(_data);
    return makeFrom(_data.sublist(length - count));
  }

  /// Returns a new  [Array] containing random [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Int1D sample([int count = 10]) => makeFrom(_sample<int>(_data, count));

  Int2D to2D() => new Int2D.make([new Int1D(_data)]);

  Int2D repeat({int repeat: 1, bool transpose: false}) {
    if (!transpose) {
      return new Int2D.repeatCol(_data, repeat + 1);
    } else {
      return new Int2D.repeatRow(_data, repeat + 1);
    }
  }

  Int2D get transpose {
    final ret = new Int2D.sized(length, 1);
    for (int i = 0; i < length; i++) {
      ret[i][0] = _data[i];
    }
    return ret;
  }

  int dot(Iterable<num> other) {
    if (length != other.length) throw new Exception('Lengths must match!');

    num ret = 0;
    for (int i = 0; i < length; i++) {
      ret += _data[i] * other.elementAt(i);
    }
    return ret.toInt();
  }

  Double1D get toDouble {
    final ret = new Double1D.sized(length);
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

  Int1DView get view => this;

  @override
  IntSeries<int> valueCounts(
      {bool sortByValue: false,
        bool ascending: false,
        bool dropNull: false,
        dynamic name: ''}) {
    final groups = new Map<int, List<int>>();

    for (int i = 0; i < length; i++) {
      final int v = _data[i];
      if (!groups.containsKey(v)) groups[v] = <int>[0];
      groups[v][0]++;
    }

    final ret = new IntSeries<int>.fromMap(groups, name: name);

    // Sort
    if (sortByValue) {
      ret.sortByIndex(ascending: ascending, inplace: true);
    } else {
      ret.sortByValue(ascending: ascending, inplace: true);
    }

    return ret;
  }
}
