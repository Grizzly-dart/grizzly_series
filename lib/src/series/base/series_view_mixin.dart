part of grizzly.series;

abstract class SeriesViewMixin<LT, VT> implements SeriesView<LT, VT> {
  List<LT> get _labels;

  List<VT> get _data;

  SplayTreeMap<LT, int> get _mapper;

  int get length => _data.length;

  bool containsIndex(LT label) => _mapper.containsKey(label);

  VT operator [](LT label) {
    if (!_mapper.containsKey(label)) {
      throw new Exception("Index named $label not found!");
    }
    return _data[_mapper[label]];
  }

  VT get(LT label) => this[label];

  VT getByPos(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return _data[position];
  }

  LT labelAt(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return _labels[position];
  }

  @override
  int posOf(LT label) => _mapper[label];

  Pair<LT, VT> pairByLabel(LT label) => pair<LT, VT>(label, this[label]);

  Pair<LT, VT> pairByPos(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return pair<LT, VT>(_labels[position], _data[position]);
  }

  Iterable<Pair<LT, VT>> get enumerate =>
      Ranger.indices(length - 1).map(pairByPos);

  Iterable<Pair<LT, VT>> enumerateSliced(int start, [int end]) {
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

  Series<int, VT> mode() {
    final LinkedHashMap<VT, int> map = new LinkedHashMap<VT, int>();
    int max = 0;

    for (VT v in _data) {
      if (!map.containsKey(v)) map[v] = 0;
      map[v]++;
      if (map[v] > max) max = map[v];
    }

    if (max == 0) return make<int>([], labels: []);

    final ret = <VT>[];

    for (VT k in map.keys) {
      if (map[k] != max) continue;
      ret.add(k);
    }

    return make<int>(ret,
        labels: new List<int>.generate(ret.length, (int i) => i));
  }

  StringSeries<LT> toStringSeries() {
    return new StringSeries<LT>(_data.map((v) => v.toString()).toList(),
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

  DataFrame<LT, dynamic> toDataFrame<CT>({CT column}) {
    return new DataFrame<LT, CT>({column ?? name: data}, labels: labels);
  }
}
