import 'dataframe/construct.dart' as dataframeConstruct;
import 'dataframe/getters.dart' as dataframeGetters;
import 'series/int/math_ops.dart' as seriesIntMathOps;
import 'series/remove.dart' as seriesRemove;
import 'series/series.dart' as series;

void main() {
  dataframeConstruct.main();
  dataframeGetters.main();

  seriesIntMathOps.main();

  seriesRemove.main();
  series.main();
}
