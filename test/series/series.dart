// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:grizzly_series/grizzly_series.dart';
import 'package:test/test.dart';

void main() {
  group('Series', () {
    setUp(() {});

    test('Subscript operator', () {
      final series = new IntSeries<int>([1, 2, 3, 4]);
      expect(series[0], 1);
      expect(series[1], 2);
      expect(series[2], 3);
      expect(series[3], 4);
    });

    test('duplicate exception', () {
      expect(() => new IntSeries<int>([1, 2, 3, 4], labels: [1, 2, 2, 3]),
          throwsA(isA<Exception>()));
    });

    test('Subscript operator with String index', () {
      final series = new IntSeries<String>([1, 2, 3, 4],
          labels: ['one', 'two', 'three', 'four']);
      expect(series['one'], 1);
      expect(series['two'], 2);
      expect(series['three'], 3);
      expect(series['four'], 4);
    });

    test('Pos', () {
      final series = new IntSeries<int>([1, 2, 3, 4]);
      expect(series.getByPos(0), 1);
      expect(series.getByPos(1), 2);
      expect(series.getByPos(2), 3);
      expect(series.getByPos(3), 4);
    });

    test('add other missing', () {
      final series1 =
          new IntSeries<int>([1, 2, 3, 4, 5], labels: [1, 2, 3, 4, 5]);
      final series2 = new IntSeries<int>([10, 20, 30], labels: [1, 2, 3]);
      final res = series1 + series2;
      expect(res.labels, [1, 2, 3, 4, 5]);
      expect(res.toList(), [11, 22, 33, 4, 5]);
    });

    test('add self missing', () {
      final series1 = new IntSeries<int>([1, 2, 3], labels: [1, 2, 3]);
      final series2 =
          new IntSeries<int>([10, 20, 30, 40], labels: [1, 2, 3, 4]);
      final res = series1 + series2;
      expect(res.labels, [1, 2, 3]);
      expect(res.toList(), [11, 22, 33]);
    });

    /* TODO
    test('add other missing with fillValue', () {
      final series1 = new IntSeries<int>([1, 2, 3, 4], labels: [1, 2, 3, 4]);
      final series2 = new IntSeries<int>([10, 20, 30], labels: [1, 2, 3]);
      final res =
          series1.addition(series2, myFillValue: 100, otherFillValue: 100);
      expect(res.labels, [1, 2, 3, 4, 4]);
      expect(res.data, [11, 22, 33, 104, 105]);
    });
    */
  });
}
