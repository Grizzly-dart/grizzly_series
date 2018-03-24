import 'package:grizzly_array/grizzly_array.dart';
import 'package:grizzly_series/grizzly_series.dart';

void x(Numeric2DView y) {
  // TODO
}

main() {
  final df = new DataFrame<int>({
    'num': new IntSeries([1, 2, 3, 4, 5]),
  });
  x(df.asDouble2D());
  // TODO
}
