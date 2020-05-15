library grizzly.series;

import 'dart:collection';
import 'package:grizzly_series/src/utils/utils.dart';
import 'package:grizzly_series/grizzly_series.dart';
import 'package:collection/collection.dart';
import 'package:grizzly_array/grizzly_array.dart';
import 'package:grizzly_range/grizzly_range.dart' as ranger;

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
    /* Iterable | SeriesView<LT, VT> | Map<LT, VT> */ data,
    {name,
    Iterable<LT> labels}) {
  if (data is Iterable<int>) {
    return IntSeries<LT>(data, name: name, labels: labels) as Series<LT, VT>;
  } else if (data is Iterable<double>) {
    return DoubleSeries<LT>(data, name: name, labels: labels) as Series<LT, VT>;
  } else if (data is Iterable<String>) {
    return StringSeries<LT>(data, name: name, labels: labels) as Series<LT, VT>;
  } else if (data is Iterable<bool>) {
    return BoolSeries<LT>(data, name: name, labels: labels) as Series<LT, VT>;
  } else if (data is Map<dynamic, int>) {
    return IntSeries<LT>.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Map<dynamic, double>) {
    return DoubleSeries<LT>.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Map<dynamic, String>) {
    return StringSeries<LT>.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is Map<dynamic, bool>) {
    return BoolSeries<LT>.fromMap(data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, int>) {
    return IntSeries<LT>(data.data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, double>) {
    return DoubleSeries<LT>(data.data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, String>) {
    return StringSeries<LT>(data.data, name: name, labels: labels)
        as Series<LT, VT>;
  } else if (data is SeriesView<dynamic, bool>) {
    return BoolSeries<LT>(data.data, name: name, labels: labels)
        as Series<LT, VT>;
  }
  // TODO dynamic
  throw UnimplementedError();
}
