library grizzly.data_frame;

import 'dart:collection';

import 'package:grizzly_primitives/grizzly_primitives.dart';
import 'package:grizzly_series/grizzly_series.dart';
import 'package:grizzly_series/src/utils/utils.dart';
import 'package:grizzly_scales/grizzly_scales.dart';
import 'package:collection/collection.dart';

import 'package:text_table/text_table.dart';

class DataFrame<LT> implements DataFrameBase<LT> {
  final List<String> _columns;

  final List<LT> _labels;

  final List<Series<LT, dynamic>> _data;

  final SplayTreeMap<LT, int> _mapper;

  DataFrame._(this._columns, this._labels, this._data, this._mapper);

  factory DataFrame(
          Map<
                  String,
                  /* IterView<VT> | Iterable<VT> | SeriesView<LT, VT> | Map<LT, VT> */ dynamic>
              data,
          {Iterable<LT> labels}) =>
      _makeDf(data, labels: labels?.toList());

  int get numCols => _columns.length;

  int get numRows => _labels.length;

  Index2D get shape => new Index2D(numRows, numCols);

  Iterable<String> get columns => _columns;

  Iterable<LT> get labels => _labels;

  @override
  int posOf(LT label) => _mapper[label];

  LT labelAt(int position) {
    if (position >= numRows) throw new RangeError.range(position, 0, numRows);
    return labels.elementAt(position);
  }

  @override
  bool containsLabel(LT label) => _mapper.containsKey(label);

  SeriesFix<LT, dynamic> operator [](String column) {
    final int colPos = _columns.indexOf(column);
    if (colPos == -1) throw new Exception("Column named $column not found!");
    return _data[colPos].fixed;
  }

  operator []=(
          String column,
          /* SeriesView<LT, dynamic> | IterView | Iterable<VT> */ value) =>
      set(column, value);

  SeriesFix<LT, VT> get<VT>(String column) {
    final int colPos = _columns.indexOf(column);
    if (colPos == -1) throw new Exception("Column named $column not found!");
    return _data[colPos].fixed;
  }

  void set<VT>(
      String column,
      /* SeriesView<LT, VT> | IterView<VT> | Iterable<VT> */ value) {
    int columnPos = _columns.indexOf(column);
    if (columnPos == -1) {
      if (value is IterView<VT> || value is Iterable<VT>) {
        if (value.length != numRows) {
          throw new Exception('Mismatching column lengths!');
        }
        final s = series<LT, VT>(value, labels: labels);
        _columns.add(column);
        _data.add(s);
      } else if (value is SeriesView<LT, dynamic>) {
        final Array d = value.makeValueArraySized(numRows);
        for (int i = 0; i < numRows; i++) {
          d[i] = value[labelAt(i)];
        }
        final s = value.make(d, labels: labels);
        _columns.add(column);
        _data.add(s);
      } else
        throw new UnimplementedError();
      return;
    }
    _data[columnPos].assign(value);
  }

  DynamicSeriesViewBase<String> getByPos(int position) {
    if (position >= _labels.length)
      throw new RangeError.range(position, 0, _labels.length);
    // TODO return proxy series
    final d = <dynamic>[];
    for (int i = 0; i < numCols; i++) {
      d.add(_data[i].getByPos(position));
    }
    return new DynamicSeriesView(d, labels: columns, name: position.toString());
  }

  void setByPos(
      int position,
      /* SeriesView<String, dynamic> | IterView | Map<String, dynamic> */ value) {
    if (position >= _labels.length)
      throw new RangeError.range(position, 0, _labels.length);

    if (value is IterView) {
      if (value.length != _columns.length)
        throw new Exception('Value does not match number of columns!');

      for (int i = 0; i < _columns.length; i++) {
        _data[i].setByPos(position, value[i]);
      }
    } else if (value is SeriesView<String, dynamic>) {
      for (int i = 0; i < _columns.length; i++) {
        var lab = _columns[i];
        if (value.containsLabel(lab))
          _data[i].setByPos(position, value.get(lab));
        else
          _data[i].setByPos(position, null);
      }
    } else if (value is Map<String, dynamic>) {
      for (int i = 0; i < _columns.length; i++) {
        var lab = _columns[i];
        if (value.containsKey(lab))
          _data[i].setByPos(position, value[lab]);
        else
          _data[i].setByPos(position, null);
      }
    } else {
      throw new UnsupportedError('Type not supported!');
    }
  }

  DynamicSeriesViewBase<String> getByLabel(LT label) {
    if (!_mapper.containsKey(label)) throw labelNotFound(label);
    return getByPos(_mapper[label]);
  }

  void setByLabel(
      LT label,
      /* SeriesView<String, dynamic> | IterView | Map<String, dynamic> */ value) {
    if (!_mapper.containsKey(label)) {
      // TODO append
      return;
    }
    setByPos(_mapper[label], value);
  }

  Pair<LT, DynamicSeriesFixBase<String>> pairByPos(int position) {
    if (position >= numRows) throw new RangeError.range(position, 0, numRows);
    return pair<LT, DynamicSeriesFixBase<String>>(
        _labels[position], getByPos(position));
  }

  Pair<LT, DynamicSeriesViewBase<String>> pairByLabel(LT label) =>
      pair<LT, DynamicSeriesViewBase<String>>(label, getByLabel(label));

  Iterable<Pair<LT, DynamicSeriesViewBase<String>>> get enumerate =>
      Ranger.indices(numRows).map(pairByPos);

  Iterable<Pair<LT, DynamicSeriesViewBase<String>>> enumerateSliced(int start,
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
    final Table tab = table(columns.toList()..insert(0, ''));
    for (int i = 0; i < numRows; i++) {
      tab.row(getByPos(i).data.toList()..insert(0, labels.elementAt(i)));
    }
    return tab.toString();
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

  void _updatePosOnRemove(int posLimit) {
    for (LT label in _mapper.keys) {
      int pos = _mapper[label];
      if (pos > posLimit) _mapper[label]--;
    }
  }

  /// Remove element at position [pos]
  void removeByPos(int pos) {
    if (pos >= numRows) throw new RangeError.range(pos, 0, numRows);

    final LT label = _labels[pos];
    _mapper.remove(label);
    _labels.removeAt(pos);
    _updatePosOnRemove(pos);

    for (Series s in _data) {
      s.remove(pos);
    }
  }

  void removeManyByPos(List<int> positions) {
    if (positions.length == 0) {
      return;
    }

    final positionSet = new Set<int>.from(positions).toList();
    positionSet.sort((int a, int b) => b.compareTo(a));
    if (positionSet.first >= numRows)
      throw new RangeError.range(positionSet.first, 0, numRows);

    for (int pos in positionSet) {
      final LT label = _labels[pos];
      _mapper.remove(label);
      _labels.removeAt(pos);
      _updatePosOnRemove(pos);
    }

    for (Series s in _data) {
      s.removeMany(positionSet.toList());
    }
    return;
  }

  void drop(LT label) {
    if (!_mapper.containsKey(label)) {
      return;
    }

    final int pos = _mapper[label];
    _labels.removeAt(pos);
    _mapper.remove(label);
    _updatePosOnRemove(pos);

    for (Series s in _data) {
      s.remove(pos);
    }
  }

  void dropMany(/* Iterable<LT> | IterView<LT> | Labeled */ labels) {
    if (labels is IterView<LT>) {
      labels = (labels as IterView<LT>).asIterable;
    } else if (labels is Labeled<LT>) {
      labels = (labels as Labeled<LT>).labels;
    }
    for (LT label in labels) {
      if (!_mapper.containsKey(label)) {
        continue;
      }

      final int pos = _mapper[label];
      _labels.removeAt(pos);
      _mapper.remove(label);
      _updatePosOnRemove(pos);

      for (Series s in _data) {
        s.remove(pos);
      }
    }
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
    } else if (mask is DfCond<LT>) {
      keepWhen(mask);
      return;
    }
    throw new UnimplementedError();
  }

  void keepOnly(Labeled<LT> mask) {
    if (numRows != mask.labels.length)
      throw lengthMismatch(
          expected: numRows, found: mask.labels.length, subject: 'mask');

    final pos = <int>[];
    for (LT lab in labels) {
      if (!mask.containsLabel(lab)) pos.add(posOf(lab));
    }
    removeManyByPos(pos);
  }

  void keepLabels(/* Iterable<LT> | IterView<LT> */ mask) {
    if (mask is IterView<LT>) {
      mask = mask.asIterable;
    }
    if (mask is Iterable<LT>) {
      if (numRows != mask.length)
        throw lengthMismatch(
            expected: numRows, found: mask.length, subject: 'mask');

      keepOnly(new BoolSeriesView.constant(true, labels: mask));
      return;
    }
    throw new UnimplementedError();
  }

  void keepIf(BoolSeriesViewBase<LT> mask) {
    if (numRows != mask.length)
      throw lengthMismatch(
          expected: numRows, found: mask.length, subject: 'mask');

    final pos = <int>[];
    for (LT lab in labels) {
      if (!mask.containsLabel(lab) || !mask[lab]) pos.add(posOf(lab));
    }
    removeManyByPos(pos);
  }

  void keepWhen(DfCond<LT> cond) {
    final pos = <int>[];
    for (LT lab in labels) {
      if (!cond(lab, this)) pos.add(posOf(lab));
    }
    removeManyByPos(pos);
  }

  DataFrame<LT> select(mask) {
    if (mask is BoolSeriesViewBase<LT>) {
      return selectIf(mask);
    } else if (mask is Labeled<LT>) {
      return selectOnly(mask);
    } else if (mask is Iterable<LT> || mask is IterView<LT>) {
      return selectLabels(mask);
    } else if (mask is DfCond<LT>) {
      return selectWhen(mask);
    }
    throw new UnimplementedError();
  }

  DataFrame<LT> selectOnly(Labeled<LT> mask) {
    if (numRows != mask.labels.length)
      throw lengthMismatch(
          expected: numRows, found: mask.labels.length, subject: 'mask');

    final ret = new DataFrame<LT>({});
    for (LT lab in labels) {
      if (mask.containsLabel(lab)) ret.setByLabel(lab, getByLabel(lab));
    }
    return ret;
  }

  DataFrame<LT> selectLabels(/* Iterable<LT> | IterView<LT> */ mask) {
    if (mask is IterView<LT>) {
      mask = mask.asIterable;
    }
    if (mask is Iterable<LT>) {
      if (numRows != mask.length)
        throw lengthMismatch(
            expected: numRows, found: mask.length, subject: 'mask');

      return selectOnly(new BoolSeriesView.constant(true, labels: mask));
    }
    throw new UnimplementedError();
  }

  DataFrame<LT> selectIf(BoolSeriesViewBase<LT> mask) {
    if (numRows != mask.length)
      throw lengthMismatch(
          expected: numRows, found: mask.length, subject: 'mask');

    final ret = new DataFrame<LT>({});
    for (LT lab in labels) {
      if (mask.containsLabel(lab) && mask[lab])
        ret.setByLabel(lab, getByLabel(lab));
    }
    return ret;
  }

  DataFrame<LT> selectWhen(DfCond<LT> cond) {
    final ret = new DataFrame<LT>({});
    for (LT lab in labels) {
      if (cond(lab, this)) ret.setByLabel(lab, getByLabel(lab));
    }
    return ret;
  }
}

/*
  void addColumnFromList<VVT>(String column, List<VVT> value,
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

  DynamicSeries<String> max({dynamic name, bool numericOnly: false}) {
    final ret = new DynamicSeries<String>([], name: name, labels: []);

    for (int i = 0; i < _columns.length; i++) {
      ret[_columns[i]] = _data[i].max();
    }

    return ret;
  }

  DynamicSeries<String> min({dynamic name, bool numericOnly: false}) {
    final ret = new DynamicSeries<String>([], name: name, labels: []);

    for (int i = 0; i < _columns.length; i++) {
      ret[_columns[i]] = _data[i].min();
    }

    return ret;
  }

  // TODO test
  DataFrame<int, String> mode() {
    final ret = new DataFrame<int, String>({});

    for (int i = 0; i < _columns.length; i++) {
      ret[_columns[i]] = _data[i].mode();
    }

    return ret;
  }
 */

DataFrame _makeDf<LT>(
    Map<
            String,
            /* IterView<VT> | Iterable<VT> | SeriesView<LT, VT> | Map<LT, VT> */ dynamic>
        data,
    {List<LT> labels}) {
  if (data.length == 0) {
    if (labels == null || labels.length == 0) {
      return new DataFrame._(<String>[], <LT>[], <Series<LT, dynamic>>[],
          new SplayTreeMap<LT, int>());
    } else {
      return new DataFrame._(<String>[], labels.toList(),
          <Series<LT, dynamic>>[], new SplayTreeMap<LT, int>());
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
  labels ??= (data.values.firstWhere((v) => v is SeriesView, orElse: () => null)
          as SeriesView)
      ?.labels
      ?.retype<LT>()
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

    final s =
        series<LT, dynamic>(cur, name: data.keys.elementAt(i), labels: labs);
    d[i] = s;
  }
  return new DataFrame<LT>._(data.keys.toList(), labs, d, mapper);
}

const UnorderedIterableEquality _iterEquality =
    const UnorderedIterableEquality();
