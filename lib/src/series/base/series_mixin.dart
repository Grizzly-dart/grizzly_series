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
  void dropMany(List<LT> label) {
    final labs = new Set<LT>.from(label);

    for (LT label in labs) {
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

  void assign(/* Series<LT, VT> | IterView<VT> */ other, {bool addNew: true}) {
    if (other is Series<LT, VT>) {
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
          (Pair<LT, VT> a, Pair<LT, VT> b) => compareVT(a.value, b.value));
    } else {
      items.sort(
          (Pair<LT, VT> a, Pair<LT, VT> b) => compareVT(b.value, a.value));
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
    final d = makeVTArraySized(length);
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

  /*
  SplayTreeMap<LT, List<int>> cloneMapper() {
    final ret = new SplayTreeMap<LT, List<int>>();

    for (LT label in _mapper.keys) {
      ret[label] = new List<int>.from(_mapper[label]);
    }

    return ret;
  }
  */

  @override
  void mask(IterView<bool> mask) {
    if (length != mask.length)
      throw lengthMismatch(
          expected: length, found: mask.length, subject: 'mask');

    final pos = <int>[];
    for (int i = 0; i < length; i++) {
      if (!mask[i]) pos.add(i);
    }
    removeMany(pos);
  }

  String toString() {
    final sb = new StringBuffer();

    //TODO print as table
    for (int i = 0; i < labels.length; i++) {
      sb.writeln('${_labels[i]} ${_data[i]}');
    }

    return sb.toString();
  }
}
