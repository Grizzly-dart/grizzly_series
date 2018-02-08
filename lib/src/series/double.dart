part of grizzly.series;

/*
class DoubleSeries<IT> extends Object
    with SeriesMixin<IT, double>, NumericSeries<IT, double>
    implements Series<IT, double> {
  final List<IT> _labels;

  final Float64List _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> labels;

  final UnmodifiableListView<double> data;

  SeriesPositioned<IT, double> _pos;

  SeriesPositioned<IT, double> get pos => _pos;

  DoubleSeriesView<IT> _view;

  DoubleSeriesView<IT> toView() {
    if (_view == null) _view = new DoubleSeriesView<IT>(this);
    return _view;
  }

  DoubleSeries._(this._data, this._labels, this.name, this._mapper)
      : labels = new UnmodifiableListView(_labels),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, double>(this);
  }

  factory DoubleSeries(Iterable<double> data, {dynamic name, List<IT> labels}) {
    final List<IT> madeIndices = makeLabels<IT>(data.length, labels, IT);
    final mapper = labelsToMapper(madeIndices);

    return new DoubleSeries._(
        new Float64List.fromList(data), madeIndices, name, mapper);
  }

  factory DoubleSeries.fromMap(Map<IT, List<double>> map, {dynamic name}) {
    final List<IT> indices = [];
    final data = new Float64List(0);
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (double val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new DoubleSeries._(data, indices, name, mapper);
  }

  factory DoubleSeries.fromLabels(
      Iterable<IT> keys, double value(IT key, int index),
      {dynamic name}) {
    final List<IT> indices = keys.toList();
    final data = new Float64List(keys.length);
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (int i = 0; i < keys.length; i++) {
      final index = indices[i];
      data[i] = value(index, i);

      List<int> maps = mapper[index];
      if (maps == null) {
        maps = mapper[index] = <int>[];
      }

      maps.add(i);
    }

    return new DoubleSeries._(data, indices, name, mapper);
  }

  DoubleSeries<IIT> makeNew<IIT>(Iterable<double> data,
          {dynamic name, List<IIT> labels}) =>
      new DoubleSeries<IIT>(new Float64List.fromList(data),
          name: name, labels: labels.toList());

  double sum({bool skipNull: true}) {
    double ret = 0.0;
    for (int i = 0; i < _data.length; i++) {
      if (data[i] != null)
        ret += data[i];
      else if (!skipNull) return null;
    }
    return ret;
  }

  void _selfAdd(NumericSeries<IT, num> a,
      {double mfv, double ofv, bool strict: true}) {
    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        final List<int> sourcePos = _mapper[index];
        final List<int> destPos = a._mapper[index];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) + (dest ?? ofv);
            }
          }
        } else if (sourcePos.length > destPos.length) {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < destPos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) + (dest ?? ofv);
            }
          }
        } else {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) + (dest ?? ofv);
            }
          }
          // Add remaining
          {
            final lst = new List<double>(destPos.length - sourcePos.length);
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

      appendAll(index, a.getByLabelMulti(index).map((v) => v.toDouble()));
    }
  }

  DoubleSeries<IT> addition(a,
      {double myFillValue,
      double otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true}) {
    DoubleSeries<IT> ret = this;

    if (!self)
      ret = new DoubleSeries._(new Float64List.fromList(_data),
          _labels.toList(), name, cloneMapper());

    if (a is DoubleSeries<IT>) {
      ret._selfAdd(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is NumericSeries<IT, num>) {
      ret._selfAdd(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] += a;
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] += a.elementAt(i);
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  DoubleSeries<IT> operator +(a) => addition(a);

  void _selfSub(NumericSeries<IT, num> a,
      {double mfv, double ofv, bool strict: true}) {
    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        final List<int> sourcePos = _mapper[index];
        final List<int> destPos = a._mapper[index];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) - (dest ?? ofv);
            }
          }
        } else if (sourcePos.length > destPos.length) {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < destPos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) - (dest ?? ofv);
            }
          }
        } else {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) - (dest ?? ofv);
            }
          }
          // Add remaining
          {
            final lst = new List<double>(destPos.length - sourcePos.length);
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

      appendAll(index, a.getByLabelMulti(index).map((v) => v.toDouble()));
    }
  }

  DoubleSeries<IT> subtract(a,
      {double myFillValue,
      double otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true}) {
    DoubleSeries<IT> ret = this;

    if (!self)
      ret = new DoubleSeries._(new Float64List.fromList(_data),
          _labels.toList(), name, cloneMapper());

    if (a is DoubleSeries<IT>) {
      ret._selfSub(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is NumericSeries<IT, num>) {
      ret._selfSub(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] -= a;
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] -= a.elementAt(i);
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  DoubleSeries<IT> operator -(a) => subtract(a);

  void _selfMul(NumericSeries<IT, num> a,
      {double mfv, double ofv, bool strict: true}) {
    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        final List<int> sourcePos = _mapper[index];
        final List<int> destPos = a._mapper[index];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) * (dest ?? ofv);
            }
          }
        } else if (sourcePos.length > destPos.length) {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < destPos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) * (dest ?? ofv);
            }
          }
        } else {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) * (dest ?? ofv);
            }
          }
          // Add remaining
          {
            final lst = new List<double>(destPos.length - sourcePos.length);
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

      appendAll(index, a.getByLabelMulti(index).map((v) => v.toDouble()));
    }
  }

  DoubleSeries<IT> multiply(a,
      {double myFillValue,
      double otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true}) {
    DoubleSeries<IT> ret = this;

    if (!self)
      ret = new DoubleSeries._(new Float64List.fromList(_data),
          _labels.toList(), name, cloneMapper());

    if (a is DoubleSeries<IT>) {
      ret._selfMul(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is NumericSeries<IT, num>) {
      ret._selfMul(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] *= a;
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] *= a.elementAt(i);
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  DoubleSeries<IT> operator *(a) => multiply(a);

  void _selfDiv(NumericSeries<IT, num> a,
      {double mfv, double ofv, bool strict: true}) {
    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        final List<int> sourcePos = _mapper[index];
        final List<int> destPos = a._mapper[index];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) / (dest ?? ofv);
            }
          }
        } else if (sourcePos.length > destPos.length) {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < destPos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) / (dest ?? ofv);
            }
          }
        } else {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = (source ?? mfv) / (dest ?? ofv);
            }
          }
          // Add remaining
          {
            final lst = new List<double>(destPos.length - sourcePos.length);
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

      appendAll(index, a.getByLabelMulti(index).map((v) => v.toDouble()));
    }
  }

  DoubleSeries<IT> divide(a,
      {double myFillValue,
      double otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true}) {
    DoubleSeries<IT> ret = this;

    if (!self)
      ret = new DoubleSeries._(new Float64List.fromList(_data),
          _labels.toList(), name, cloneMapper());

    if (a is DoubleSeries<IT>) {
      ret._selfDiv(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is NumericSeries<IT, num>) {
      ret._selfDiv(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] /= a;
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] /= a.elementAt(i);
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  DoubleSeries<IT> operator /(a) => divide(a);

  void _selfModNum(NumericSeries<IT, num> a,
      {double mfv, double ofv, bool strict: true}) {
    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        final List<int> sourcePos = _mapper[index];
        final List<int> destPos = a._mapper[index];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = ((source ?? mfv) % (dest ?? ofv)).toDouble();
            }
          }
        } else if (sourcePos.length > destPos.length) {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < destPos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = ((source ?? mfv) % (dest ?? ofv)).toDouble();
            }
          }
        } else {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = ((source ?? mfv) % (dest ?? ofv)).toDouble();
            }
          }
          // Add remaining
          {
            final lst = new List<double>(destPos.length - sourcePos.length);
            for (int i = sourcePos.length; i < destPos.length; i++) {
              lst[i] = a._data[destPos[i]]?.toDouble();
            }
            appendAll(index, lst);
          }
        }
      }
    }

    for (IT index in a._mapper.keys) {
      if (_mapper.containsKey(index)) continue;

      if (strict) throw new Exception('Invalid lengths at label $index!');

      appendAll(index, a.getByLabelMulti(index).map((v) => v.toDouble()));
    }
  }

  DoubleSeries<IT> mod(a,
      {double myFillValue,
      double otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true}) {
    DoubleSeries<IT> ret = this;

    if (!self)
      ret = new DoubleSeries._(new Float64List.fromList(_data),
          _labels.toList(), name, cloneMapper());

    if (a is DoubleSeries<IT>) {
      ret._selfModNum(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is NumericSeries<IT, num>) {
      ret._selfModNum(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] = ret._data[i] % a;
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] = ret._data[i] % a.elementAt(i);
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  DoubleSeries<IT> operator %(a) => mod(a);

  void _selfPowNum(NumericSeries<IT, num> a,
      {double mfv, double ofv, bool strict: true}) {
    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        final List<int> sourcePos = _mapper[index];
        final List<int> destPos = a._mapper[index];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = math.pow((source ?? mfv), (dest ?? ofv));
            }
          }
        } else if (sourcePos.length > destPos.length) {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < destPos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = math.pow((source ?? mfv), (dest ?? ofv));
            }
          }
        } else {
          if (strict) throw new Exception('Invalid lengths at label $index!');
          for (int i = 0; i < sourcePos.length; i++) {
            final int srcIdx = sourcePos[i];
            final double source = _data[srcIdx];
            final num dest = a._data[destPos[i]];
            if ((source == null && mfv == null) ||
                (dest == null && ofv == null)) {
              _data[srcIdx] = null;
            } else {
              _data[srcIdx] = math.pow((source ?? mfv), (dest ?? ofv));
            }
          }
          // Add remaining
          {
            final lst = new List<double>(destPos.length - sourcePos.length);
            for (int i = sourcePos.length; i < destPos.length; i++) {
              lst[i] = a._data[destPos[i]]?.toDouble();
            }
            appendAll(index, lst);
          }
        }
      }
    }

    for (IT index in a._mapper.keys) {
      if (_mapper.containsKey(index)) continue;

      if (strict) throw new Exception('Invalid lengths at label $index!');

      appendAll(index, a.getByLabelMulti(index).map((v) => v.toDouble()));
    }
  }

  DoubleSeries<IT> pow(a,
      {double myFillValue,
      double otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true}) {
    DoubleSeries<IT> ret = this;

    if (!self)
      ret = new DoubleSeries._(new Float64List.fromList(_data),
          _labels.toList(), name, cloneMapper());

    if (a is DoubleSeries<IT>) {
      ret._selfPowNum(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is NumericSeries<IT, num>) {
      ret._selfPowNum(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] = math.pow(ret._data[i], a);
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] = math.pow(ret._data[i], a.elementAt(i));
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  DoubleSeries<IT> log({double fillValue = 1.0, bool self: true}) {
    if (self) {
      for (int i = 0; i < length; i++) {
        if (_data[i] == null && fillValue != null) {
          _data[i] = math.log(fillValue);
        } else {
          _data[i] = math.log(_data[i]);
        }
      }
      return this;
    } else {
      throw new UnimplementedError();
    }
  }

  DoubleSeries<IT> logN(num n, {double fillValue = 1.0, bool self: true}) {
    if (self) {
      for (int i = 0; i < length; i++) {
        if (_data[i] == null && fillValue != null) {
          _data[i] = math.log(fillValue) / math.log(n);
        } else {
          _data[i] = math.log(_data[i]) / math.log(n);
        }
      }
      return this;
    } else {
      throw new UnimplementedError();
    }
  }

  DoubleSeries<IT> log10({double fillValue = 1.0, bool self: true}) {
    if (self) {
      for (int i = 0; i < length; i++) {
        if (_data[i] == null && fillValue != null) {
          _data[i] = math.log(fillValue) / math.LN10;
        } else {
          _data[i] = math.log(_data[i]) / math.LN10;
        }
      }
      return this;
    } else {
      throw new UnimplementedError();
    }
  }

  IntSeries<IT> toInt() {
    return new IntSeries<IT>(_data.map((double v) => v.toInt()).toList(),
        name: name, labels: _labels.toList());
  }
}

class DoubleSeriesView<IT> extends DoubleSeries<IT>
    implements SeriesView<IT, double> {
  DoubleSeriesView(DoubleSeries<IT> series)
      : super._(series._data, series._labels, null, series._mapper) {
    _nameGetter = () => series.name;
  }

  Function _nameGetter;

  dynamic get name => _nameGetter();

  set name(dynamic value) {
    throw new Exception('Cannot change name of SeriesView!');
  }

  @override
  operator []=(IT index, double value) {
    if (!_mapper.containsKey(index)) {
      throw new Exception('Cannot add new elements to SeriesView!');
    }

    _mapper[index].forEach((int position) {
      _data[position] = value;
    });
  }

  DoubleSeries<IT> toSeries() =>
      new DoubleSeries(_data, name: name, labels: _labels);

  DoubleSeriesView<IT> toView() => this;
}
*/