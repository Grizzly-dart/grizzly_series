part of grizzly.series.array;

class Double1D extends Double1DFix implements Numeric1D<double> {
  Double1D(Iterable<double> data) : super(data);

  Double1D.make(Iterable<double> iterable) : super.make(iterable);

  Double1D.sized(int length, {double data: 0.0})
      : super.sized(length, data: data);

  Double1D.single(double data) : super.single(data);

  factory Double1D.fromNum(Iterable<num> iterable) {
    final list = new Float64List(iterable.length);
    final Iterator<num> ite = iterable.iterator;
    ite.moveNext();
    for (int i = 0; i < list.length; i++) {
      list[i] = ite.current.toDouble();
      ite.moveNext();
    }
    return new Double1D.make(list);
  }

  Double1D.gen(int length, double maker(int index)) : super.gen(length, maker);

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

  @override
  void add(double a) {
    _data = new Float64List.fromList(_data.toList()..add(a));
    if(_view != null) _view._data = _data;
    if(_fixed != null) _fixed._data = _data;
  }

  @override
  void insert(int index, double a) {
    _data = new Float64List.fromList(_data.toList()..insert(index, a));
    if(_view != null) _view._data = _data;
    if(_fixed != null) _fixed._data = _data;
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

  Double1D addition(/* num | Iterable<num> */ other, {bool self: false}) {
    Double1D ret = this;

    if (!self) ret = new Double1D.sized(length);

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

  Double1D subtract(/* num | Iterable<num> */ other, {bool self: false}) {
    Double1D ret = this;

    if (!self) ret = new Double1D.sized(length);

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

  Double1D multiply(/* num | Iterable<num> */ other, {bool self: false}) {
    Double1D ret = this;

    if (!self) ret = new Double1D.sized(length);

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

  Double1D divide(/* E | Iterable<E> */ other, {bool self: false}) {
    Double1D ret = this;

    if (!self) ret = new Double1D.sized(length);

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

  Int1D truncDiv(/* num | Iterable<num> */ other, {bool self: false}) {
    if (!self) return this ~/ other;
    throw new Exception('Operation not supported!');
  }

  Double1D floorToDouble({bool self: false}) {
    if (self) {
      for (int i = 0; i < length; i++) {
        _data[i] = _data[i].floorToDouble();
      }
      return this;
    }
    return super.floorToDouble();
  }

  Double1D ceilToDouble({bool self: false}) {
    if (self) {
      for (int i = 0; i < length; i++) {
        _data[i] = _data[i].ceilToDouble();
      }
      return this;
    }
    return super.ceilToDouble();
  }

  Double1DFix _fixed;
  Double1DFix get fixed => _fixed ??= new Double1DFix.make(_data);
}
