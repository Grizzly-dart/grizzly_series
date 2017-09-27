library grizzly.data_frame;

import 'dart:collection';

import 'package:grizzly_series/src/series/series.dart';
import 'package:grizzly_series/src/utils/utils.dart';

class DataFrame<IT, CT> {
  final List<CT> _columns;

  final List<IT> _labels;

  final List<Series> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  DataFramePositioned _pos;

  DataFramePositioned get pos => _pos;

  DataFrameIndexed _index;

  DataFrameIndexed get index => _index;

  final UnmodifiableListView<CT> columns;

  final UnmodifiableListView<IT> labels;

  DataFrame._(this._columns, this._labels, this._data, this._mapper)
      : labels = new UnmodifiableListView(_labels),
        columns = new UnmodifiableListView(_columns) {
    _pos = new DataFramePositioned<IT, CT>(this);
    _index = new DataFrameIndexed<IT, CT>(this);
  }

  factory DataFrame(Map<CT, List> data, {List<IT> labels}) {
    int len;

    if (data.length > 0) {
      for (List v in data.values) {
        if (v == null) continue;

        final int l = v.length;
        if (len == null)
          len = l;
        else {
          if (len != l)
            throw new Exception('All columns must have same length!');
        }
      }
    }

    if (labels == null) {
      if (IT == int) {
        throw new Exception("Indices are required for non-int indexing!");
      }
      if (len == null) {
        if (data.length != 0) {
          throw new Exception('Cannot figure out length!');
        } else {
          len = 0;
          labels = <IT>[];
        }
      } else {
        labels = new List<int>.generate(len, (int idx) => idx) as List<IT>;
      }
    } else {
      if (len != null) {
        if (labels.length != len) {
          throw new Exception("Indices and data must be same length!");
        }
      } else {
        len = labels.length;
      }
    }

    final List<CT> c = [];
    final List<DynamicSeries<IT>> d = [];

    {
      final Map<CT, bool> colCheck = {};
      for (final CT k in data.keys) {
        if (colCheck.containsKey(k)) continue;
        c.add(k);
        colCheck[k] = true;
        final List v = data[k];
        if (v == null) {
          d.add(new DynamicSeries(new List.filled(len, null),
              name: k, labels: labels));
        } else {
          d.add(new DynamicSeries(v, name: k, labels: labels));
        }
      }
    }

    final mapper = new SplayTreeMap<IT, List<int>>();

    for (int i = 0; i < labels.length; i++) {
      final IT index = labels[i];
      if (mapper.containsKey(index)) {
        mapper[index].add(i);
      } else {
        mapper[index] = new List<int>()..add(i);
      }
    }

    return new DataFrame._(c, labels, d, mapper);
  }

  factory DataFrame.series(Map<CT, Series<IT, dynamic>> seriesMap,
      {Map<CT, List> lists: const {},
      List<Series<IT, dynamic>> series: const []}) {
    final List<Series<IT, dynamic>> seriesAll = seriesMap.values.toList()
      ..addAll(series);

    {
      final int len = seriesAll.first.length;

      bool sameIdx = seriesAll.every((Series s) => s.length == len);

      if (sameIdx) {
        for (int i = 0; i < seriesAll.first.length; i++) {
          final IT idx = seriesAll.first.labels[i];
          sameIdx =
              sameIdx && seriesAll.every((Series s) => s.labels[i] == idx);
          if (!sameIdx) break;
        }

        if (sameIdx) {
          final bool listMatchLen =
              lists.values.every((List l) => l.length == len);

          if (!listMatchLen)
            throw new Exception('Some of the lists dont match labels length!');

          final List<IT> labels = seriesAll.first.labels.toList();

          seriesAll.addAll(lists.keys.map((CT key) =>
              new DynamicSeries<IT>(lists[key], name: key, labels: labels)));

          final List<CT> columns = seriesMap.keys.toList()
            ..addAll(series.map((Series s) => s.name).toList() as List<CT>)
            ..addAll(lists.keys.toList());
          final SplayTreeMap<IT, List<int>> mapper = labelsToPosMapper(labels);
          return new DataFrame._(columns, labels, seriesAll, mapper);
        }
      }
    }

    if (lists.length != 0)
      throw new Exception(
          'lists can be specified only when all series have identical labels!');

    final labelsSet = new SplayTreeSet<IT>();
    seriesAll.forEach((Series<IT, dynamic> s) => labelsSet.addAll(s.labels));
    final List<IT> labelsSorted = labelsSet.toList()..sort();

    final List<Series<IT, dynamic>> d =
        seriesAll.map((Series<IT, dynamic> s) => s.makeNew([])).toList();

    final labels = <IT>[];

    for (IT idx in labelsSorted) {
      for (int i = 0; i < seriesAll.length; i++) {
        //TODO
      }
    }

    final List<CT> columns = seriesMap.keys.toList()
      ..addAll(series.map((Series s) => s.name) as Iterable<CT>);

    final SplayTreeMap<IT, List<int>> mapper = labelsToPosMapper<IT>(labels);

    return new DataFrame._(columns, labels, d, mapper);
  }

  SeriesView<IT, dynamic> operator [](CT column) {
    final int colPos = _columns.indexOf(column);
    if (colPos == -1) {
      throw new Exception("Column named $column not found!");
    }

    return _data[colPos].toView();
  }

  operator []=(CT column, Series<IT, dynamic> value) {
    final int colPos = _columns.indexOf(column);
    if (colPos == -1) {
      final temp = value.makeNew(new List.filled(length, null),
          name: column, labels: _labels.toList());
      temp.assign(value);
      _columns.add(column);
      _data.add(temp);
      return;
    }

    _data[colPos].assign(value);
  }

  void addColumnFromList<VVT>(CT column, List<VVT> value,
      {SeriesMaker<IT, VVT> maker}) {
    if (value.length != _labels.length)
      throw new Exception('Value does not match length!');

    Series<IT, VVT> series;

    if (maker == null) {
      if (VVT != dynamic)
        throw new Exception('Need a maker for non-dynamic element type!');
      series =
          new DynamicSeries<IT>(value, name: column, labels: _labels.toList())
              as Series<IT, VVT>;
    } else {
      series = maker(value, name: column, labels: _labels.toList());
    }

    final int colPos = _columns.indexOf(column);
    if (colPos == -1) {
      _columns.add(column);
      _data.add(series);
      return;
    }

    _data[colPos] = series;
  }

  DynamicSeries<CT> getByIndex(IT index) {
    if (!_mapper.containsKey(index)) {
      throw new Exception("Index named $index not found!");
    }

    final int pos = _mapper[index].first;

    final List d = _data.map((Series l) => l.pos[pos]).toList();

    return new DynamicSeries<CT>(d, labels: _columns.toList(), name: index);
  }

  List<DynamicSeries<CT>> getByIndexMulti(IT index) {
    if (!_mapper.containsKey(index)) {
      throw new Exception("Index named $index not found!");
    }

    return _mapper[index].map((int pos) {
      final List d = _data.map((Series l) => l.pos[pos]).toList();
      return new DynamicSeries<CT>(d, labels: _columns.toList(), name: index);
    }).toList();
  }

  void setByIndex(IT index, List value) {
    if (!_mapper.containsKey(index)) {
      throw new Exception("Index named $index not found!");
    }

    for (final int position in _mapper[index]) {
      if (value.length != _columns.length)
        throw new Exception('Value does not match number of columns!');

      for (int i = 0; i < _columns.length; i++) {
        _data[i][position] = value[i];
      }
    }
  }

  DynamicSeries<CT> getByPos(int position) {
    if (position >= _labels.length)
      throw new RangeError.range(position, 0, _labels.length);

    final List d = _data.map((Series l) => l.pos[position]).toList();

    return new DynamicSeries<CT>(d,
        labels: _columns.toList(), name: _labels[position]);
  }

  void setByPos(int position, List value) {
    if (position >= _labels.length)
      throw new RangeError.range(position, 0, _labels.length);
    if (value.length != _columns.length)
      throw new Exception('Value does not match number of columns!');

    for (int i = 0; i < _columns.length; i++) {
      _data[i][position] = value[i];
    }
  }

  NumSeries<CT> max({dynamic name, bool numericOnly: false}) {
    final ret = new NumSeries<CT>([], name: name, labels: []);

    for (int i = 0; i < _columns.length; i++) {
      if (numericOnly && _data[i] is! NumericSeries) continue;
      ret[_columns[i]] = _data[i].max();
    }

    return ret;
  }

  NumSeries<CT> min({dynamic name, bool numericOnly: false}) {
    final ret = new NumSeries<CT>([], name: name, labels: []);

    for (int i = 0; i < _columns.length; i++) {
      if (numericOnly && _data[i] is! NumericSeries) continue;
      ret[_columns[i]] = _data[i].min();
    }

    return ret;
  }

  DataFrame<int, CT> mode() {
    final ret = new DataFrame<int, CT>({});

    for (int i = 0; i < _columns.length; i++) {
      ret[_columns[i]] = _data[i].mode();
    }

    return ret;
  }

  List<int> get shape => [_labels.length, _columns.length];

  int get length => _labels.length;

  String toString() {
    final sb = new StringBuffer();

    //TODO format table
    for (CT col in _columns) sb.write('$col\t');
    sb.writeln();

    for (int i = 0; i < length; i++) {
      sb.write(_labels[i]);
      sb.write('\t');
      for (Series s in _data) {
        sb.write(s.pos[i]);
        sb.write('\t');
      }
      sb.writeln();
    }

    return sb.toString();
  }
}

class DataFramePositioned<IT, CT> {
  final DataFrame<IT, CT> frame;

  DataFramePositioned(this.frame);

  DynamicSeries<CT> operator [](int position) => frame.getByPos(position);

  operator []=(int position, List value) => frame.setByPos(position, value);

  DynamicSeries<CT> get(int position) => frame.getByPos(position);

  void set(int position, List value) => frame.setByPos(position, value);
}

class DataFrameIndexed<IT, CT> {
  final DataFrame<IT, CT> frame;

  DataFrameIndexed(this.frame);

  DynamicSeries<CT> operator [](IT index) => frame.getByIndex(index);

  operator []=(IT index, List value) => frame.setByIndex(index, value);

  DynamicSeries<CT> get(IT index) => frame.getByIndex(index);

  void set(IT index, List value) => frame.setByIndex(index, value);

  List<DynamicSeries<CT>> getMulti(IT index) => frame.getByIndexMulti(index);
}
