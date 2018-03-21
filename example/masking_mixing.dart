import 'package:grizzly_series/grizzly_series.dart';

void main() {
  final df = new DataFrame<int>({
    'num': new IntSeries([1, 2, 3, 4, 5]),
    'other': new IntSeries([2, 1, 3, 5, 4]),
  });

  print(df['num'].asInt.stats.describe());

  print(df['num'] > df['other']);
  print(df['num'].eq(df['other']));

  df.keepIf(df['num'] > df['other']);
  print(df);
}
