part of grizzly.series;

abstract class SeriesBase<IT, VT> implements Series<IT, VT> {
  List<IT> get _labels;

  List<VT> get _data;

  SplayTreeMap<IT, List<int>> get _mapper;

  int get length => _data.length;

  bool containsIndex(IT label) => _mapper.containsKey(label);

  VT operator [](IT label) {
    if (!_mapper.containsKey(label)) {
      throw new Exception("Index named $label not found!");
    }

    return _data[_mapper[label].first];
  }

  operator []=(IT label, VT value) {
    if (!_mapper.containsKey(label)) {
      _labels.add(label);
      _data.add(value);
      _mapper[label].add(_data.length - 1);
      return;
    }

    _mapper[label].forEach((int position) {
      _data[position] = value;
    });
  }

  VT getByPos(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return _data[position];
  }

  void setByPos(int position, VT value) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    _data[position] = value;
  }

  VT getByLabel(IT label) => this[label];

  void setByLabel(IT label, VT value) => this[label] = value;

  List<VT> getByLabelMulti(IT label) {
    if (!_mapper.containsKey(label)) {
      throw new Exception("Index named $label not found!");
    }

    return _mapper[label].map((int pos) => _data[pos]).toList();
  }

  IT labelAt(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return _labels[position];
  }

  Pair<IT, VT> pairByLabel(IT label) => pair<IT, VT>(label, this[label]);

  Pair<IT, VT> pairByPos(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return pair<IT, VT>(_labels[position], _data[position]);
  }

  Iterable<Pair<IT, VT>> enumerate() =>
      Ranger.indices(length - 1).map(pairByPos);

  Iterable<Pair<IT, VT>> enumerateSliced(int start, [int end]) {
    if (end == null)
      end = length - 1;
    else {
      if (end > length - 1) {
        throw new ArgumentError.value(end, 'end', 'Out of range');
      }
    }

    if (start > length - 1) {
      throw new ArgumentError.value(start, 'start', 'Out of range');
    }

    return Ranger.range(start, end).map(pairByPos);
  }

  void append(IT label, VT value) {
    _labels.add(label);
    _data.add(value);

    if (!_mapper.containsKey(label)) {
      _mapper[label] = new List<int>()..add(_data.length - 1);
    } else {
      _mapper[label].add(_data.length - 1);
    }
  }

  void appendAll(IT label, Iterable<VT> values) {
    if (values.length == 0) return;

    final int start = _data.length - 1;
    _data.addAll(values);

    List<int> poses = <int>[];
    if (!_mapper.containsKey(label)) {
      _mapper[label] = poses;
    } else {
      poses = _mapper[label];
    }

    for (int i = start; i < _data.length; i++) {
      _labels.add(label);
      poses.add(i);
    }
  }

  void _updatePosOnRemove(int posLimit) {
    _mapper.forEach((_, List<int> list) {
      for (int i = 0; i < list.length; i++) {
        if (list[i] > posLimit) list[i]--;
      }
    });
  }

  /// Remove element at position [pos]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> remove(int pos, {bool inplace: false}) {
    if (pos >= length) throw new RangeError.range(pos, 0, length);
    if (inplace) {
      final IT label = _labels[pos];
      _mapper[label].remove(pos);
      if (_mapper[label].length == 0) _mapper.remove(label);
      _labels.removeAt(pos);
      _data.removeAt(pos);
      _updatePosOnRemove(pos);
      return this;
    } else {
      final List<IT> idx = _labels.toList();
      final List<VT> d = _data.toList();

      idx.removeAt(pos);
      d.removeAt(pos);

      return makeNew(d, name: name, labels: idx);
    }
  }

  /// Remove multiple element at positions [positions]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> removeMany(List<int> positions, {bool inplace: false}) {
    if (positions.length == 0) {
      //TODO we should accept this
      throw new Exception('positions cannot be empty List!');
    }

    final positionSet = new Set<int>.from(positions).toList();
    positionSet.sort((int a, int b) => b.compareTo(a));
    if (positionSet.first >= length)
      throw new RangeError.range(positionSet.first, 0, length);

    if (inplace) {
      for (int pos in positionSet) {
        final IT label = _labels[pos];
        _mapper[label].remove(pos);
        if (_mapper[label].length == 0) _mapper.remove(label);
        _labels.removeAt(pos);
        _data.removeAt(pos);
        _updatePosOnRemove(pos);
      }
      return this;
    } else {
      final List<IT> idx = _labels.toList();
      final List<VT> d = _data.toList();

      for (int pos in positionSet) {
        idx.removeAt(pos);
        d.removeAt(pos);
      }

      return makeNew(d, name: name, labels: idx);
    }
  }

  /// Drop elements by label [label]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> drop(IT label, {bool inplace: false}) {
    if (!_mapper.containsKey(label)) {
      //TODO should we ignore this?
      throw new Exception('Label not found!');
    }

    if (inplace) {
      final List<int> poses = _mapper[label].toList();
      poses.sort((int a, int b) => b.compareTo(a));
      for (int pos in poses) {
        _labels.removeAt(pos);
        _data.removeAt(pos);
        _updatePosOnRemove(pos);
      }
      _mapper.remove(label);
      return this;
    } else {
      final List<IT> idx = _labels.toList();
      final List<VT> d = _data.toList();

      final List<int> poses = _mapper[label].toList();
      poses.sort((int a, int b) => b.compareTo(a));
      for (int pos in poses) {
        idx.removeAt(pos);
        d.removeAt(pos);
      }

      return makeNew(d, name: name, labels: idx);
    }
  }

  /// Drop elements by label [label]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> dropMany(List<IT> label, {bool inplace: false}) {
    final List<IT> labelSet =
        label.where((IT lab) => _mapper.containsKey(lab)).toList();
    final positionSet = labelSet.fold(new Set<int>(), (Set<int> set, IT lab) {
      List<int> pos = _mapper[lab];
      set.addAll(pos);
      return set;
    }).toList()
      ..sort((int a, int b) => b.compareTo(a));

    if (inplace) {
      labelSet.forEach((IT idx) => _mapper.remove(idx));
      for (int pos in positionSet) {
        _labels.removeAt(pos);
        _data.removeAt(pos);
        _updatePosOnRemove(pos);
      }
      return this;
    } else {
      final List<IT> idx = _labels.toList();
      final List<VT> d = _data.toList();

      for (int pos in positionSet) {
        idx.removeAt(pos);
        d.removeAt(pos);
      }

      return makeNew(d, name: name, labels: idx);
    }
  }

  void assign(Series<IT, VT> other) {
    // Check
    for (IT key in _mapper.keys) {
      if (!other.containsIndex(key)) continue;

      final List<int> sourcePos = _mapper[key];
      final List<int> destPos = other._mapper[key];

      if (sourcePos.length != destPos.length) {
        if (destPos.length != 1) {
          throw new Exception('Mismatch of value lengths by label!');
        }
      }
    }

    // Assign
    for (IT key in _mapper.keys) {
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

  Series<int, VT> mode() {
    final LinkedHashMap<VT, int> map = new LinkedHashMap<VT, int>();
    int max = 0;

    for (VT v in _data) {
      if (!map.containsKey(v)) map[v] = 0;
      map[v]++;
      if (map[v] > max) max = map[v];
    }

    if (max == 0) return makeNew<int>([], labels: []);

    final ret = <VT>[];

    for (VT k in map.keys) {
      if (map[k] != max) continue;
      ret.add(k);
    }

    return makeNew<int>(ret,
        labels: new List<int>.generate(ret.length, (int i) => i));
  }

  StringSeries<IT> toStringSeries() {
    return new StringSeries<IT>(_data.map((v) => v.toString()).toList(),
        name: name, labels: _labels.toList());
  }

  @override
  IntSeries<VT> valueCounts(
      {bool sortByValue: false,
      bool ascending: false,
      bool dropNull: false,
      dynamic name}) {
    final groups = new Map<VT, List<int>>();

    for (int i = 0; i < length; i++) {
      final VT v = _data[i];
      if (!groups.containsKey(v)) groups[v] = <int>[0];
      groups[v][0]++;
    }

    // Drop null
    if (dropNull) {
      groups.remove(null);
    }

    final ret = new IntSeries<VT>.fromMap(groups, name: name ?? this.name);

    // Sort
    if (sortByValue) {
      ret.sortByIndex(ascending: ascending, inplace: true);
    } else {
      ret.sortByValue(ascending: ascending, inplace: true);
    }

    return ret;
  }

  DataFrame<IT, dynamic> toDataFrame<CT>({CT column}) {
    return new DataFrame<IT, CT>({column ?? name: data}, labels: labels);
  }

  Series<IT, VT> sortByValue(
      {bool ascending: true, bool inplace: false, name}) {
    if (length == 0) {
      if (inplace)
        return this;
      else
        return makeNew([], labels: [], name: name ?? this.name);
    }

    final items = <SeriesValueSortItem<IT, VT>>[];

    for (int i = 0; i < length; i++) {
      items.add(new SeriesValueSortItem(_labels[i], _data[i]));
    }

    if (ascending) {
      items.sort(SeriesValueSortItem.compare);
    } else {
      items.sort((a, b) => SeriesValueSortItem.compare(b, a));
    }

    if (inplace) {
      final idx = <IT>[];
      final List<VT> d = <VT>[];
      final mapper = new SplayTreeMap<IT, List<int>>();

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
      final idx = <IT>[];
      final List<VT> d = <VT>[];

      for (SeriesValueSortItem i in items) {
        idx.add(i.label);
        d.add(i.value);
      }

      return makeNew(d, name: name ?? this.name, labels: idx);
    }
  }

  Series<IT, VT> sortByIndex(
      {bool ascending: true, bool inplace: false, name}) {
    List<IT> idxSorted = _mapper.keys.toList();

    sortList(idxSorted, ascending);

    if (inplace) {
      final idx = <IT>[];
      final List<VT> d = <VT>[];
      final mapper = new SplayTreeMap<IT, List<int>>();

      for (IT i in idxSorted) {
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
      final idx = <IT>[];
      final List<VT> d = <VT>[];

      for (IT i in idxSorted) {
        for (int pos in _mapper[i]) {
          idx.add(i);
          d.add(_data[pos]);
        }
      }

      return makeNew(d, name: name ?? this.name, labels: idx);
    }
  }

  SplayTreeMap<IT, List<int>> cloneMapper() {
    final ret = new SplayTreeMap<IT, List<int>>();

    for (IT label in _mapper.keys) {
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
