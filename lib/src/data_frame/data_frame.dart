import 'dart:math' as math;
import 'dart:collection';

import '../series/series.dart';

class DataFrame<IT, CT> {
  final List<CT> _columns;

  final List<IT> _indices;

  final List<List> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  DataFramePositioned _pos;

  DataFramePositioned get pos => _pos;

  DataFrameIndexed _index;

  DataFrameIndexed get index => _index;

  DataFrame._(this._columns, this._indices, this._data, this._mapper) {
    _pos = new DataFramePositioned<IT, CT>(this);
    _index = new DataFrameIndexed<IT, CT>(this);
  }

  factory DataFrame(Map<CT, List> data, {List<IT> indices}) {
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

    if (indices == null) {
      if (IT.runtimeType == int) {
        throw new Exception("Indices are required for non-int indexing!");
      }
      if (len == null) throw new Exception('Cannot figure out length!');
      indices = new List<int>.generate(len, (int idx) => idx) as List<IT>;
    } else {
      if (len != null) {
        if (indices.length != len) {
          throw new Exception("Indices and data must be same length!");
        }
      } else {
        len = indices.length;
      }
    }

    final List<CT> c = [];
    final List<List> d = [];

    {
      final Map<CT, bool> colCheck = {};
      for (final CT k in data.keys) {
        if (colCheck.containsKey(k)) continue;
        c.add(k);
        colCheck[k] = true;
        final List v = data[k];
        if (v == null) {
          d.add(new List.filled(len, null));
        } else {
          d.add(v);
        }
      }
    }

    final mapper = new SplayTreeMap<IT, List<int>>();

    for (int i = 0; i < indices.length; i++) {
      final IT index = indices[i];
      if (mapper.containsKey(index)) {
        mapper[index].add(i);
      } else {
        mapper[index] = new List<int>()..add(i);
      }
    }

    return new DataFrame._(c, indices, d, mapper);
  }

  DynamicSeries<IT> operator [](CT column) {
    final int colPos = _columns.indexOf(column);
    if (colPos == -1) {
      throw new Exception("Column named $column not found!");
    }

    final List d = _data[colPos].toList();

    return new DynamicSeries<IT>(d, indices: _indices.toList());
  }

  operator []=(CT column, List value) {
    if (value.length != _indices.length)
      throw new Exception('Value does not match length!');

    final int colPos = _columns.indexOf(column);
    if (colPos == -1) {
      _columns.add(column);
      _data.add(value);
      return;
    }

    _data[colPos] = value.toList();
  }

  DynamicSeries<CT> getByIndex(IT index) {
    if (!_mapper.containsKey(index)) {
      throw new Exception("Index named $index not found!");
    }

    final int pos = _mapper[index].first;

    final List d = _data.map((List l) => l[pos]).toList();

    return new DynamicSeries<CT>(d, indices: _columns.toList(), name: index);
  }

  List<DynamicSeries<CT>> getByIndexMulti(IT index) {
    if (!_mapper.containsKey(index)) {
      throw new Exception("Index named $index not found!");
    }

    return _mapper[index].map((int pos) {
      final List d = _data.map((List l) => l[pos]).toList();
      return new DynamicSeries<CT>(d, indices: _columns.toList(), name: index);
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
    if (position >= _indices.length)
      throw new RangeError.range(position, 0, _indices.length);

    final List d = _data.map((List l) => l[position]).toList();

    return new DynamicSeries<CT>(d,
        indices: _columns.toList(), name: _indices[position]);
  }

  void setByPos(int position, List value) {
    if (position >= _indices.length)
      throw new RangeError.range(position, 0, _indices.length);
    if (value.length != _columns.length)
      throw new Exception('Value does not match number of columns!');

    for (int i = 0; i < _columns.length; i++) {
      _data[i][position] = value[i];
    }
  }

  List<int> get shape => [_indices.length, _columns.length];

  int get length => _indices.length;
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
