part of grizzly.series;

class DoubleSeries<LT> extends Object
    with
        SeriesViewMixin<LT, double>,
        SeriesFixMixin<LT, double>,
        SeriesMixin<LT, double>,
        DoubleSeriesViewMixin<LT>
    implements NumericSeries<LT, double> {
  final List<LT> _labels;

  final Double1D _data;

  final SplayTreeMap<LT, int> _mapper;

  String name;

  DoubleSeries._(this._labels, this._data, this.name, this._mapper);

  DoubleSeries._build(this._labels, this._data, this.name)
      : _mapper = labelsToMapper(_labels);

  factory DoubleSeries(/* Iterable<int> | IterView<int> */ data,
      {dynamic name, Iterable<LT> labels}) {
    Double1D d;
    if (data is Iterable<double>) {
      d = new Double1D(data);
    } else if (data is IterView<double>) {
      d = new Double1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new DoubleSeries._build(madeLabels, d, name);
  }

  factory DoubleSeries.fromMap(Map<LT, double> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = new List<LT>()..length = map.length;
    final data = new Double1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new DoubleSeries._(labels, data, name, mapper);
  }

  factory DoubleSeries.copy(SeriesView<LT, double> series,
      {name, Iterable<LT> labels}) {
    // TODO
  }

  Iterable<LT> get labels => _labels;

  Numeric1DView<double> get data => _data.view;

  DoubleSeriesView<LT> _view;

  DoubleSeriesView<LT> get view =>
      _view ??= new DoubleSeriesView<LT>._(_labels, _data, () => name, _mapper);

  DoubleSeriesFix<LT> _fixed;

  DoubleSeriesFix<LT> get fixed =>
      _fixed ??= new DoubleSeriesFix<LT>._(_labels, _data, () => name, _mapper);
}

/*
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
  }
  */
