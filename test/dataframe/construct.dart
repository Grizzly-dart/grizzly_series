import 'package:grizzly_series/grizzly_series.dart';
import 'package:test/test.dart';

void main() {
  group('DataFrame.Getters', () {
    setUp(() {});

    test('series', () {
      final df = new DataFrame.series({
        'one': new IntSeries<int>([1, 2, 3, 4]),
        'two': new IntSeries<int>([10, 20, 30, 40])
      });

      expect(df.labels, [0, 1, 2, 3]);

      expect(df.pos[0].data, [1, 10]);
      expect(df.pos[1].data, [2, 20]);
      expect(df.pos[2].data, [3, 30]);
      expect(df.pos[3].data, [4, 40]);
    });

    test('series.withSeriesList', () {
      final df = new DataFrame.series({
        'one': new IntSeries<int>([1, 2, 3, 4]),
        'two': new IntSeries<int>([10, 20, 30, 40])
      }, series: [
        new StringSeries<int>(['A', 'B', 'C', 'D'], name: 'alphabets')
      ]);

      expect(df.labels, [0, 1, 2, 3]);
      expect(df.columns, ['one', 'two', 'alphabets']);

      expect(df.pos[0].data, [1, 10, 'A']);
      expect(df.pos[1].data, [2, 20, 'B']);
      expect(df.pos[2].data, [3, 30, 'C']);
      expect(df.pos[3].data, [4, 40, 'D']);
    });

    test('series.withSeriesListAndList', () {
      final df = new DataFrame.series({
        'one': new IntSeries<int>([1, 2, 3, 4]),
        'two': new IntSeries<int>([10, 20, 30, 40])
      }, series: [
        new StringSeries<int>(['A', 'B', 'C', 'D'], name: 'alphabets')
      ], lists: {
        'three': [1000, 2000, 3000, 4000],
        'four': ['AA', 'BB', 'CC', 'DD']
      });

      expect(df.labels, [0, 1, 2, 3]);
      expect(df.columns, ['one', 'two', 'alphabets', 'three', 'four']);

      expect(df.pos[0].data, [1, 10, 'A', 1000, 'AA']);
      expect(df.pos[1].data, [2, 20, 'B', 2000, 'BB']);
      expect(df.pos[2].data, [3, 30, 'C', 3000, 'CC']);
      expect(df.pos[3].data, [4, 40, 'D', 4000, 'DD']);
    });
  });
}
