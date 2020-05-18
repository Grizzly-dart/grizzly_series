part of grizzly.series;

class IntSeries<LT> extends Object
    with
        SeriesViewMixin<LT, int>,
        SeriesFixMixin<LT, int>,
        SeriesMixin<LT, int>,
        IntSeriesFixMixin<LT>
    implements IntNumericSeries<LT>, IntSeriesFix<LT>, NumericSeries<LT, int> {
  final List<LT> _labels;

  final Int1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  IntSeries._(this._labels, this._data, this._name, this._mapper);

  IntSeries._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory IntSeries(Iterable<int> data, {dynamic name, Iterable<LT> labels}) {
    Int1D d = Int1D(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return IntSeries._build(madeLabels, d, name);
  }

  factory IntSeries.fromNums(Iterable<num> data,
      {dynamic name, Iterable<LT> labels}) {
    Int1D d = Int1D.fromNums(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return IntSeries._build(madeLabels, d, name);
  }

  factory IntSeries.fromMap(Map<LT, int> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = List<LT>()..length = map.length;
    final data = Int1D.sized(map.length);
    final mapper = SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return IntSeries._(labels, data, name, mapper);
  }

  factory IntSeries.copy(SeriesView<LT, int> series, {name}) =>
      IntSeries(series.data, name: name ?? series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  Int1DFix get data => _data.fixed;

  IntSeriesView<LT> _view;

  IntSeriesView<LT> get view =>
      _view ??= IntSeriesView<LT>._(_labels, _data, () => name, _mapper);

  IntSeriesFix<LT> _fixed;

  IntSeriesFix<LT> get fixed =>
      _fixed ??= IntSeriesFix<LT>._(_labels, _data, () => name, _mapper);

  String get name => _name is Function ? _name() : _name.toString();

  Stats<int> get stats => _data.stats;

  @override
  void negate() {
    _data.negate();
  }

  IntSeries<LT> toSeries() => IntSeries(data, name: name, labels: labels);

  IntSeriesView<NLT> makeView<NLT>(Iterable<int> data,
          {dynamic name, Iterable<NLT> labels}) =>
      IntSeriesView<NLT>(data, name: name, labels: labels);

  IntSeries<NLT> make<NLT>(Iterable<int> data,
          {dynamic name, Iterable<NLT> labels}) =>
      IntSeries<NLT>(data, name: name, labels: labels);

  @override
  Int1D makeValueArraySized(int size) => Int1D.sized(size);

  @override
  Int1D makeValueArray(Iterable<int> data) => Int1D(data);

  @override
  int compareValue(int a, int b) => a.compareTo(b);

  int get max => data.max;

  int get min => data.min;

  int get sum => data.sum;

  int get prod => data.prod;

  double average(Iterable<num> weights) => data.average(weights);

  double get variance => data.variance;

  double get std => data.std;

  DoubleNumericSeries<LT> get log =>
      DoubleSeries(data.log, name: name, labels: labels);

  DoubleNumericSeries<LT> get log10 =>
      DoubleSeries(data.log10, name: name, labels: labels);

  DoubleNumericSeries<LT> logN(num n) =>
      DoubleSeries(data.logN(n), name: name, labels: labels);

  DoubleNumericSeries<LT> get exp =>
      DoubleSeries(data.exp, name: name, labels: labels);

  IntNumericSeries<LT> get abs =>
      IntSeries<LT>.fromNums(data.abs(), name: name, labels: labels);

  DoubleSeries<LT> toDouble() =>
      DoubleSeries<LT>(data.toDouble(), name: name, labels: labels.toList());

  IntSeries<LT> toInt() =>
      IntSeries<LT>(data, name: name, labels: labels.toList());

  @override
  IntSeries<LT> operator +(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */
      other) {
    if (other is int) {
      return IntSeries<LT>(data + other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] + other[label];
        }
      }
      return IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return IntSeries<LT>(data + other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  IntSeries<LT> operator -(
      /* int | Iterable<int> | NumericSeriesView<LT, int> | Numeric1DView<int> */
      other) {
    if (other is int) {
      return IntSeries<LT>(data - other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] - other[label];
        }
      }
      return IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return IntSeries<LT>(data - other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  IntSeries<LT> operator *(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */
      other) {
    if (other is int) {
      return IntSeries<LT>(data * other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] * other[label];
        }
      }
      return IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return IntSeries<LT>(data * other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  DoubleSeries<LT> operator /(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */
      other) {
    if (other is num) {
      return DoubleSeries<LT>(data / other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, num>) {
      final list = List<double>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] / other[label];
        }
      }
      return DoubleSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<num>) {
      return DoubleSeries<LT>(data / other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  IntSeries<LT> operator ~/(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */
      other) {
    if (other is num) {
      return IntSeries<LT>(data ~/ other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, num>) {
      final list = List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] ~/ other[label];
        }
      }
      return IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<num>) {
      return IntSeries<LT>(data ~/ other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  IntSeries<LT> operator -() => IntSeries.copy(this, name: name)..negate();

  @override
  BoolSeries<LT> operator >=(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return BoolSeries<LT>(data >= other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] >= other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return BoolSeries<LT>(data >= other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator >(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return BoolSeries<LT>(data > other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] > other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return BoolSeries<LT>(data > other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator <=(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return BoolSeries<LT>(data <= other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] <= other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return BoolSeries<LT>(data <= other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator <(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return BoolSeries<LT>(data < other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] < other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return BoolSeries<LT>(data < other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }
}

/*
  void _selfMod(IntSeries<IT> a, {int mfv, int ofv, bool strict: true}) {
    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        final List<int> sourcePos = _mapper[index];
        final List<int> destPos = a._mapper[index];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final int source = _data[srcIdx];
            final int dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) % (dest ?? ofv);
            }
          }
        } else if (sourcePos.length > destPos.length) {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < destPos.length; i++) {
            final int srcIdx = sourcePos[i];
            final int source = _data[srcIdx];
            final int dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) % (dest ?? ofv);
            }
          }
        } else {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final int source = _data[srcIdx];
            final int dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) % (dest ?? ofv);
            }
          }
          // Add remaining
          {
            final lst = new List<int>(destPos.length - sourcePos.length);
            for (int i = sourcePos.length; i < destPos.length; i++) {
              lst[i] = a._data[destPos[i]];
            }
            appendAll(index, lst);
          }
        }
      }
    }

    for (IT index in a._mapper.keys) {
      if (_mapper.containsKey(index)) continue;

      if (strict) throw new Exception('Invalid lengths at label $index!');

      appendAll(index, a.getByLabelMulti(index));
    }
  }

  IntSeries<IT> mod(a,
      {int myFillValue,
      int otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true}) {
    IntSeries<IT> ret = this;

    if (!self)
      ret = new IntSeries._(
          _data.toList(), _labels.toList(), name, cloneMapper());

    if (a is IntSeries<IT>) {
      ret._selfMod(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is DoubleSeries<IT>) {
      ret._selfMod(a.toInt(),
          mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is int) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] %= a;
      }
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] %= a.toInt();
      }
    } else if (a is Iterable<int>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] %= a.elementAt(i);
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] %= a.elementAt(i).toInt();
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  IntSeries<IT> operator %(a) => mod(a);

  void _selfPow(IntSeries<IT> a, {int mfv, int ofv, bool strict: true}) {
    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        final List<int> sourcePos = _mapper[index];
        final List<int> destPos = a._mapper[index];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final int source = _data[srcIdx];
            final int dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = math.pow(source ?? mfv, dest ?? ofv);
            }
          }
        } else if (sourcePos.length > destPos.length) {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < destPos.length; i++) {
            final int srcIdx = sourcePos[i];
            final int source = _data[srcIdx];
            final int dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = math.pow(source ?? mfv, dest ?? ofv);
            }
          }
        } else {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final int source = _data[srcIdx];
            final int dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = math.pow(source ?? mfv, dest ?? ofv);
            }
          }
          // Add remaining
          {
            final lst = new List<int>(destPos.length - sourcePos.length);
            for (int i = sourcePos.length; i < destPos.length; i++) {
              lst[i] = a._data[destPos[i]];
            }
            appendAll(index, lst);
          }
        }
      }
    }

    for (IT index in a._mapper.keys) {
      if (_mapper.containsKey(index)) continue;

      if (strict) throw new Exception('Invalid lengths at label $index!');

      appendAll(index, a.getByLabelMulti(index));
    }
  }

  IntSeries<IT> pow(a,
      {int myFillValue,
      int otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true}) {
    IntSeries<IT> ret = this;

    if (!self)
      ret = new IntSeries._(
          _data.toList(), _labels.toList(), name, cloneMapper());

    if (a is IntSeries<IT>) {
      ret._selfPow(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is DoubleSeries<IT>) {
      ret._selfPow(a.toInt(),
          mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is int) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] = math.pow(ret._data[i], a);
      }
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] = math.pow(ret._data[i], a.toInt());
      }
    } else if (a is Iterable<int>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] = math.pow(ret._data[i], a.elementAt(i));
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] = math.pow(ret._data[i], a.elementAt(i).toInt());
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }
  */
