import 'dart:math';
import 'package:grizzly_series/grizzly_series.dart';
import 'package:test/test.dart';

void main() {
  group('DataFrame.Getters', () {
    setUp(() {});

    test('series.base', () {
      final df = DataFrame({
        'one': IntSeries<int>([1, 2, 3, 4]),
        'two': IntSeries<int>([10, 20, 30, 40])
      });

      expect(df.labels, [0, 1, 2, 3]);

      expect(df.getByPos(0).toList(), [1, 10]);
      expect(df.getByPos(1).toList(), [2, 20]);
      expect(df.getByPos(2).toList(), [3, 30]);
      expect(df.getByPos(3).toList(), [4, 40]);
    });

    test('series.string', () {
      final df = DataFrame({
        'one': IntSeries<int>([1, 2, 3, 4]),
        'two': IntSeries<int>([10, 20, 30, 40]),
        'alphabets': StringSeries<int>(['A', 'B', 'C', 'D'], name: 'alphabets')
      });

      expect(df.labels, [0, 1, 2, 3]);
      expect(df.columns, ['one', 'two', 'alphabets']);

      expect(df.getByPos(0).toList(), [1, 10, 'A']);
      expect(df.getByPos(1).toList(), [2, 20, 'B']);
      expect(df.getByPos(2).toList(), [3, 30, 'C']);
      expect(df.getByPos(3).toList(), [4, 40, 'D']);
    });

    test('series.withSeriesAndList', () {
      final df = DataFrame({
        'one': IntSeries<int>([1, 2, 3, 4]),
        'two': IntSeries<int>([10, 20, 30, 40]),
        'three': <int>[1000, 2000, 3000, 4000],
        'four': <String>['AA', 'BB', 'CC', 'DD']
      });

      expect(df.labels, [0, 1, 2, 3]);
      expect(df.columns, ['one', 'two', 'three', 'four']);

      expect(df.getByPos(0).toList(), [1, 10, 1000, 'AA']);
      expect(df.getByPos(1).toList(), [2, 20, 2000, 'BB']);
      expect(df.getByPos(2).toList(), [3, 30, 3000, 'CC']);
      expect(df.getByPos(3).toList(), [4, 40, 4000, 'DD']);
    });

    test('empty', () {
      final df = DataFrame<String>({});
      expect(df.numRows, 0);

      df.ensureLabel(List.generate(1000, (i) => i.toString()));
      expect(df.numRows, 1000);
    });
  });
}
