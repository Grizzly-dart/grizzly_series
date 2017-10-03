library grizzly.series;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:collection';
import 'package:grizzly_series/src/utils/utils.dart';
import 'package:grizzly_series/grizzly_series.dart';
import 'package:grizzly_scales/grizzly_scales.dart';

part 'base.dart';
part 'bool.dart';
part 'double.dart';
part 'dynamic.dart';
part 'int.dart';
part 'numeric.dart';
part 'string.dart';

typedef SeriesMaker<IT, VT> = Series<IT, VT> Function(Iterable<VT> data,
    {dynamic name, Iterable<IT> labels});

abstract class Series<IT, VT> {
  dynamic name;

  UnmodifiableListView<IT> get labels;

  UnmodifiableListView<VT> get data;

  int get length;

  SeriesPositioned<IT, VT> get pos;

  /// Checks if Series contains the label
  bool containsIndex(IT label);

  /// Lookup by label
  VT operator [](IT label);

  operator []=(IT label, VT val);

  /// Lookup by position
  VT getByPos(int position);

  void setByPos(int position, VT value);

  /// Returns multiple values by label
  VT getByLabel(IT label);

  void setByLabel(IT label, VT value);

  /// Returns multiple values by label
  List<VT> getByLabelMulti(IT label);

  /// Returns label at position
  IT labelAt(int position);

  Pair<IT, VT> pairByLabel(IT label);

  Pair<IT, VT> pairByPos(int pos);

  Iterable<Pair<IT, VT>> enumerate();

  Iterable<Pair<IT, VT>> enumerateSliced(int start, [int end]);

  void append(IT label, VT value);

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
      {dynamic name, List<IIT> labels});

  SeriesView<IT, VT> toView();

  DataFrame<IT, dynamic> toDataFrame<CT>({CT column});

  StringSeries<IT> toStringSeries();

  SplayTreeMap<IT, List<int>> cloneMapper();

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
