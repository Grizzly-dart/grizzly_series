library grizzly.series;

import 'dart:math' as math;
import 'dart:collection';
import '../data_frame/data_frame.dart';

part 'bool.dart';
part 'double.dart';
part 'dynamic.dart';
part 'int.dart';
part 'num.dart';
part 'numeric.dart';
part 'string.dart';

typedef SeriesMaker<IT, VT> = Series<IT, VT> Function(Iterable<VT> data,
    {dynamic name, Iterable<IT> indices});

void _sort(List list, bool ascending) {
  dynamic firstVal = list.firstWhere((v) => v != null, orElse: () => null);
  if (firstVal == null) return;

  if (firstVal is Comparable) {
    if (ascending) {
      (list as List<Comparable>)
          .sort((Comparable a, Comparable b) => a.compareTo(b));
    } else {
      (list as List<Comparable>)
          .sort((Comparable a, Comparable b) => b.compareTo(a));
    }
  } else if (firstVal is bool) {
    throw new Exception('Not implemented for bool yet!');
  } else {
    throw new Exception('Can only sort Comparable!');
  }
}

class _SeriesValueSortItem<IT, VT>
    implements Comparable<_SeriesValueSortItem<IT, VT>> {
  final IT index;

  final VT value;

  _SeriesValueSortItem(this.index, this.value);

  int compareTo(_SeriesValueSortItem<IT, VT> other) =>
      _SeriesValueSortItem.compare<IT, VT>(this, other);

  static int compare<IT, VT>(
      _SeriesValueSortItem<IT, VT> first, _SeriesValueSortItem<IT, VT> second) {
    if (first.value != null) {
      if (first.value is! Comparable)
        throw new Exception('Can only compare Comparable values!');
    } else {
      if (second.value != null) {
        if (second.value is! Comparable)
          throw new Exception('Can only compare Comparable values!');
      } else {
        return 0;
      }
    }
    return (first.value as Comparable<VT>).compareTo(second.value);
  }
}

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

  /// Remove element at position [pos]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> remove(int pos, {bool inplace: false});

  /// Remove multiple element at positions [positions]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> removeMany(List<int> positions, {bool inplace: false});

  /// Drop elements by label [label]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> drop(IT label, {bool inplace: false});

  void apply(VT func(VT value));

  void assign(Series<IT, VT> other);

  VT max();

  VT min();

  Series<int, VT> mode();

  IntSeries<VT> valueCounts(
      {bool sortByValue: false, bool ascending: false, bool dropNull: false});

  /* TODO IntSeries<VT> valueCountsNormalized(
      {bool sortByValue: false, bool ascending: false, bool dropNull: false}); */

  Series<IT, VT> sortByValue({bool ascending: true, bool inplace: false});

  Series<IT, VT> sortByIndex({bool ascending: true, bool inplace: false});

  Series<IIT, VT> makeNew<IIT>(Iterable<VT> data,
      {dynamic name, List<IIT> indices});

  SeriesView<IT, VT> toView();

  DataFrame<IT, dynamic> toDataFrame<CT>({CT column});

  StringSeries<IT> toStringSeries();

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

  void _updatePosOnRemove(int posLimit) {
    _mapper.forEach((_, List<int> list) {
      for (int i = 0; i < list.length; i++) {
        if (list[i] > posLimit) list[i]--;
      }
    });
  }

  /// Remove element at position [pos]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> remove(int pos, {bool inplace: false}) {
    if (pos >= length) throw new RangeError.range(pos, 0, length);
    if (inplace) {
      final IT label = _indices[pos];
      _mapper[label].remove(pos);
      if (_mapper[label].length == 0) _mapper.remove(label);
      _indices.removeAt(pos);
      _data.removeAt(pos);
      _updatePosOnRemove(pos);
      return this;
    } else {
      final List<IT> idx = _indices.toList();
      final List<VT> d = _data.toList();

      idx.removeAt(pos);
      d.removeAt(pos);

      return makeNew(d, name: name, indices: idx);
    }
  }

  /// Remove multiple element at positions [positions]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> removeMany(List<int> positions, {bool inplace: false}) {
    if (positions.length == 0) {
      //TODO we should accept this
      throw new Exception('positions cannot be empty List!');
    }

    final positionSet = new Set<int>.from(positions).toList();
    positionSet.sort((int a, int b) => b.compareTo(a));
    if (positionSet.first >= length)
      throw new RangeError.range(positionSet.first, 0, length);

    if (inplace) {
      for (int pos in positionSet) {
        final IT label = _indices[pos];
        _mapper[label].remove(pos);
        if (_mapper[label].length == 0) _mapper.remove(label);
        _indices.removeAt(pos);
        _data.removeAt(pos);
        _updatePosOnRemove(pos);
      }
      return this;
    } else {
      final List<IT> idx = _indices.toList();
      final List<VT> d = _data.toList();

      for (int pos in positionSet) {
        idx.removeAt(pos);
        d.removeAt(pos);
      }

      return makeNew(d, name: name, indices: idx);
    }
  }

  /// Drop elements by label [label]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> drop(IT label, {bool inplace: false}) {
    if (!_mapper.containsKey(label)) {
      //TODO should we ignore this?
      throw new Exception('Label not found!');
    }

    if (inplace) {
      final List<int> poses = _mapper[label].toList();
      poses.sort((int a, int b) => b.compareTo(a));
      for (int pos in poses) {
        _indices.removeAt(pos);
        _data.removeAt(pos);
        _updatePosOnRemove(pos);
      }
      _mapper.remove(label);
      return this;
    } else {
      final List<IT> idx = _indices.toList();
      final List<VT> d = _data.toList();

      final List<int> poses = _mapper[label].toList();
      poses.sort((int a, int b) => b.compareTo(a));
      for (int pos in poses) {
        idx.removeAt(pos);
        d.removeAt(pos);
      }

      return makeNew(d, name: name, indices: idx);
    }
  }

  /// Drop elements by label [label]
  ///
  /// If [inplace] is true, the modifications are done inplace.
  Series<IT, VT> dropMany(List<IT> label, {bool inplace: false}) {
    final List<IT> labelSet =
        label.where((IT lab) => _mapper.containsKey(lab)).toList();
    final positionSet = labelSet.fold(new Set<int>(), (Set<int> set, IT lab) {
      List<int> pos = _mapper[lab];
      set.addAll(pos);
      return set;
    }).toList()
      ..sort((int a, int b) => b.compareTo(a));

    if (inplace) {
      labelSet.forEach((IT idx) => _mapper.remove(idx));
      for (int pos in positionSet) {
        _indices.removeAt(pos);
        _data.removeAt(pos);
        _updatePosOnRemove(pos);
      }
      return this;
    } else {
      final List<IT> idx = _indices.toList();
      final List<VT> d = _data.toList();

      for (int pos in positionSet) {
        idx.removeAt(pos);
        d.removeAt(pos);
      }

      return makeNew(d, name: name, indices: idx);
    }
  }

  void assign(Series<IT, VT> other) {
    // Check
    for (IT key in _mapper.keys) {
      if (!other.containsIndex(key)) continue;

      final List<int> sourcePos = _mapper[key];
      final List<int> destPos = other._mapper[key];

      if (sourcePos.length != destPos.length) {
        if (destPos.length != 1) {
          throw new Exception('Mismatch of value lengths by index!');
        }
      }
    }

    // Assign
    for (IT key in _mapper.keys) {
      if (!other.containsIndex(key)) continue;

      final List<int> sourcePos = _mapper[key];
      final List<int> destPos = other._mapper[key];

      if (sourcePos.length == destPos.length) {
        for (int i = 0; i < sourcePos.length; i++) {
          _data[sourcePos[i]] = other.data[destPos[i]];
        }
      } else {
        final VT destData = other.data[destPos.first];
        for (int pos in sourcePos) {
          _data[pos] = destData;
        }
      }
    }
  }

  void apply(VT func(VT value)) {
    for (int i = 0; i < length; i++) {
      _data[i] = func(_data[i]);
    }
  }

  Series<int, VT> mode() {
    final LinkedHashMap<VT, int> map = new LinkedHashMap<VT, int>();
    int max = 0;

    for (VT v in _data) {
      if (!map.containsKey(v)) map[v] = 0;
      map[v]++;
      if (map[v] > max) max = map[v];
    }

    if (max == 0) return makeNew<int>([], indices: []);

    final ret = <VT>[];

    for (VT k in map.keys) {
      if (map[k] != max) continue;
      ret.add(k);
    }

    return makeNew<int>(ret);
  }

  StringSeries<IT> toStringSeries() {
    return new StringSeries<IT>(_data.map((v) => v.toString()).toList(),
        name: name, indices: _indices.toList());
  }

  @override
  IntSeries<VT> valueCounts(
      {bool sortByValue: false,
      bool ascending: false,
      bool dropNull: false,
      dynamic name}) {
    final groups = new Map<VT, List<int>>();

    for (int i = 0; i < length; i++) {
      final VT v = _data[i];
      if (!groups.containsKey(v)) groups[v] = <int>[0];
      groups[v][0]++;
    }

    // Drop null
    if (dropNull) {
      groups.remove(null);
    }

    final ret = new IntSeries<VT>.fromMap(groups, name: name ?? this.name);

    // Sort
    if (sortByValue) {
      ret.sortByIndex(ascending: ascending, inplace: true);
    } else {
      ret.sortByValue(ascending: ascending, inplace: true);
    }

    return ret;
  }

  DataFrame<IT, dynamic> toDataFrame<CT>({CT column}) {
    return new DataFrame<IT, CT>({column ?? name: data}, indices: indices);
  }

  Series<IT, VT> sortByValue(
      {bool ascending: true, bool inplace: false, name}) {
    if (length == 0) {
      if (inplace)
        return this;
      else
        return makeNew([], indices: [], name: name ?? this.name);
    }

    final items = <_SeriesValueSortItem<IT, VT>>[];

    for (int i = 0; i < length; i++) {
      items.add(new _SeriesValueSortItem(_indices[i], _data[i]));
    }

    if (ascending) {
      items.sort(_SeriesValueSortItem.compare);
    } else {
      items.sort((a, b) => _SeriesValueSortItem.compare(b, a));
    }

    if (inplace) {
      final idx = <IT>[];
      final List<VT> d = <VT>[];
      final mapper = new SplayTreeMap<IT, List<int>>();

      for (_SeriesValueSortItem i in items) {
        idx.add(i.index);
        d.add(i.value);
        if (!mapper.containsKey(i.index)) mapper[i.index] = <int>[];
        mapper[i.index].add(idx.length - 1);
      }

      _indices.replaceRange(0, _indices.length, idx);
      _data.replaceRange(0, _data.length, d);
      _mapper.clear();
      _mapper.addAll(mapper);

      return this;
    } else {
      final idx = <IT>[];
      final List<VT> d = <VT>[];

      for (_SeriesValueSortItem i in items) {
        idx.add(i.index);
        d.add(i.value);
      }

      return makeNew(d, name: name ?? this.name, indices: idx);
    }
  }

  Series<IT, VT> sortByIndex(
      {bool ascending: true, bool inplace: false, name}) {
    List<IT> idxSorted = _mapper.keys.toList();

    _sort(idxSorted, ascending);

    if (inplace) {
      final idx = <IT>[];
      final List<VT> d = <VT>[];
      final mapper = new SplayTreeMap<IT, List<int>>();

      for (IT i in idxSorted) {
        mapper[i] = <int>[];
        for (int pos in _mapper[i]) {
          idx.add(i);
          d.add(_data[pos]);
          mapper[i].add(idx.length - 1);
        }
      }

      _indices.replaceRange(0, _indices.length, idx);
      _data.replaceRange(0, _data.length, d);
      _mapper.clear();
      _mapper.addAll(mapper);

      return this;
    } else {
      final idx = <IT>[];
      final List<VT> d = <VT>[];

      for (IT i in idxSorted) {
        for (int pos in _mapper[i]) {
          idx.add(i);
          d.add(_data[pos]);
        }
      }

      return makeNew(d, name: name ?? this.name, indices: idx);
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
