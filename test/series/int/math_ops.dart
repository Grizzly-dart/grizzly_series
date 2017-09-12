// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:grizzly_series/grizzly_series.dart';
import 'package:test/test.dart';

void main() {
  group('IntSeries.MathOps', () {
    setUp(() {});

    test('add', () {
      final s1 = new IntSeries<int>([1, 2, 3, 4]);
      final s2 = new IntSeries<int>([1, 2, 3, 4]);

      final IntSeries<int> s3 = s1 + s2;

      expect(s3.data, [2, 4, 6, 8]);
      expect(s3.labels, [0, 1, 2, 3]);
    });

    test('add.StrIndex', () {
      final s1 = new IntSeries<String>([1, 2, 3, 4],
          labels: ['one', 'two', 'three', 'four']);
      final s2 = new IntSeries<String>([1, 2, 3, 4],
          labels: ['one', 'three', 'four', 'two']);

      final IntSeries<String> s3 = s1 + s2;

      expect(s3['one'], 2);
      expect(s3['two'], 6);
      expect(s3['three'], 5);
      expect(s3['four'], 7);

      //TODO expect(s3.data, [2, 6, 5, 7]);
      //TODO expect(s3.labels, ['one', 'two', 'three', 'four']);
    });

    test('gt', () {
      final s1 = new IntSeries<int>([1, 2, 3, 4, 5]);
      final s2 = new IntSeries<int>([5, 4, 3, 2, 1]);

      final BoolSeries<int> s3 = s1.gt(s2);

      expect(s3[0], false);
      expect(s3[1], false);
      expect(s3[2], false);
      expect(s3[3], true);
      expect(s3[4], true);

      expect(s3.data, [false, false, false, true, true]);
      expect(s3.labels, [0, 1, 2, 3, 4]);
    });

    test('lt', () {
      final s1 = new IntSeries<int>([1, 2, 3, 4, 5]);
      final s2 = new IntSeries<int>([5, 4, 3, 2, 1]);

      final BoolSeries<int> s3 = s1.lt(s2);

      expect(s3[0], true);
      expect(s3[1], true);
      expect(s3[2], false);
      expect(s3[3], false);
      expect(s3[4], false);

      expect(s3.data, [true, true, false, false, false]);
      expect(s3.labels, [0, 1, 2, 3, 4]);
    });

    test('gt.NonIdenticalIndex', () {
      final s1 = new IntSeries<int>([1, 2, 3], labels: [0, 1, 1]);
      final s2 = new IntSeries<int>([5, 4, 3], labels: [0, 1, 0]);

      expect(() => s1.gt(s2), throwsA(isException));
    });
  });
}
