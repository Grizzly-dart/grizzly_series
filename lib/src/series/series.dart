library grizzly.series;

import 'dart:collection';
import 'package:grizzly_series/src/utils/utils.dart';
import 'package:grizzly_series/grizzly_series.dart';
import 'package:grizzly_scales/grizzly_scales.dart';
import 'package:collection/collection.dart';
import 'package:grizzly_array/grizzly_array.dart';

part 'base/series_mixin.dart';
part 'base/series_view_mixin.dart';

part 'bool/bool.dart';
part 'bool/bool_view.dart';

part 'int/int_series.dart';
part 'int/int_view.dart';
part 'int/int_view_mixin.dart';

part 'double/double_series.dart';
part 'double/double_view.dart';
part 'double/double_view_mixin.dart';

part 'dynamic.dart';
part 'numeric.dart';
part 'string/string_view.dart';
part 'string/string_series.dart';

Series<LT, VT> series<LT, VT>(
    /* Iterable | IterView | SeriesView<LT, VT> | Map<LT, VT> */ data,
    {name,
    Iterable<LT> labels}) {
  if (data is Iterable<int> || data is IterView<int>) {
    return new IntSeries(data, name: name, labels: labels) as Series<LT, VT>;
  } else if (data is Iterable<double> || data is IterView<double>) {
    return new DoubleSeries(data, name: name, labels: labels) as Series<LT, VT>;
  } else if (data is Iterable<String> || data is IterView<String>) {
    return new StringSeries(data, name: name, labels: labels) as Series<LT, VT>;
  } else if (data is Iterable<bool> || data is IterView<bool>) {
    return new BoolSeries(data, name: name, labels: labels) as Series<LT, VT>;
  } else if (data is Map<dynamic, int>) {
    return new IntSeries.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Map<dynamic, double>) {
    return new DoubleSeries.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Map<dynamic, String>) {
    return new StringSeries.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Map<dynamic, bool>) {
    return new BoolSeries.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, int>) {
    return new IntSeries.copy(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, double>) {
    return new DoubleSeries.copy(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, String>) {
    return new StringSeries.copy(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, bool>) {
    return new BoolSeries.copy(data, name: name, labels: labels)
        as Series<LT, VT>;
  }
  // TODO dynamic
}
