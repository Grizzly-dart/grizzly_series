import 'dart:math' as math;
import 'dart:collection';

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

class IntSeries<IT> extends Object
    with SeriesBase<IT, int>, NumericSeries<IT, int>
    implements Series<IT, int> {
  final List<IT> _indices;

  final List<int> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> indices;

  final UnmodifiableListView<int> data;

  SeriesPositioned<IT, int> _pos;

  SeriesPositioned<IT, int> get pos => _pos;

  IntSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, int>(this);
  }

  factory IntSeries(Iterable<int> data, {dynamic name, List<IT> indices}) {
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

  factory IntSeries.fromMap(Map<IT, List<int>> map, {dynamic name}) {
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

  dynamic name;

  final UnmodifiableListView<IT> indices;

  final UnmodifiableListView<num> data;

  SeriesPositioned<IT, num> _pos;

  SeriesPositioned<IT, num> get pos => _pos;

  NumSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, num>(this);
  }

  factory NumSeries(Iterable<num> data, {dynamic name, List<IT> indices}) {
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

  factory NumSeries.fromMap(Map<IT, List<num>> map, {dynamic name}) {
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

class StringSeries<IT> extends Object
    with SeriesBase<IT, String>
    implements Series<IT, String> {
  final List<IT> _indices;

  final List<String> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> indices;

  final UnmodifiableListView<String> data;

  SeriesPositioned<IT, String> _pos;

  SeriesPositioned<IT, String> get pos => _pos;

  StringSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, String>(this);
  }

  factory StringSeries(Iterable<String> data,
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

    return new StringSeries._(data.toList(), indices, name, mapper);
  }

  factory StringSeries.fromMap(Map<IT, List<String>> map, {dynamic name}) {
    final List<IT> indices = [];
    final List<String> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (String val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new StringSeries._(data.toList(), indices, name, mapper);
  }
}
