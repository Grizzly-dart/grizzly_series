import 'package:grizzly_series/grizzly_series.dart';

void main() {
  final df = DataFrame<int>({
    'num': IntSeries([1, 2, 3, 4, 5]),
    'other': IntSeries([2, 1, 3, 5, 4]),
  });

  print(df['num'].asInt.stats.describe());

  print(df['num'] > df['other']);
  print(df['num'].eq(df['other']));

  print(df.select(df['num'] > df['other']));

  df.keepIf(df['num'] > df['other']);
  print(df);
}
