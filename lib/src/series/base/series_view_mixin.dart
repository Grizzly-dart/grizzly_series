part of grizzly.series;

abstract class SeriesViewMixin<LT, VT> implements SeriesView<LT, VT> {
  SplayTreeMap<LT, int> get _mapper;

  int get length => data.length;

  @override
  List<VT> toList() => data.toList();

  bool containsLabel(LT label) => _mapper.containsKey(label);

  VT operator [](LT label) {
    if (!_mapper.containsKey(label)) throw labelNotFound(label);
    return data[_mapper[label]];
  }

  VT get(LT label) => this[label];

  VT getByPos(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return data[position];
  }

  LT labelAt(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return labels.elementAt(position);
  }

  @override
  int posOf(LT label) => _mapper[label];

  Pair<LT, VT> pairByLabel(LT label) => pair<LT, VT>(label, this[label]);

  Pair<LT, VT> pairByPos(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return pair<LT, VT>(labels.elementAt(position), data[position]);
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

    for (VT v in data.asIterable) {
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
    return new StringSeries<LT>(data.toStringArray(),
        name: name, labels: labels);
  }

  @override
  IntSeries<VT> valueCounts(
      {bool sortByValue: false,
      bool descending: false,
      bool dropNull: false,
      dynamic name}) {
    final groups = new Map<VT, int>();

    for (int i = 0; i < length; i++) {
      final VT v = data[i];
      if (!groups.containsKey(v)) groups[v] = 0;
      groups[v]++;
    }

    // Drop null
    if (dropNull) groups.remove(null);

    final ret = new IntSeries<VT>.fromMap(groups, name: name ?? this.name);

    // Sort
    if (sortByValue) {
      ret.sortByLabel(descending: descending);
    } else {
      ret.sortByValue(descending: descending);
    }

    return ret;
  }

  DataFrame<LT> toDataFrame({String column}) {
    return new DataFrame<LT>({column ?? name: data}, labels: labels);
  }

  bool labelsMatch(
      final /* IterView<LT> | Labeled<LT> | Iterable<LT> */ labels) {
    if (labels is IterView<LT>) {
      return _iterEquality.equals(this.labels, labels.asIterable);
    } else if (labels is Labeled<LT>) {
      return _iterEquality.equals(this.labels, labels.labels);
    } else if (labels is Iterable<LT>) {
      return _iterEquality.equals(this.labels, labels);
    }
    throw new UnsupportedError('Type not supported!');
  }

  String toString() {
    final Table tab = table(['', name]);
    for (int i = 0; i < length; i++) {
      tab.row([labelAt(i), getByPos(i)]);
    }
    return tab.toString();
  }

  @override
  BoolSeriesBase<LT> eq(
      /* E | IterView<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is VT) {
      return new BoolSeries<LT>(data.eq(other), name: name, labels: labels);
    } else if (other is SeriesView<LT, VT>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] == other[label];
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<VT> || other is Iterable<VT>) {
      return new BoolSeries<LT>(data.eq(other), name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> ne(
      /* E | IterView<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is VT) {
      return new BoolSeries<LT>(data.ne(other), name: name, labels: labels);
    } else if (other is SeriesView<LT, VT>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] != other[label];
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<VT> || other is Iterable<VT>) {
      return new BoolSeries<LT>(data.ne(other), name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  BoolSeriesBase<LT> operator >=(
      /* VT | IterView<VT> | SeriesView<VT> | ArrayView<VT> */ other) {
    if (other is VT) {
      return new BoolSeries<LT>(data >= other, name: name, labels: labels);
    } else if (other is SeriesView<LT, VT>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = compareValue(data[i], other[label]) >= 0;
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<VT> || other is Iterable<VT>) {
      return new BoolSeries<LT>(data >= other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  BoolSeriesBase<LT> operator >(
      /* E | IterView<E> | SeriesView<E> | ArrayView<E> */ other) {
    if (other is VT) {
      return new BoolSeries<LT>(data > other, name: name, labels: labels);
    } else if (other is SeriesView<LT, VT>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = compareValue(data[i], other[label]) > 0;
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<VT> || other is Iterable<VT>) {
      return new BoolSeries<LT>(data > other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  BoolSeriesBase<LT> operator <(
      /* E | IterView<E> | SeriesView<E> | ArrayView<E> */ other) {
    if (other is VT) {
      return new BoolSeries<LT>(data < other, name: name, labels: labels);
    } else if (other is SeriesView<LT, VT>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = compareValue(data[i], other[label]) < 0;
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<VT> || other is Iterable<VT>) {
      return new BoolSeries<LT>(data < other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  BoolSeriesBase<LT> operator <=(
      /* E | IterView<E> | SeriesView<E> | ArrayView<E> */ other) {
    if (other is VT) {
      return new BoolSeries<LT>(data <= other, name: name, labels: labels);
    } else if (other is SeriesView<LT, VT>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = compareValue(data[i], other[label]) <= 0;
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<VT> || other is Iterable<VT>) {
      return new BoolSeries<LT>(data <= other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  NumericSeriesView<LT, int> get asInt => this as NumericSeriesView<LT, int>;

  NumericSeriesView<LT, double> get asDouble =>
      this as NumericSeriesView<LT, double>;

  BoolSeriesViewBase<LT> get asBool => this as BoolSeriesViewBase<LT>;

  StringSeriesViewBase<LT> get asString => this as StringSeriesViewBase<LT>;

  DynamicSeriesViewBase<LT> get asDynamic => this as DynamicSeriesViewBase<LT>;
}

const IterableEquality _iterEquality = const IterableEquality();
