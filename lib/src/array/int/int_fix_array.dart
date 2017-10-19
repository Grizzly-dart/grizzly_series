part of grizzly.series.array;

class Int1DFix extends Int1DView implements Numeric1DFix<int> {
  Int1DFix(Iterable<int> data) : super(data);

  Int1DFix.make(Int32List data) : super.make(data);

  Int1DFix.sized(int length, {int data: 0}) : super.sized(length, data: data);

  Int1DFix.single(int data) : super.single(data);

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

  Int1DFix operator +(/* num | Iterable<num> */ other) => addition(other);

  Int1DFix addition(/* num | Iterable<num> */ other, {bool self: false}) {
    Int1DFix ret = this;
    if (!self) ret = new Int1DFix.sized(length);

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

  Int1DFix subtract(/* num | Iterable<num> */ other, {bool self: false}) {
    Int1DFix ret = this;
    if (!self) {
      ret = new Int1DFix.sized(length);
    }

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

  Int1DFix multiply(/* num | Iterable<num> */ other, {bool self: false}) {
    Int1DFix ret = this;

    if (!self) {
      ret = new Int1DFix.sized(length);
    }

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

  Double1D divide(/* E | Iterable<E> */ other, {bool self: false}) {
    if (!self) return this / other;

    throw new Exception('Operation not supported!');
  }

  Int1DFix operator ~/(/* num | Iterable<num> */ other) => truncDiv(other);

  Int1DFix truncDiv(/* num | Iterable<num> */ other, {bool self: false}) {
    Int1DFix ret = this;

    if (!self) {
      ret = new Int1DFix.sized(length);
    }

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

  Int1DView _view;
  Int1DView get view => _view ??= new Int1DView.make(_data);

  Int1DFix get fixed => this;
}
