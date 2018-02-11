library grizzly.data_frame;

import 'dart:collection';

import 'package:grizzly_primitives/grizzly_primitives.dart';
import 'package:grizzly_series/grizzly_series.dart';
import 'package:grizzly_series/src/utils/utils.dart';
import 'package:grizzly_scales/grizzly_scales.dart';

class DataFrame<LT, CT> implements DataFrameBase<LT, CT> {
  final List<CT> _columns;

  final List<LT> _labels;

  final List<Series<LT, dynamic>> _data;

  final SplayTreeMap<LT, int> _mapper;

  DataFrame._(this._columns, this._labels, this._data, this._mapper);

  factory DataFrame(
      Map<CT, /* IterView<VT> | Iterable<VT> | SeriesView<LT, VT> | Map<LT, VT> */ dynamic>
          data,
      {List<LT> labels}) {
    if (data.length == 0) {
      if (labels == null || labels.length == 0) {
        return new DataFrame._([], [], [], new SplayTreeMap<LT, int>());
      } else {
        return new DataFrame._(
            [], labels.toList(), [], new SplayTreeMap<LT, int>());
      }
    }

    int expectedLen = labels?.length ?? data.values.first.length;
    // Check lengths
    for (int i = 0; i < data.length; i++) {
      int curLen = data.values.elementAt(i).length;
      if (curLen != expectedLen)
        throw lengthMismatch(
            expected: expectedLen, found: curLen, subject: 'data');
    }

    List<LT> labs = labels;
    labels ??=
        (data.values.firstWhere((v) => v is SeriesView, orElse: () => null)
                as SeriesView<LT, dynamic>)
            ?.labels
            ?.toList();
    labels ??= (data.values.firstWhere((v) => v is Map, orElse: () => null)
            as Map<LT, dynamic>)
        ?.keys
        ?.toList();
    labs = makeLabels<LT>(expectedLen, labs);
    SplayTreeMap<LT, int> mapper = labelsToMapper<LT>(labs);
    List<Series<LT, dynamic>> d = new List<Series<LT, dynamic>>()
      ..length = data.length;
    for (int i = 0; i < data.length; i++) {
      final cur = data.values.elementAt(i);
      if (cur is Map) {
        if (labs.any((LT lab) => !cur.containsKey(lab)))
          throw new Exception('Invalid data');
      } else if (cur is SeriesView) {
        if (labs.any((LT lab) => !cur.containsLabel(lab)))
          throw new Exception('Invalid data');
      }

      d[i] = series(cur, name: data.keys.elementAt(i), labels: labs);
    }
    return new DataFrame._(data.keys.toList(), labs, d, mapper);
  }

  int get numCols => _columns.length;

  int get numRows => _labels.length;

  Index2D get shape => new Index2D(numRows, numCols);

  Iterable<CT> get columns => _columns;

  Iterable<LT> get labels => _labels;

  SeriesFix<LT, dynamic> operator [](CT column) {
    final int colPos = _columns.indexOf(column);
    if (colPos == -1) throw new Exception("Column named $column not found!");
    return _data[colPos].fix;
  }

  operator []=(CT column, /* SeriesView<LT, dynamic> | IterView */ value) =>
      set(column, value);

  Series<LT, VT> get<VT>(CT column) {
    final int colPos = _columns.indexOf(column);
    if (colPos == -1) throw new Exception("Column named $column not found!");
    return _data[colPos].toView();
  }

  void set<VT>(CT column, /* SeriesView<LT, VT> | IterView<VT> */ value) {
    // TODO check if exists
    int columnPos = _columns.indexOf(column);
    if (columnPos == -1) {
      // TODO append or throw?
      return;
    }
    _data[columnPos].assign(value);
  }

  DynamicSeriesViewBase<CT> getByPos(int position) {
    if (position >= _labels.length)
      throw new RangeError.range(position, 0, _labels.length);
    // TODO return proxy series
  }

  void setByPos(int position, /* SeriesView<CT, dynamic> | IterView */ value) {
    if (position >= _labels.length)
      throw new RangeError.range(position, 0, _labels.length);

    if (value.length != _columns.length)
      throw new Exception('Value does not match number of columns!');

    for (int i = 0; i < _columns.length; i++) {
      _data[i].setByPos(position, value[i]);
    }
  }

  DynamicSeriesViewBase<CT> getByLabel(LT label) {
    if (!_mapper.containsKey(label))
      throw new Exception("Index named $label not found!");
    return getByPos(_mapper[label]);
  }

  void setByLabel(LT label, /* SeriesView<CT, dynamic> | IterView */ value) {
    if (!_mapper.containsKey(label))
      throw new Exception("Index named $label not found!");
    setByPos(_mapper[label], value);
  }

  Pair<LT, DynamicSeriesFixBase<CT>> pairByPos(int position) {
    if (position >= numRows) throw new RangeError.range(position, 0, numRows);
    return pair<LT, DynamicSeriesFixBase<CT>>(
        _labels[position], getByPos(position));
  }

  Pair<LT, DynamicSeriesViewBase<CT>> pairByLabel(LT label) =>
      pair<LT, DynamicSeriesViewBase<CT>>(label, getByLabel(label));

  Iterable<Pair<LT, DynamicSeriesViewBase<CT>>> get enumerate =>
      Ranger.indices(numRows).map(pairByPos);

  Iterable<Pair<LT, DynamicSeriesViewBase<CT>>> enumerateSliced(int start,
      [int end]) {
    if (end == null)
      end = numRows - 1;
    else {
      if (end >= numRows) {
        throw new ArgumentError.value(end, 'end', 'Out of range');
      }
    }

    if (start >= numRows) {
      throw new ArgumentError.value(start, 'start', 'Out of range');
    }

    return Ranger.range(start, end).map(pairByPos);
  }

  String toString() {
    final sb = new StringBuffer();

    //TODO format table
    for (CT col in _columns) sb.write('$col\t');
    sb.writeln();

    for (int i = 0; i < numRows; i++) {
      sb.write(_labels[i]);
      sb.write('\t');
      for (Series s in _data) {
        sb.write(s.byPos[i]);
        sb.write('\t');
      }
      sb.writeln();
    }

    return sb.toString();
  }
}

/*
  void addColumnFromList<VVT>(CT column, List<VVT> value,
      {SeriesMaker<LT, VVT> maker}) {
    if (value.length != _labels.length)
      throw new Exception('Value does not match length!');

    Series<LT, VVT> series;

    if (maker == null) {
      if (VVT != dynamic)
        throw new Exception('Need a maker for non-dynamic element type!');
      series =
          new DynamicSeries<LT>(value, name: column, labels: _labels.toList())
              as Series<LT, VVT>;
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

  DynamicSeries<CT> max({dynamic name, bool numericOnly: false}) {
    final ret = new DynamicSeries<CT>([], name: name, labels: []);

    for (int i = 0; i < _columns.length; i++) {
      ret[_columns[i]] = _data[i].max();
    }

    return ret;
  }

  DynamicSeries<CT> min({dynamic name, bool numericOnly: false}) {
    final ret = new DynamicSeries<CT>([], name: name, labels: []);

    for (int i = 0; i < _columns.length; i++) {
      ret[_columns[i]] = _data[i].min();
    }

    return ret;
  }

  // TODO test
  DataFrame<int, CT> mode() {
    final ret = new DataFrame<int, CT>({});

    for (int i = 0; i < _columns.length; i++) {
      ret[_columns[i]] = _data[i].mode();
    }

    return ret;
  }
 */
