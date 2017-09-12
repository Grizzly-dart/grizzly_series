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

    test('Subscript operator multiple', () {
      final series = new IntSeries<int>([1, 2, 3, 4], labels: [1, 2, 2, 3]);
      expect(series[1], 1);
      expect(series[2], 2);
      expect(series[3], 4);
    });

    test('Subscript operator with String index', () {
      final series = new IntSeries<String>([1, 2, 3, 4],
          labels: ['one', 'two', 'three', 'four']);
      expect(series['one'], 1);
      expect(series['two'], 2);
      expect(series['three'], 3);
      expect(series['four'], 4);
    });

    test('Subscript operator multiple with String index', () {
      final series = new IntSeries<String>([1, 2, 3, 4],
          labels: ['one', 'two', 'two', 'three']);
      expect(series['one'], 1);
      expect(series['two'], 2);
      expect(series['three'], 4);
    });

    test('Pos', () {
      final series = new IntSeries<int>([1, 2, 3, 4]);
      expect(series.pos[0], 1);
      expect(series.pos[1], 2);
      expect(series.pos[2], 3);
      expect(series.pos[3], 4);
    });

    test('Indexed', () {
      final series = new IntSeries<int>([1, 2, 3, 4], labels: [1, 2, 2, 3]);
      expect(series.getByLabelMulti(1), [1]);
      expect(series.getByLabelMulti(2), [2, 3]);
      expect(series.getByLabelMulti(3), [4]);
    });

    test('add', () {
      final series1 = new IntSeries<int>([1, 2, 3, 4]);
      final series2 = new IntSeries<int>([1, 2, 3, 4]);
      final res = series1.add(series2);
      expect(res.labels, [0, 1, 2, 3]);
      expect(res.data, [2, 4, 6, 8]);
    });

    test('add dup1', () {
      final series1 = new IntSeries<int>([1, 2, 3, 4], labels: [1, 2, 2, 3]);
      final series2 = new IntSeries<int>([10, 20, 30], labels: [1, 2, 3]);
      final res = series1.add(series2);
      expect(res.labels, [1, 2, 2, 3]);
      expect(res.data, [11, 22, 23, 34]);
    });

    test('add dup2', () {
      final series1 = new IntSeries<int>([1, 2, 3, 4], labels: [1, 2, 2, 3]);
      final series2 =
          new IntSeries<int>([10, 20, 30, 40], labels: [1, 2, 2, 3]);
      final res = series1.add(series2);
      expect(res.labels, [1, 2, 2, 3]);
      expect(res.data, [11, 22, 33, 44]);
    });

    test('add dup3', () {
      final series1 = new IntSeries<int>([1, 2, 3, 4], labels: [1, 2, 2, 3]);
      final series2 =
          new IntSeries<int>([10, 20, 30, 40, 50], labels: [1, 2, 2, 2, 3]);
      final res = series1.add(series2);
      expect(res.labels, [1, 2, 2, 2, 2, 2, 2, 3]);
      expect(res.data, [11, 22, 32, 42, 23, 33, 43, 54]);
    });

    test('add other missing', () {
      final series1 =
          new IntSeries<int>([1, 2, 3, 4, 5], labels: [1, 2, 3, 4, 5]);
      final series2 = new IntSeries<int>([10, 20, 30], labels: [1, 2, 3]);
      final res = series1.add(series2);
      expect(res.labels, [1, 2, 3, 4, 5]);
      expect(res.data, [11, 22, 33, null, null]);
    });

    test('add self missing', () {
      final series1 = new IntSeries<int>([1, 2, 3], labels: [1, 2, 3]);
      final series2 =
          new IntSeries<int>([10, 20, 30, 40, 50], labels: [1, 2, 3, 4, 4]);
      final res = series1.add(series2);
      expect(res.labels, [1, 2, 3, 4, 4]);
      expect(res.data, [11, 22, 33, null, null]);
    });

    test('add other missing with fillValue', () {
      final series1 =
          new IntSeries<int>([1, 2, 3, 4, 5], labels: [1, 2, 3, 4, 4]);
      final series2 = new IntSeries<int>([10, 20, 30], labels: [1, 2, 3]);
      final res = series1.add(series2, fillVal: 100);
      expect(res.labels, [1, 2, 3, 4, 4]);
      expect(res.data, [11, 22, 33, 104, 105]);
    });
  });
}
