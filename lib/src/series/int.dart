part of grizzly.series;

class IntSeries<IT> extends Object
    with SeriesBase<IT, int>, NumericSeries<IT, int>
    implements Series<IT, int> {
  final List<IT> _labels;

  final List<int> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> labels;

  final UnmodifiableListView<int> data;

  SeriesPositioned<IT, int> _pos;

  SeriesPositioned<IT, int> get pos => _pos;

  IntSeriesView<IT> _view;

  IntSeriesView<IT> toView() {
    if (_view == null) _view = new IntSeriesView<IT>(this);
    return _view;
  }

  IntSeries._(this._data, this._labels, this.name, this._mapper)
      : labels = new UnmodifiableListView(_labels),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, int>(this);
  }

  factory IntSeries(Iterable<int> data, {dynamic name, List<IT> labels}) {
    final List<IT> madeIndices = makeLabels<IT>(data.length, labels, IT);
    final mapper = labelsToPosMapper(madeIndices);

    return new IntSeries._(data.toList(), madeIndices, name, mapper);
  }

  factory IntSeries.fromMap(Map<IT, List<int>> map, {dynamic name}) {
    final List<IT> indices = [];
    final data = new List<int>();
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (num val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new IntSeries._(data, indices, name, mapper);
  }

  IntSeries<IIT> makeNew<IIT>(Iterable<int> data,
      {dynamic name, List<IIT> labels}) {
    return new IntSeries<IIT>(data, name: name, labels: labels);
  }

  int sum({bool skipNull: true}) {
    int ret = 0;
    for (int i = 0; i < _data.length; i++) {
      if (data[i] != null)
        ret += data[i];
      else if (!skipNull) return null;
    }
    return ret;
  }

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

  DoubleSeries<IT> log({int fillValue = 1, bool self: false}) {
    if (self) throw new UnsupportedError('Log results are double!');
    return toDouble().log(fillValue: fillValue.toDouble(), self: true);
  }

  DoubleSeries<IT> logN(num n, {int fillValue = 1, bool self: false}) {
    if (self) throw new UnsupportedError('Log results are double!');
    return toDouble().logN(n, fillValue: fillValue.toDouble(), self: true);
  }

  DoubleSeries<IT> log10({int fillValue = 1, bool self: false}) {
    if (self) throw new UnsupportedError('Log results are double!');
    return toDouble().log10(fillValue: fillValue.toDouble(), self: true);
  }

  DoubleSeries<IT> toDouble() {
    return new DoubleSeries<IT>(_data.map((int v) => v.toDouble()).toList(),
        name: name, labels: _labels.toList());
  }
}

abstract class SeriesView<IT, VT> implements Series<IT, VT> {
  Series<IT, VT> toSeries();
}

class IntSeriesView<IT> extends IntSeries<IT>
    with SeriesViewBase<IT, int>
    implements SeriesView<IT, int> {
  IntSeriesView(IntSeries<IT> series)
      : super._(series._data, series._labels, null, series._mapper) {
    _nameGetter = () => series.name;
  }

  Function _nameGetter;

  dynamic get name => _nameGetter();

  set name(dynamic value) {
    throw new Exception('Cannot change name of SeriesView!');
  }

  @override
  operator []=(IT index, int value) {
    if (!_mapper.containsKey(index)) {
      throw new Exception('Cannot add new elements to SeriesView!');
    }

    _mapper[index].forEach((int position) {
      _data[position] = value;
    });
  }

  IntSeries<IT> toSeries() => new IntSeries(_data, name: name, labels: _labels);

  @override
  IntSeriesView<IT> toView() => this;
}

abstract class SeriesViewBase<IT, VT> implements SeriesView<IT, VT> {
  /// Appends a value [value] with index [index] into the series
  ///
  /// append is not supported on [SeriesView]. Throws an exception if the
  /// operation is attempted on a [SeriesView].
  void append(IT index, VT value) {
    throw new Exception('Cannot add new elements to SeriesView!');
  }

  /// Remove element at position [pos]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> remove(int pos, {bool inplace: false}) {
    throw new Exception('Cannot remove elements from SeriesView!');
  }

  /// Drop elements by label [label]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> drop(IT label, {bool inplace: false}) {
    throw new Exception('Cannot remove elements from SeriesView!');
  }

  Series<IT, VT> sortByValue(
      {bool ascending: true, bool inplace: false, name}) {
    if (inplace) throw new Exception('Cannot sort SeriesView!');
    return sortByValue(ascending: ascending, name: name);
  }

  SeriesView<IT, VT> sortByIndex(
      {bool ascending: true, bool inplace: false, name}) {
    if (inplace) throw new Exception('Cannot sort SeriesView!');
    return sortByIndex(ascending: ascending, name: name);
  }
}
