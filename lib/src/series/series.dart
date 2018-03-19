library grizzly.series;

import 'dart:collection';
import 'package:grizzly_series/src/utils/utils.dart';
import 'package:grizzly_series/grizzly_series.dart';
import 'package:grizzly_scales/grizzly_scales.dart';
import 'package:collection/collection.dart';
import 'package:grizzly_array/grizzly_array.dart';

import 'package:text_table/text_table.dart';

part 'base/series_fix.dart';
part 'base/series_mixin.dart';
part 'base/series_view_mixin.dart';

part 'bool/bool_fix.dart';
part 'bool/bool.dart';
part 'bool/bool_view.dart';

part 'int/int_fix.dart';
part 'int/int_series.dart';
part 'int/int_view.dart';
part 'int/int_view_mixin.dart';

part 'double/double_fix.dart';
part 'double/double_series.dart';
part 'double/double_view.dart';
part 'double/double_view_mixin.dart';

part 'string/string_fix.dart';
part 'string/string_view.dart';
part 'string/string_series.dart';

part 'dynamic/dynamic.dart';
part 'dynamic/dynamic_fix.dart';
part 'dynamic/dynamic_view.dart';
part 'dynamic/dynamic_view_mixin.dart';

part 'numeric.dart';

Series<LT, VT> series<LT, VT>(
    /* Iterable | IterView | SeriesView<LT, VT> | Map<LT, VT> */ data,
    {name,
    Iterable<LT> labels}) {
  if (data is Iterable<int> || data is IterView<int>) {
    return new IntSeries<LT>(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Iterable<double> || data is IterView<double>) {
    return new DoubleSeries<LT>(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Iterable<String> || data is IterView<String>) {
    return new StringSeries<LT>(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Iterable<bool> || data is IterView<bool>) {
    return new BoolSeries<LT>(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Map<dynamic, int>) {
    return new IntSeries<LT>.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Map<dynamic, double>) {
    return new DoubleSeries<LT>.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Map<dynamic, String>) {
    return new StringSeries<LT>.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Map<dynamic, bool>) {
    return new BoolSeries<LT>.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, int>) {
    return new IntSeries<LT>(data.data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, double>) {
    return new DoubleSeries<LT>(data.data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, String>) {
    return new StringSeries<LT>(data.data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, bool>) {
    return new BoolSeries<LT>(data.data, name: name, labels: labels)
        as Series<LT, VT>;
  }
  // TODO dynamic
  throw new UnimplementedError();
}
