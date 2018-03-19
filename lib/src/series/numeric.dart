part of grizzly.series;

/* TODO
abstract class NumericSeries<IT, VT extends num> implements Series<IT, VT> {
  List<IT> get _labels;

  List<VT> get _data;

  SplayTreeMap<IT, List<int>> get _mapper;

  void abs() {
    for (int i = 0; i < _data.length; i++) {
      if (_data[i] != null && _data[i] < 0) _data[i] = -_data[i];
    }
  }

  VT sum({bool skipNull: true});

  BoolSeries<IT> _relOp(NumericSeries<IT, num> other, bool func(num a, num b),
      {num fillVal}) {
    if (length != other.length)
      throw new Exception('Can only compare identically labeled Series!');

    final map = new SplayTreeMap<IT, List<bool>>();

    for (IT index in _mapper.keys) {
      if (!other._mapper.containsKey(index))
        throw new Exception('Can only compare identically labeled Series!');

      final List<int> sourcePos = _mapper[index];
      final List<int> destPos = other._mapper[index];

      if (sourcePos.length != destPos.length)
        throw new Exception('Can only compare identically labeled Series!');

      map[index] = <bool>[];
      for (int pos in sourcePos) {
        final num source = _data[pos];
        final num dest = other._data[pos];
        map[index].add(func(source, dest));
      }
    }

    for (IT index in other._mapper.keys) {
      if (!_mapper.containsKey(index))
        throw new Exception('Can only compare identically labeled Series!');
    }

    return new BoolSeries<IT>.fromMap(map);
  }

  BoolSeries<IT> gt(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a > b, fillVal: fillVal);

  BoolSeries<IT> lt(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a < b, fillVal: fillVal);

  BoolSeries<IT> le(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a <= b, fillVal: fillVal);

  BoolSeries<IT> ge(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a >= b, fillVal: fillVal);

  BoolSeries<IT> ne(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a != b, fillVal: fillVal);

  BoolSeries<IT> eq(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a == b, fillVal: fillVal);

  NumericSeries<IT, num> addition(a,
      {VT myFillValue,
      VT otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true});

  NumericSeries<IT, num> operator +(a);

  NumericSeries<IT, num> subtract(a,
      {VT myFillValue,
      VT otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true});

  NumericSeries<IT, num> operator -(a);

  NumericSeries<IT, num> multiply(a,
      {VT myFillValue,
      VT otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true});

  NumericSeries<IT, num> operator *(a);

  NumericSeries<IT, num> divide(a,
      {VT myFillValue,
      VT otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true});

  NumericSeries<IT, num> operator /(a);

  // TODO truncDiv

  // TODO operator ~/

  NumericSeries<IT, num> mod(a,
      {VT myFillValue,
      VT otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true});

  NumericSeries<IT, num> operator %(a);

  NumericSeries<IT, num> pow(a,
      {VT myFillValue,
      VT otherFillValue,
      dynamic name,
      bool self: false,
      bool strict: true});

  DoubleSeries<IT> log({VT fillValue, bool self: true});

  DoubleSeries<IT> logN(num n, {VT fillValue, bool self: true});

  DoubleSeries<IT> log10({VT fillValue, bool self: true});

  /* TODO
  NumericSeriesGroupBy<IT, VT> groupByValue({VT apply(VT value)}) {
    final groups = new LinkedHashMap<VT, List<int>>();

    for (int i = 0; i < length; i++) {
      final VT v = _data[i];
      if (!groups.containsKey(v)) groups[v] = <int>[];
      groups[v].add(i);
    }

    return new NumericSeriesGroupBy<IT, VT>(this, groups);
  }

  NumericSeriesGroupBy<IT, VT> groupBySeries(NumericSeries<int, VT> series) {
    final groups = new LinkedHashMap<VT, List<int>>();

    for (int i = 0; i < series.length; i++) {
      final VT v = series._data[i];
      if (!groups.containsKey(v)) groups[v] = <int>[];
      final int idx = series._labels[i];
      groups[v].add(idx);
    }

    return new NumericSeriesGroupBy<IT, VT>(this, groups);
  }

  NumericSeriesGroupBy<IT, VT> groupByMapping(Map<VT, List<int>> indexMap) {
    return new NumericSeriesGroupBy<IT, VT>(this, indexMap);
  }
  */
}
*/

/* TODO
abstract class NumericSeriesGroupBy<IT, VT extends num> {
  final NumericSeries<IT, VT> series;

  UnmodifiableMapView<VT, UnmodifiableListView<int>> _groups;

  UnmodifiableMapView<VT, UnmodifiableListView<int>> get groups => _groups;

  UnmodifiableMapView<VT, UnmodifiableListView<IT>> _labels;

  UnmodifiableMapView<VT, UnmodifiableListView<IT>> get labels => _labels;

  NumericSeriesGroupBy(this.series, Map<VT, List<int>> groupMapping) {
    final temp = new LinkedHashMap<VT, UnmodifiableListView<int>>();
    final tempIdx = new LinkedHashMap<VT, UnmodifiableListView<IT>>();

    for (VT v in groupMapping.keys) {
      temp[v] = new UnmodifiableListView<int>(groupMapping[v]);
      tempIdx[v] = new UnmodifiableListView<IT>(groupMapping[v]
          .map((int position) => series.labels[position])
          .toList());
    }

    _groups = new UnmodifiableMapView<VT, UnmodifiableListView<int>>(temp);
    _labels = new UnmodifiableMapView<VT, UnmodifiableListView<IT>>(tempIdx);
  }

  IntSeries<VT> count({dynamic name}) {
    final List<VT> idx = [];
    final List<int> data = [];

    for (VT key in _groups.keys) {
      idx.add(key);
      data.add(_groups[key].length);
    }

    return new IntSeries<VT>(data, name: name, labels: idx);
  }

  NumericSeries<IT, VT> max({dynamic name}) {
    final List<VT> idx = [];
    final List<num> data = [];

    for (VT key in _groups.keys) {
      idx.add(key);
      final List<VT> list = _groups[key]
          .map((int position) => series.getByPos(position))
          .toList();
      num mx;
      for (VT v in list) {
        if (v == null) continue;
        if (mx == null)
          mx = v;
        else if (mx < v) mx = v;
      }

      data.add(mx);
    }

    return new NumSeries<VT>(data, name: name, labels: idx);
  }

  NumSeries<VT> min({dynamic name}) {
    final List<VT> idx = [];
    final List<num> data = [];

    for (VT key in _groups.keys) {
      idx.add(key);
      final List<VT> list = _groups[key]
          .map((int position) => series.getByPos(position))
          .toList();
      num min;
      for (VT v in list) {
        if (v == null) continue;
        if (min == null)
          min = v;
        else if (min > v) min = v;
      }

      data.add(min);
    }

    return new NumSeries<VT>(data, name: name, labels: idx);
  }
}
*/
