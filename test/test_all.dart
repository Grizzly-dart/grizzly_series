import 'array/int.dart' as arrayInt;
import 'array2d/int.dart' as array2DInt;
import 'dataframe/construct.dart' as dataframeConstruct;
import 'dataframe/getters.dart' as dataframeGetters;
import 'series/int/math_ops.dart' as seriesIntMathOps;
import 'series/remove.dart' as seriesRemove;
import 'series/series.dart' as series;

void main() {
  arrayInt.main();

  array2DInt.main();

  dataframeConstruct.main();
  dataframeGetters.main();

  seriesIntMathOps.main();

  seriesRemove.main();
  series.main();
}
