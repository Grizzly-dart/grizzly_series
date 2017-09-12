part of grizzly.series;

abstract class NumericSeries<IT, VT extends num> implements Series<IT, VT> {
  List<IT> get _labels;

  List<VT> get _data;

  SplayTreeMap<IT, List<int>> get _mapper;

  void abs() {
    for (int i = 0; i < _data.length; i++) {
      if (_data[i] != null && _data[i] < 0) _data[i] = -_data[i];
    }
  }

  VT max({bool skipNan: true}) {
    VT ret;
    bool seenNan = false;

    for (VT v in _data) {
      if (v == null) continue;
      if (v == double.NAN) {
        if (skipNan) {
          seenNan = true;
          continue;
        } else {
          return double.NAN as VT;
        }
      }
      if (ret == null)
        ret = v;
      else if (ret < v) ret = v;
    }

    if (ret == null && seenNan) return double.NAN as VT;

    return ret;
  }

  VT min({bool skipNan: true}) {
    VT ret;
    bool seenNan = false;

    for (VT v in _data) {
      if (v == null) continue;
      if (v == double.NAN) {
        if (skipNan) {
          seenNan = true;
          continue;
        } else {
          return double.NAN as VT;
        }
      }
      if (ret == null)
        ret = v;
      else if (ret > v) ret = v;
    }

    if (ret == null && seenNan) return double.NAN as VT;

    return ret;
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

/* TODO
  NumSeries<IT> _op(NumericSeries<IT, VT> a, VT func(VT a, VT b),
      {VT fillVal, dynamic name}) {
    final mapper = new SplayTreeMap<IT, List<num>>();

    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        List<int> sourcePos = _mapper[index];
        List<int> destPos = a._mapper[index];

        final List<num> res = [];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final num source = _data[sourcePos[i]];
            final num dest = a._data[destPos[i]];
            if (source == null)
              res.add(null);
            else if (dest == null) {
              if (fillVal == null)
                res.add(null);
              else
                res.add(func(source, fillVal));
            } else
              res.add(func(source, dest));
          }
        } else {
          for (int i = 0; i < sourcePos.length; i++) {
            final num source = _data[sourcePos[i]];
            for (int j = 0; j < destPos.length; j++) {
              final num dest = a._data[destPos[j]];
              if (source == null)
                res.add(null);
              else if (dest == null) {
                if (fillVal == null)
                  res.add(null);
                else
                  res.add(func(source, fillVal));
              } else
                res.add(func(source, dest));
            }
          }
        }
        mapper[index] = res;
      } else {
        if (fillVal == null) {
          mapper[index] = new List<int>.filled(_mapper[index].length, null);
        } else {
          mapper[index] = _mapper[index].map((int pos) {
            num data = _data[pos];
            if (data == null) return null;
            return func(data, fillVal);
          }).toList();
        }
      }
    }

    for (IT index in a._mapper.keys) {
      if (_mapper.containsKey(index)) continue;
      mapper[index] = new List<int>.filled(a._mapper[index].length, null);
    }

    return new NumSeries<IT>.fromMap(mapper, name: name);
  }

  NumSeries<IT> add(NumericSeries<IT, VT> a, {VT fillVal, dynamic name}) =>
      _op(a, (VT opa, VT opb) => opa + opb, fillVal: fillVal, name: name);

  NumSeries<IT> sub(NumericSeries<IT, VT> a, {VT fillVal, dynamic name}) =>
      _op(a, (VT opa, VT opb) => opa - opb, fillVal: fillVal, name: name);

  NumSeries<IT> mul(NumericSeries<IT, VT> a, {VT fillVal, dynamic name}) =>
      _op(a, (VT opa, VT opb) => opa * opb, fillVal: fillVal, name: name);

  NumSeries<IT> floorDiv(NumericSeries<IT, VT> a, {VT fillVal, dynamic name}) =>
      _op(a, (VT opa, VT opb) => (opa / opb).floor(), fillVal: fillVal, name: name);
      */

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
}

class NumericSeriesGroupBy<IT, VT extends num> {
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

  NumSeries<VT> max({dynamic name}) {
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
