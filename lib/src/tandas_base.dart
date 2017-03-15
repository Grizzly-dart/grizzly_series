// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';
import 'dart:math';
import 'dart:collection';

abstract class Series<IT, VT> {
  String name;

  //TODO List get indices;

  VT operator [](IT key);

  int get length;

  Series add(Series a, {fillVal});
}

class IntSeries<IT> implements Series<IT, int> {
  final Int32List _data;

  final SplayTreeMap<IT, SplayTreeSet<int>> _mapper;

  String name;

  final List<IT> _indices;

  IntSeries._(this._data, this._indices, this.name, this._mapper);

  factory IntSeries(Int32List data, {String name, List<IT> indices}) {
    if (indices == null) {
      if(IT == int) {
        throw new Exception("Indices are required for non-int indexing!");
      }
      indices = new List<int>.generate(data.length, (int idx) => idx) as List<IT>;
    } else {
      if (indices.length != data.length) {
        throw new Exception("Indices and data must be same length!");
      }
    }

    final mapper = new SplayTreeMap<IT, SplayTreeSet<int>>();

    for(int i = 0; i < indices.length; i++) {
      final IT index = indices[i];
      if(mapper.containsKey(index)) {
        mapper[index].add(i);
      } else {
        mapper[index] = new SplayTreeSet<int>()..add(i);
      }
    }

    return new IntSeries._(data, indices, name, mapper);
  }

  int operator[](IT key) {
    if(!_mapper.containsKey(IT)) {
      throw new Exception("Index named $key not found!");
    }

    return _data[_mapper[IT].first];
  }

  int get length => _data.length;

  Series add(Series a, {fillVal, String name}) {
    final int resLen = max<int>(length, a.length);

    final retData = new Int32List(resLen);
    final retIndex = new List<IT>(resLen);

    for(IT key in _mapper.keys) {
      //TODO
    }

    return new IntSeries(retData, name: name, indices: retIndex);
  }
}
