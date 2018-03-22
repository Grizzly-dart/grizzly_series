part of grizzly.series;

class IntSeries<LT> extends Object
    with
        SeriesViewMixin<LT, int>,
        SeriesFixMixin<LT, int>,
        SeriesMixin<LT, int>,
        IntSeriesViewMixin<LT>
    implements IntSeriesFix<LT>, NumericSeries<LT, int> {
  final List<LT> _labels;

  final Int1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  IntSeries._(this._labels, this._data, this._name, this._mapper);

  IntSeries._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory IntSeries(/* Iterable<int> | IterView<int> */ data,
      {dynamic name, Iterable<LT> labels}) {
    Int1D d;
    if (data is Iterable<int>) {
      d = new Int1D(data);
    } else if (data is IterView<int>) {
      d = new Int1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new IntSeries._build(madeLabels, d, name);
  }

  factory IntSeries.fromMap(Map<LT, int> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = new List<LT>()..length = map.length;
    final data = new Int1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new IntSeries._(labels, data, name, mapper);
  }

  factory IntSeries.copy(SeriesView<LT, int> series, {name}) =>
      new IntSeries(series.data,
          name: name ?? series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  Int1DView get data => _data.view;

  IntSeriesView<LT> _view;

  IntSeriesView<LT> get view =>
      _view ??= new IntSeriesView<LT>._(_labels, _data, () => name, _mapper);

  IntSeriesFix<LT> _fixed;

  IntSeriesFix<LT> get fixed =>
      _fixed ??= new IntSeriesFix<LT>._(_labels, _data, () => name, _mapper);

  String get name => _name is Function ? _name() : _name.toString();

  Stats<int> get stats => _data.stats;

  @override
  void negate() {
    _data.negate();
  }
}

/*
  void _selfAdd(IntSeries<IT> a, {int mfv, int ofv, bool strict: true}) {
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
              _data[srcIdx] = (source ?? mfv) + (dest ?? ofv);
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
              _data[srcIdx] = (source ?? mfv) + (dest ?? ofv);
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
              _data[srcIdx] = (source ?? mfv) + (dest ?? ofv);
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

  IntSeries<IT> addition(a,
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
      ret._selfAdd(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is DoubleSeries<IT>) {
      ret._selfAdd(a.toInt(),
          mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is int) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] += a;
      }
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] += a.toInt();
      }
    } else if (a is Iterable<int>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] += a.elementAt(i);
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] += a.elementAt(i).toInt();
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  IntSeries<IT> operator +(a) => addition(a);

  void _selfSub(IntSeries<IT> a, {int mfv, int ofv, bool strict: true}) {
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
              _data[srcIdx] = (source ?? mfv) - (dest ?? ofv);
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
              _data[srcIdx] = (source ?? mfv) - (dest ?? ofv);
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
              _data[srcIdx] = (source ?? mfv) - (dest ?? ofv);
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

  IntSeries<IT> subtract(a,
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
      ret._selfSub(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is DoubleSeries<IT>) {
      ret._selfSub(a.toInt(),
          mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is int) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] -= a;
      }
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] -= a.toInt();
      }
    } else if (a is Iterable<int>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] -= a.elementAt(i);
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] -= a.elementAt(i).toInt();
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  IntSeries<IT> operator -(a) => subtract(a);

  void _selfMul(IntSeries<IT> a, {int mfv, int ofv, bool strict: true}) {
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
              _data[srcIdx] = (source ?? mfv) * (dest ?? ofv);
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
              _data[srcIdx] = (source ?? mfv) * (dest ?? ofv);
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
              _data[srcIdx] = (source ?? mfv) * (dest ?? ofv);
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

  IntSeries<IT> multiply(a,
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
      ret._selfMul(a, mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is DoubleSeries<IT>) {
      ret._selfMul(a.toInt(),
          mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is int) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] *= a;
      }
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] *= a.toInt();
      }
    } else if (a is Iterable<int>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] *= a.elementAt(i);
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] *= a.elementAt(i).toInt();
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  IntSeries<IT> operator *(a) => multiply(a);

  DoubleSeries<IT> divide(a,
      {int myFillValue,
      int otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true}) {
    if (self) throw new UnsupportedError('Log results are double!');
    return toDouble().divide(a,
        myFillValue: myFillValue.toDouble(),
        otherFillValue: otherFillValue.ceilToDouble(),
        name: name,
        self: true,
        strict: strict);
  }

  DoubleSeries<IT> operator /(a) => divide(a);

  void _selfTruncDiv(IntSeries<IT> a, {int mfv, int ofv, bool strict: true}) {
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
              _data[srcIdx] = (source ?? mfv) ~/ (dest ?? ofv);
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
              _data[srcIdx] = (source ?? mfv) ~/ (dest ?? ofv);
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
              _data[srcIdx] = (source ?? mfv) ~/ (dest ?? ofv);
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

  IntSeries<IT> truncDiv(a,
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
      ret._selfTruncDiv(a,
          mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is DoubleSeries<IT>) {
      ret._selfTruncDiv(a.toInt(),
          mfv: myFillValue, ofv: otherFillValue, strict: strict);
    } else if (a is int) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] ~/= a;
      }
    } else if (a is num) {
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] ~/= a.toInt();
      }
    } else if (a is Iterable<int>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] ~/= a.elementAt(i);
      }
    } else if (a is Iterable<num>) {
      if (length != a.length) {
        throw new Exception('Length mismatch!');
      }
      for (int i = 0; i < _data.length; i++) {
        ret._data[i] ~/= a.elementAt(i).toInt();
      }
    } else {
      throw new Exception('Unknown type!');
    }

    return ret;
  }

  IntSeries<IT> operator ~/(a) => truncDiv(a);

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
