library grizzly.data_frame;

import 'dart:collection';

import 'package:grizzly_array/grizzly_array.dart';
import 'package:grizzly_primitives/grizzly_primitives.dart';
import 'package:grizzly_series/grizzly_series.dart';
import 'package:grizzly_series/src/utils/utils.dart';
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

  LT labelAt(int position) {
    if (position >= numRows) throw new RangeError.range(position, 0, numRows);
    return labels.elementAt(position);
  }

  @override
  int posOf(LT label) => _mapper[label];

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
      /* SeriesView<LT, VT> | Iterable<VT> */ value) {
    int columnPos = _columns.indexOf(column);
    if (columnPos == -1) {
      if (value is Iterable<VT>) {
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
      /* SeriesView<String, dynamic> | Iterable<dynamic> | Map<String, dynamic> */ value) {
    if (position >= _labels.length)
      throw new RangeError.range(position, 0, _labels.length);

    if (value is Iterable) {
      if (value.length != _columns.length)
        throw new Exception('Value does not match number of columns!');

      for (int i = 0; i < _columns.length; i++) {
        _data[i].setByPos(position, value.elementAt(i));
      }
    } else if (value is SeriesView<String, dynamic>) {
      for (int i = 0; i < _columns.length; i++) {
        String lab = _columns[i];
        if (value.containsLabel(lab))
          _data[i].setByPos(position, value.get(lab));
        else
          _data[i].setByPos(position, null);
      }
    } else if (value is Map<String, dynamic>) {
      for (int i = 0; i < _columns.length; i++) {
        String lab = _columns[i];
        if (value.containsKey(lab))
          _data[i].setByPos(position, value[lab]);
        else
          _data[i].setByPos(position, null);
      }
    } else if (value is DfCellSetter<LT, dynamic>) {
      LT label = labelAt(position);
      for (int i = 0; i < _columns.length; i++) {
        String colname = _columns[i];
        _data[i].setByPos(position, value(colname, label));
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
      append(label, value);
      return;
    }
    setByPos(_mapper[label], value);
  }

  void append(
      LT label,
      /* SeriesView<String, dynamic> | Iterable<dynamic> | Map<String, dynamic> | DfCellSetter */ value) {
    if (_mapper.containsKey(label))
      throw new Exception('Label already exists!');

    if (_columns.length != 0) {
      if (value is Iterable) {
        if (value.length != _columns.length)
          throw new Exception('Value does not match number of columns!');

        for (int i = 0; i < _columns.length; i++) {
          _data[i].append(label, value.elementAt(i));
        }
      } else if (value is SeriesView<String, dynamic>) {
        for (int i = 0; i < _columns.length; i++) {
          String colname = _columns[i];
          if (value.containsLabel(colname))
            _data[i].append(label, value[colname]);
          else
            _data[i].append(label, null);
        }
      } else if (value is Map<String, dynamic>) {
        for (int i = 0; i < _columns.length; i++) {
          String colname = _columns[i];
          if (value.containsKey(colname))
            _data[i].append(label, value[colname]);
          else
            _data[i].append(label, null);
        }
      } else if (value is DfCellSetter<LT, dynamic>) {
        for (int i = 0; i < _columns.length; i++) {
          String colname = _columns[i];
          _data[i].append(label, value(colname, label));
        }
      } else {
        throw new UnsupportedError('Type not supported!');
      }
      _labels.add(label);
      _mapper[label] = _labels.length - 1;
    } else {
      if (value is SeriesView<String, dynamic>) {
        _columns.addAll(value.labels);
        for (int i = 0; i < _columns.length; i++) {
          String colname = _columns[i];
          _data.add(new DynamicSeries<LT>([value[colname]],
              name: colname, labels: <LT>[label]));
        }
      } else if (value is Map<String, dynamic>) {
        _columns.addAll(value.keys);
        for (int i = 0; i < _columns.length; i++) {
          String colname = _columns[i];
          _data.add(new DynamicSeries<LT>([value[colname]],
              name: colname, labels: <LT>[label]));
        }
      } else {
        throw new UnsupportedError('Type not supported!');
      }
      _labels.add(label);
      _mapper[label] = _labels.length - 1;
    }
  }

  void insert(
      int pos,
      LT label,
      /* SeriesView<String, dynamic> | Iterable | Map<String, dynamic> | DfCellSetter */ value) {
    if (pos > numRows) throw new RangeError.range(pos, 0, numRows);
    if (containsLabel(label)) drop(label);

    _updatePosOnInsert(pos);
    _mapper[label] = pos;
    _labels.insert(pos, label);

    if (value is Iterable) {
      if (value.length != _columns.length)
        throw new Exception('Value does not match number of columns!');

      for (int i = 0; i < _columns.length; i++) {
        _data[i].insert(pos, label, value.elementAt(i));
      }
    } else if (value is SeriesView<String, dynamic>) {
      for (int i = 0; i < _columns.length; i++) {
        String colname = _columns[i];
        if (value.containsLabel(colname))
          _data[i].insert(pos, label, value[colname]);
        else
          _data[i].insert(pos, label, null);
      }
    } else if (value is Map<String, dynamic>) {
      for (int i = 0; i < _columns.length; i++) {
        String colname = _columns[i];
        if (value.containsKey(colname))
          _data[i].insert(pos, label, value[colname]);
        else
          _data[i].insert(pos, label, null);
      }
    } else if (value is DfCellSetter<LT, dynamic>) {
      for (int i = 0; i < _columns.length; i++) {
        String colname = _columns[i];
        _data[i]..insert(pos, label, value(colname, label));
      }
    } else {
      throw new UnsupportedError('Type not supported!');
    }
  }

  void appendColumn(
      String name,
      /* SeriesView<LT, dynamic> | Iterable | Map<VT, dynamic> | int | double | String */ value) {
    if (_columns.contains(name)) removeColumn(name);

    if (value is SeriesView<LT, dynamic>) {
      final d = new List()..length = numRows;
      for (int i = 0; i < numRows; i++) {
        LT lab = labelAt(i);
        if (value.containsLabel(lab)) {
          d[i] = value.get(lab);
        }
      }
      _data.add(value.make<LT>(d, name: name, labels: labels));
      _columns.add(name);
      return;
    } else if (value is Iterable) {
      if (value.length != numRows)
        throw lengthMismatch(
            expected: numRows, found: value.length, subject: 'value');
      _data.add(new DynamicSeries<LT>(value, name: name, labels: labels));
      _columns.add(name);
      return;
    } else if (value is Map<LT, dynamic>) {
      final d = new List()..length = numRows;
      for (int i = 0; i < numRows; i++) {
        LT lab = labelAt(i);
        if (value.containsKey(lab)) {
          d[i] = value[lab];
        }
      }
      _data.add(new DynamicSeries<LT>(d, name: name, labels: labels));
      _columns.add(name);
      return;
    } else if (value is int) {
      final d = new List<int>(numRows);
      for (int i = 0; i < numRows; i++) d[i] = value;
      _data.add(new IntSeries<LT>(d, name: name, labels: labels));
      _columns.add(name);
      return;
    } else if (value is double) {
      final d = new List<double>(numRows);
      for (int i = 0; i < numRows; i++) d[i] = value;
      _data.add(new DoubleSeries<LT>(d, name: name, labels: labels));
      _columns.add(name);
      return;
    } else if (value is String) {
      final d = new List<String>(numRows);
      for (int i = 0; i < numRows; i++) d[i] = value;
      _data.add(new StringSeries<LT>(d, name: name, labels: labels));
      _columns.add(name);
      return;
    }
    throw new UnsupportedError('');
  }

  void insertColumn(
      int pos,
      String name,
      /* SeriesView<LT, dynamic> | Iterable | Map<VT, dynamic> | int | double | String */ value) {
    if (containsColumn(name)) removeColumn(name);

    if (pos > numCols) throw new Exception('Invalid position!');

    if (value is SeriesView<LT, dynamic>) {
      final d = new List()..length = numRows;
      for (int i = 0; i < numRows; i++) {
        LT lab = labelAt(i);
        if (value.containsLabel(lab)) {
          d[i] = value.get(lab);
        }
      }
      _data.insert(pos, value.make(d, name: name, labels: labels));
      _columns.insert(pos, name);
      return;
    } else if (value is Iterable) {
      if (value.length != numRows)
        throw lengthMismatch(
            expected: numRows, found: value.length, subject: 'value');
      _data.insert(
          pos, new DynamicSeries<LT>(value, name: name, labels: labels));
      _columns.insert(pos, name);
      return;
    } else if (value is Map<LT, dynamic>) {
      final d = new List()..length = numRows;
      for (int i = 0; i < numRows; i++) {
        LT lab = labelAt(i);
        if (value.containsKey(lab)) {
          d[i] = value[lab];
        }
      }
      _data.insert(pos, new DynamicSeries<LT>(d, name: name, labels: labels));
      _columns.insert(pos, name);
      return;
    } else if (value is int) {
      final d = new List<int>(numRows);
      for (int i = 0; i < numRows; i++) d[i] = value;
      _data.insert(pos, new IntSeries<LT>(d, name: name, labels: labels));
      _columns.insert(pos, name);
      return;
    } else if (value is double) {
      final d = new List<double>(numRows);
      for (int i = 0; i < numRows; i++) d[i] = value;
      _data.insert(pos, new DoubleSeries<LT>(d, name: name, labels: labels));
      _columns.insert(pos, name);
      return;
    } else if (value is String) {
      final d = new List<String>(numRows);
      for (int i = 0; i < numRows; i++) d[i] = value;
      _data.insert(pos, new StringSeries<LT>(d, name: name, labels: labels));
      _columns.insert(pos, name);
      return;
    }
    throw new UnsupportedError('');
  }

  void setColumn(String name, value) {
    if (!containsColumn(name)) {
      appendColumn(name, value);
      return;
    }

    int index = _columns.indexOf(name);
    if (value is SeriesView<LT, dynamic>) {
      _data[index].assign(value, addNew: false);
      return;
    } else if (value is Iterable) {
      _data[index].assign(value, addNew: false);
      return;
    } else if (value is Map<LT, dynamic>) {
      _data[index].assignMap(value, addNew: false);
      return;
    } else if (value is int || value is double || value is String) {
      _data[index].assign(value, addNew: false);
      _columns.add(name);
      return;
    }
    throw new UnsupportedError('');
  }

  void removeColumn(String name) {
    int index = _columns.indexOf(name);
    if (index < 0) return;
    _columns.removeAt(index);
    _data.removeAt(index);
  }

  bool containsColumn(String column) => _columns.contains(column);

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

    return Ranger.between(start, end).map(pairByPos);
  }

  String toString() {
    final Table tab = table(columns.toList()..insert(0, ''));
    for (int i = 0; i < numRows; i++) {
      tab.row(getByPos(i).data.toList()..insert(0, labels.elementAt(i)));
    }
    return tab.toString();
  }

  bool labelsMatch(final /* Labeled<LT> | Iterable<LT> */ labels) {
    if (labels is Labeled<LT>) {
      return _iterEquality.equals(this.labels, labels.labels);
    } else if (labels is Iterable<LT>) {
      return _iterEquality.equals(this.labels, labels);
    }
    throw new UnsupportedError('Type not supported!');
  }

  void _updatePosOnInsert(int posLimit) {
    for (LT label in _mapper.keys) {
      int pos = _mapper[label];
      if (pos > posLimit) _mapper[label]++;
    }
  }

  void _updatePosOnRemove(int posLimit) {
    for (LT label in _mapper.keys) {
      int pos = _mapper[label];
      if (pos >= posLimit) _mapper[label]--;
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

  void dropMany(/* Iterable<LT> | Labeled */ labels) {
    if (labels is Labeled<LT>) labels = (labels as Labeled<LT>).labels;
    for (LT label in labels) {
      if (!_mapper.containsKey(label)) continue;

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
    } else if (mask is Iterable<LT>) {
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

  void keepLabels(Iterable<LT> mask) {
    if (numRows != mask.length)
      throw lengthMismatch(
          expected: numRows, found: mask.length, subject: 'mask');

    keepOnly(new BoolSeriesView.constant(true, labels: mask));
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
    } else if (mask is Iterable<LT>) {
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

  DataFrame<LT> selectLabels(Iterable<LT> mask) {
    if (numRows != mask.length)
      throw lengthMismatch(
          expected: numRows, found: mask.length, subject: 'mask');

    return selectOnly(new BoolSeriesView.constant(true, labels: mask));
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

  void setIf(
      BoolSeriesViewBase<LT> mask,
      /* SeriesView<String, dynamic> | IterView | Map<String, dynamic> | DfCellSetter */ value) {
    for (LT lab in labels) {
      if (mask.containsLabel(lab) && mask[lab]) setByLabel(lab, value);
    }
  }

  void setWhen(
      DfCond<LT> cond,
      /* SeriesView<String, dynamic> | IterView | Map<String, dynamic> | DfCellSetter */ value) {
    for (LT lab in labels) {
      if (cond(lab, this)) setByLabel(lab, value);
    }
  }

  DataFrame<LT> filter(mask) {
    if (mask is BoolSeriesViewBase<String>) {
      return filterIf(mask);
    } else if (mask is Labeled<String>) {
      return filterOnly(mask);
    } else if (mask is Iterable<String>) {
      return filterNamed(mask);
    } else if (mask is DfCond) {
      return filterWhen(mask);
    }
    throw new UnimplementedError();
  }

  DataFrame<LT> filterOnly(Labeled<String> mask) {
    if (numCols != mask.labels.length)
      throw lengthMismatch(
          expected: numCols, found: mask.labels.length, subject: 'mask');

    final ret = new DataFrame<LT>({});
    for (String col in _columns) {
      if (mask.containsLabel(col)) ret[col] = this[col];
    }
    return ret;
  }

  DataFrame<LT> filterNamed(Iterable<String> mask) {
    if (numCols != mask.length)
      throw lengthMismatch(
          expected: numCols, found: mask.length, subject: 'mask');

    return filterOnly(new BoolSeriesView.constant(true, labels: mask));
  }

  DataFrame<LT> filterIf(BoolSeriesViewBase<String> mask) {
    if (numRows != mask.length)
      throw lengthMismatch(
          expected: numRows, found: mask.length, subject: 'mask');

    final ret = new DataFrame<LT>({});
    for (String col in _columns) {
      if (mask.containsLabel(col) && mask[col]) ret[col] = this[col];
    }
    return ret;
  }

  DataFrame<LT> filterWhen(DfCond cond) {
    final ret = new DataFrame<LT>({});
    for (String col in _columns) {
      if (cond(col, this)) ret[col] = this[col];
    }
    return ret;
  }

  Double2D toDouble2D(
      {bool skipInvalid: true,
      bool convert: true,
      bool retype: false,
      bool parse: false}) {
    final ret = new List<Iterable<double>>();
    for (Series<LT, dynamic> s in _data) {
      if (s is Series<LT, double>) {
        ret.add(s.data);
        continue;
      }

      if (s is NumericSeries<LT, int>) {
        if (convert) {
          ret.add(s.toDouble.data);
          continue;
        }
      }

      if (s is StringSeriesBase<LT>) {
        if (parse) {
          ret.add(s.toDouble().data);
          continue;
        }
      }

      if (!skipInvalid) {
        throw new Exception();
      }
    }
    return new Double2D(ret);
  }

  Int2D toInt2D(
      {bool skipInvalid: true,
      bool convert: true,
      bool retype: false,
      bool parse: false}) {
    final ret = new List<Iterable<int>>();
    for (Series<LT, dynamic> s in _data) {
      if (s is Series<LT, int>) {
        ret.add(s.data);
        continue;
      }

      if (s is NumericSeries<LT, double>) {
        if (convert) {
          ret.add(s.toInt.data);
          continue;
        }
      }

      if (s is StringSeriesBase<LT>) {
        if (parse) {
          ret.add(s.toInt().data);
          continue;
        }
      }

      if (!skipInvalid) {
        throw new Exception();
      }
    }
    return new Int2D(ret);
  }

  Double2DView asDouble2D({bool skipInvalid: true, bool retype: false}) {
    final d = new List<Double1D>();
    for (Series<LT, dynamic> s in _data) {
      if (s is Series<LT, double>) {
        d.add(s.data);
        continue;
      }

      if (!skipInvalid) {
        throw new Exception();
      }
    }
    return new Double2D.own(d);
  }

  Int2DView asInt2D({bool skipInvalid: true, bool retype: false}) {
    final d = new List<Int1D>();
    for (Series<LT, dynamic> s in _data) {
      if (s is Series<LT, int>) {
        d.add(s.data);
        continue;
      }

      if (!skipInvalid) {
        throw new Exception();
      }
    }
    return new Int2D.own(d);
  }
}

/*
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
      ?.cast<LT>()
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
