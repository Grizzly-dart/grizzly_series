part of grizzly.series;

abstract class SeriesMixin<LT, VT> implements Series<LT, VT> {
  List<LT> get _labels;

  List<VT> get _data;

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

  void setByPos(int position, VT value) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    _data[position] = value;
  }

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

  void assign(SeriesView<LT, VT> other) {
    // Check
    for (LT key in _mapper.keys) {
      if (!other.containsIndex(key)) continue;

      final int sourcePos = _mapper[key];
      final int destPos = other._mapper[key];

      if (sourcePos.length != destPos.length) {
        if (destPos.length != 1) {
          throw new Exception('Mismatch of value lengths by label!');
        }
      }
    }

    // Assign
    for (LT key in _mapper.keys) {
      if (!other.containsIndex(key)) continue;

      final List<int> sourcePos = _mapper[key];
      final List<int> destPos = other._mapper[key];

      if (sourcePos.length == destPos.length) {
        for (int i = 0; i < sourcePos.length; i++) {
          _data[sourcePos[i]] = other.data[destPos[i]];
        }
      } else {
        final VT destData = other.data[destPos.first];
        for (int pos in sourcePos) {
          _data[pos] = destData;
        }
      }
    }
  }

  void apply(VT func(VT value)) {
    for (int i = 0; i < length; i++) {
      _data[i] = func(_data[i]);
    }
  }

  Series<LT, VT> sortByValue(
      {bool ascending: true, bool inplace: false, name}) {
    if (length == 0) {
      if (inplace)
        return this;
      else
        return make([], labels: [], name: name ?? this.name);
    }

    final items = <SeriesValueSortItem<LT, VT>>[];

    for (int i = 0; i < length; i++) {
      items.add(new SeriesValueSortItem(_labels[i], _data[i]));
    }

    if (ascending) {
      items.sort(SeriesValueSortItem.compare);
    } else {
      items.sort((a, b) => SeriesValueSortItem.compare(b, a));
    }

    if (inplace) {
      final idx = <LT>[];
      final List<VT> d = <VT>[];
      final mapper = new SplayTreeMap<LT, List<int>>();

      for (SeriesValueSortItem i in items) {
        idx.add(i.label);
        d.add(i.value);
        if (!mapper.containsKey(i.label)) mapper[i.label] = <int>[];
        mapper[i.label].add(idx.length - 1);
      }

      _labels.replaceRange(0, _labels.length, idx);
      _labels.replaceRange(0, _labels.length, idx);
      _data.replaceRange(0, _data.length, d);
      _mapper.clear();
      _mapper.addAll(mapper);

      return this;
    } else {
      final idx = <LT>[];
      final List<VT> d = <VT>[];

      for (SeriesValueSortItem i in items) {
        idx.add(i.label);
        d.add(i.value);
      }

      return make(d, name: name ?? this.name, labels: idx);
    }
  }

  Series<LT, VT> sortByIndex(
      {bool ascending: true, bool inplace: false, name}) {
    List<LT> idxSorted = _mapper.keys.toList();

    sortList(idxSorted, ascending);

    if (inplace) {
      final idx = <LT>[];
      final List<VT> d = <VT>[];
      final mapper = new SplayTreeMap<LT, List<int>>();

      for (LT i in idxSorted) {
        mapper[i] = <int>[];
        for (int pos in _mapper[i]) {
          idx.add(i);
          d.add(_data[pos]);
          mapper[i].add(idx.length - 1);
        }
      }

      _labels.replaceRange(0, _labels.length, idx);
      _data.replaceRange(0, _data.length, d);
      _mapper.clear();
      _mapper.addAll(mapper);

      return this;
    } else {
      final idx = <LT>[];
      final List<VT> d = <VT>[];

      for (LT i in idxSorted) {
        for (int pos in _mapper[i]) {
          idx.add(i);
          d.add(_data[pos]);
        }
      }

      return make(d, name: name ?? this.name, labels: idx);
    }
  }

  SplayTreeMap<LT, List<int>> cloneMapper() {
    final ret = new SplayTreeMap<LT, List<int>>();

    for (LT label in _mapper.keys) {
      ret[label] = new List<int>.from(_mapper[label]);
    }

    return ret;
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
