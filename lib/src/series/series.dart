library grizzly.series;

import 'dart:math' as math;
import 'dart:collection';

part 'bool.dart';
part 'double.dart';
part 'int.dart';
part 'num.dart';
part 'numeric.dart';
part 'string.dart';

abstract class Series<IT, VT> {
  dynamic name;

  UnmodifiableListView<IT> get indices;

  UnmodifiableListView<VT> get data;

  int get length;

  SeriesPositioned<IT, VT> get pos;

  /// Checks if Series contains the index
  bool containsIndex(IT index);

  /// Lookup by index
  VT operator [](IT index);

  operator []=(IT index, VT val);

  /// Lookup by position
  VT getByPos(int position);

  void setByPos(int position, VT value);

  /// Returns multiple values by index
  VT getByIndex(IT index);

  void setByIndex(IT index, VT value);

  /// Returns multiple values by index
  List<VT> getByIndexMulti(IT index);

  /// Returns index at position
  IT indexAt(int position);

  void append(IT index, VT value);

  SplayTreeMap<IT, List<int>> get _mapper;
}

class SeriesPositioned<IT, VT> {
  final Series<IT, VT> series;

  SeriesPositioned(this.series);

  VT operator [](int position) => series.getByPos(position);

  operator []=(int position, VT value) => series.setByPos(position, value);

  VT get(int position) => series.getByPos(position);

  void set(int position, VT value) => series.setByPos(position, value);
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

  VT getByPos(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return _data[position];
  }

  void setByPos(int position, VT value) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    _data[position] = value;
  }

  VT getByIndex(IT index) => this[index];

  void setByIndex(IT index, VT value) => this[index] = value;

  List<VT> getByIndexMulti(IT index) {
    if (!_mapper.containsKey(index)) {
      throw new Exception("Index named $index not found!");
    }

    return _mapper[index].map((int pos) => _data[pos]).toList();
  }

  IT indexAt(int position) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    return _indices[position];
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

  StringSeries<IT> toStringSeries() {
    return new StringSeries<IT>(_data.map((v) => v.toString()).toList(),
        name: name, indices: _indices.toList());
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

class DynamicSeries<IT> extends Object
    with SeriesBase<IT, dynamic>
    implements Series<IT, dynamic> {
  final List<IT> _indices;

  final List<dynamic> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> indices;

  final UnmodifiableListView<dynamic> data;

  SeriesPositioned<IT, dynamic> _pos;

  SeriesPositioned<IT, dynamic> get pos => _pos;

  DynamicSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, dynamic>(this);
  }

  factory DynamicSeries(Iterable<dynamic> data,
      {dynamic name, List<IT> indices}) {
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

    return new DynamicSeries._(data.toList(), indices, name, mapper);
  }

  factory DynamicSeries.fromMap(Map<IT, List<dynamic>> map, {dynamic name}) {
    final List<IT> indices = [];
    final List<dynamic> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (dynamic val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new DynamicSeries._(data.toList(), indices, name, mapper);
  }
}
