// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:math' as math;
import 'dart:collection';

abstract class Series<IT, VT> {
  String name;

  UnmodifiableListView<IT> get indices;

  UnmodifiableListView<VT> get data;

  int get length;

  /// Checks if Series contains the index
  bool containsIndex(IT index);

  /// Lookup by index
  VT operator [](IT index);

  /// Lookup by position
  VT pos(int position);

  /// Returns multiple values by index
  List<VT> indexed(IT index);

  /// Returns index at position
  IT indexAt(int position);

  operator []=(IT index, VT val);

  void append(IT index, VT value);

  SplayTreeMap<IT, List<int>> get _mapper;
}

abstract class SeriesBase<IT, VT> implements Series<IT, VT> {
  List<IT> get _indices;

  List<VT> get _data;

  SplayTreeMap<IT, List<int>> get _mapper;

  int get length => _data.length;

  bool containsIndex(IT index) => _mapper.containsKey(index);

  VT operator [](IT index) {
    if (!_mapper.containsKey(index)) {
      throw new Exception("Index named $index not found!");
    }

    return _data[_mapper[index].first];
  }

  VT pos(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return _data[position];
  }

  List<VT> indexed(IT index) {
    if (!_mapper.containsKey(index)) {
      throw new Exception("Index named $index not found!");
    }

    return _mapper[index].map((int pos) => _data[pos]).toList();
  }

  IT indexAt(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return _indices[position];
  }

  operator []=(IT index, VT value) {
    if (!_mapper.containsKey(index)) {
      _indices.add(index);
      _data.add(value);
      _mapper[index].add(_data.length - 1);
      return;
    }

    _mapper[index].forEach((int position) {
      _data[position] = value;
    });
  }

  void append(IT index, VT value) {
    _indices.add(index);
    _data.add(value);

    if (!_mapper.containsKey(index)) {
      _mapper[index] = new List<int>()..add(_data.length - 1);
    } else {
      _mapper[index].add(_data.length - 1);
    }
  }

  String toString() {
    final sb = new StringBuffer();

    //TODO print as table
    for (int i = 0; i < indices.length; i++) {
      sb.writeln('${_indices[i]} ${_data[i]}');
    }

    return sb.toString();
  }
}

class IntSeries<IT> extends Object
    with SeriesBase<IT, int>, NumericSeries<IT, int>
    implements Series<IT, int> {
  final List<IT> _indices;

  final List<int> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  String name;

  final UnmodifiableListView<IT> indices;

  final UnmodifiableListView<int> data;

  IntSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data);

  factory IntSeries(Iterable<int> data, {String name, List<IT> indices}) {
    if (indices == null) {
      if (IT.runtimeType == int) {
        throw new Exception("Indices are required for non-int indexing!");
      }
      indices =
          new List<int>.generate(data.length, (int idx) => idx) as List<IT>;
    } else {
      if (indices.length != data.length) {
        throw new Exception("Indices and data must be same length!");
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

    return new IntSeries._(data.toList(), indices, name, mapper);
  }

  factory IntSeries.fromMap(Map<IT, List<int>> map, {String name}) {
    final List<IT> indices = [];
    final List<int> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (num val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new IntSeries._(data.toList(), indices, name, mapper);
  }

  int get zero => 0;
}

class NumSeries<IT> extends Object
    with SeriesBase<IT, num>, NumericSeries<IT, num>
    implements Series<IT, num> {
  final List<IT> _indices;

  final List<int> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  String name;

  final UnmodifiableListView<IT> indices;

  final UnmodifiableListView<num> data;

  NumSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data);

  factory NumSeries(Iterable<num> data, {String name, List<IT> indices}) {
    if (indices == null) {
      if (IT.runtimeType == int) {
        throw new Exception("Indices are required for non-int indexing!");
      }
      indices =
          new List<int>.generate(data.length, (int idx) => idx) as List<IT>;
    } else {
      if (indices.length != data.length) {
        throw new Exception("Indices and data must be same length!");
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

    return new NumSeries._(data.toList(), indices, name, mapper);
  }

  factory NumSeries.fromMap(Map<IT, List<num>> map, {String name}) {
    final List<IT> indices = [];
    final List<num> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (num val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new NumSeries._(data.toList(), indices, name, mapper);
  }

  int get zero => 0;
}

abstract class NumericSeries<IT, VT extends num> implements Series<IT, VT> {
  List<IT> get _indices;

  List<VT> get _data;

  SplayTreeMap<IT, List<int>> get _mapper;

  VT get zero;

  void abs() {
    for (int i = 0; i < _data.length; i++) {
      if (data[i] != null && data[i] < 0) data[i] = -data[i];
    }
  }

  VT sum({bool skipNull: true}) {
    VT ret = zero;
    for (int i = 0; i < _data.length; i++) {
      if (data[i] != null)
        ret += data[i];
      else if (!skipNull) return null;
    }
    return ret;
  }

  NumSeries<IT> add<VVT extends num>(NumericSeries<IT, VVT> a,
      {VT fillVal, String name}) {
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
                res.add(source + fillVal);
            } else
              res.add(source + dest);
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
                  res.add(source + fillVal);
              } else
                res.add(source + dest);
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
            return data + fillVal;
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
}
