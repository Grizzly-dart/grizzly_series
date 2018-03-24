part of grizzly.series;

abstract class SeriesMixin<LT, VT> implements Series<LT, VT> {
  List<LT> get _labels;

  Array<VT> get _data;

  SplayTreeMap<LT, int> get _mapper;

  operator []=(LT label, VT value) {
    if (!_mapper.containsKey(label)) {
      _labels.add(label);
      _data.add(value);
      _mapper[label] = _data.length - 1;
      return;
    }
    _data[_mapper[label]] = value;
  }

  void set(LT label, VT value) => this[label] = value;

  void append(LT label, VT value) {
    if (_mapper.containsKey(label))
      throw new Exception('Label already exists!');

    _labels.add(label);
    _data.add(value);
    _mapper[label] = _data.length - 1;
  }

  void insert(int pos, LT label, VT value) {
    if (pos > length) throw new RangeError.range(pos, 0, length);
    if (containsLabel(label)) drop(label);

    _updatePosOnInsert(pos);
    _mapper[label] = pos;
    _labels.insert(pos, label);
    _data.insert(pos, value);
  }

  void _updatePosOnInsert(int posLimit) {
    for (LT label in _mapper.keys) {
      int pos = _mapper[label];
      if (pos > posLimit) _mapper[label]++;
    }
  }

  void _updatePosOnRemove(int posLimit) {
    for (LT label in _mapper.keys) {
      int pos = _mapper[label];
      if (pos > posLimit) _mapper[label]--;
    }
  }

  /// Remove element at position [pos]
  void remove(int pos) {
    if (pos >= length) throw new RangeError.range(pos, 0, length);

    final LT label = _labels[pos];
    _mapper.remove(label);
    _labels.removeAt(pos);
    _data.removeAt(pos);
    _updatePosOnRemove(pos);
  }

  /// Remove multiple element at positions [positions]
  void removeMany(List<int> positions) {
    if (positions.length == 0) {
      return;
    }

    final positionSet = new Set<int>.from(positions).toList();
    positionSet.sort((int a, int b) => b.compareTo(a));
    if (positionSet.first >= length)
      throw new RangeError.range(positionSet.first, 0, length);

    for (int pos in positionSet) {
      final LT label = _labels[pos];
      _mapper.remove(label);
      _labels.removeAt(pos);
      _data.removeAt(pos);
      _updatePosOnRemove(pos);
    }
    return;
  }

  /// Drop elements by label [label]
  void drop(LT label) {
    if (!_mapper.containsKey(label)) {
      return;
    }

    final int pos = _mapper[label];
    _labels.removeAt(pos);
    _data.removeAt(pos);
    _mapper.remove(label);
    _updatePosOnRemove(pos);
  }

  /// Drop elements by label [label]
  void dropMany(/* Iterable<LT> | IterView<LT> | Labeled */ labels) {
    if (labels is IterView<LT>) {
      labels = labels.asIterable;
    } else if (labels is Labeled<LT>) {
      labels = labels.labels;
    }
    for (LT label in labels) {
      if (!_mapper.containsKey(label)) {
        continue;
      }

      final int pos = _mapper[label];
      _labels.removeAt(pos);
      _data.removeAt(pos);
      _mapper.remove(label);
      _updatePosOnRemove(pos);
    }
  }

  void assign(/* SeriesView<LT, VT> | IterView<VT> */ other,
      {bool addNew: true}) {
    if (other is SeriesView<LT, VT>) {
      for (LT label in other.labels) {
        if (containsLabel(label)) {
          final int sourcePos = _mapper[label];
          _data[sourcePos] = other[label];
        } else {
          if (addNew) set(label, other[label]);
        }
      }
    } else if (other is IterView<VT>) {
      if (length != other.length)
        throw lengthMismatch(
            expected: length, found: other.length, subject: 'other');
      for (int i = 0; i < length; i++) {
        _data[i] = other[i];
      }
    } else {
      throw new UnsupportedError('Type not supported!');
    }
  }

  void assignMap(Map<LT, VT> other, {bool addNew: true}) {
    for (LT label in other.keys) {
      if (containsLabel(label)) {
        final int sourcePos = _mapper[label];
        _data[sourcePos] = other[label];
      } else {
        if (addNew) set(label, other[label]);
      }
    }
  }

  void sortByValue({bool descending: false}) {
    final items = new List<Pair<LT, VT>>(length);
    for (int i = 0; i < length; i++) {
      items[i] = new Pair<LT, VT>(labels.elementAt(i), data[i]);
    }

    if (!descending) {
      items.sort(
          (Pair<LT, VT> a, Pair<LT, VT> b) => compareValue(a.value, b.value));
    } else {
      items.sort(
          (Pair<LT, VT> a, Pair<LT, VT> b) => compareValue(b.value, a.value));
    }

    for (int i = 0; i < items.length; i++) {
      Pair<LT, VT> item = items[i];
      _labels[i] = item.key;
      _data[i] = item.value;
      _mapper[item.key] = i;
    }
  }

  void sortByLabel({bool descending: false}) {
    List<LT> labelsSorted = _mapper.keys.toList();
    if (descending) {
      labelsSorted = labelsSorted.reversed.toList();
    }

    final labs = new List<LT>(length);
    final d = makeValueArraySized(length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int c = 0; c < length; c++) {
      LT lab = labelsSorted[c];

      labs[c] = lab;
      d[c] = this[lab];
      mapper[lab] = c;
    }

    _labels.replaceRange(0, _labels.length, labs);
    _data.assign(d);
    _mapper.clear();
    _mapper.addAll(mapper);
  }

  void keep(mask) {
    if (mask is BoolSeriesViewBase<LT>) {
      keepIf(mask);
      return;
    } else if (mask is Labeled<LT>) {
      keepOnly(mask);
      return;
    } else if (mask is Iterable<LT> || mask is IterView<LT>) {
      keepLabels(mask);
      return;
    } else if (mask is SeriesCond<LT, VT>) {
      keepWhen(mask);
      return;
    }
    throw new UnimplementedError();
  }

  void keepOnly(Labeled<LT> mask) {
    if (length != mask.labels.length)
      throw lengthMismatch(
          expected: length, found: mask.labels.length, subject: 'mask');

    final pos = <int>[];
    for (LT lab in labels) {
      if (!mask.containsLabel(lab)) pos.add(posOf(lab));
    }
    removeMany(pos);
  }

  void keepLabels(/* Iterable<LT> | IterView<LT> */ mask) {
    if (mask is IterView<LT>) {
      mask = mask.asIterable;
    }
    if (mask is Iterable<LT>) {
      if (length != mask.length)
        throw lengthMismatch(
            expected: length, found: mask.length, subject: 'mask');

      keepOnly(new BoolSeriesView.constant(true, labels: mask));
      return;
    }
    throw new UnimplementedError();
  }

  void keepIf(BoolSeriesViewBase<LT> mask) {
    if (length != mask.length)
      throw lengthMismatch(
          expected: length, found: mask.length, subject: 'mask');

    final pos = <int>[];
    for (LT lab in labels) {
      if (!mask.containsLabel(lab) || !mask[lab]) pos.add(posOf(lab));
    }
    removeMany(pos);
  }

  void keepWhen(SeriesCond<LT, VT> cond) {
    final pos = <int>[];
    for (LT lab in labels) {
      if (!cond(lab, this)) pos.add(posOf(lab));
    }
    removeMany(pos);
  }

  NumericSeries<LT, int> get asInt => this as NumericSeries<LT, int>;

  NumericSeries<LT, double> get asDouble => this as NumericSeries<LT, double>;

  BoolSeriesBase<LT> get asBool => this as BoolSeriesBase<LT>;

  StringSeriesBase<LT> get asString => this as StringSeriesBase<LT>;

  DynamicSeriesBase<LT> get asDynamic => this as DynamicSeriesBase<LT>;
}
