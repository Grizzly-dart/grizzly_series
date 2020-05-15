// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:grizzly_series/grizzly_series.dart';
import 'package:grizzly_array/grizzly_array.dart';
import 'package:test/test.dart';

void main() {
  group('StringSeriesView', () {
    test('default', () {
      final s = StringSeriesView<String>(['ett', 'två', 'tre'],
          labels: ['one', 'two', 'three']);
      expect(s.labels, ['one', 'two', 'three']);
      expect(s.data, ['ett', 'två', 'tre']);
      expect(s.length, 3);
      expect(s.containsLabel('one'), true);
      expect(s.containsLabel('four'), false);
      expect(s['one'], 'ett');
      expect(s['two'], 'två');
      expect(s['three'], 'tre');
      expect(() => s['four'], throwsA(isA<LabelNotFound>()));
      expect(s.get('one'), 'ett');
      expect(() => s.get('four'), throwsA(isA<LabelNotFound>()));
      expect(s.getByPos(1), 'två');
      expect(s.labelAt(1), 'two');
      expect(s.posOf('two'), 1);
      expect(s.labelsMatch(<String>['one', 'two', 'three']), true);
      expect(s.labelsMatch(<String>['one', 'two']), false);
      expect(s.labelsMatch(<String>['one', 'two', 'three', 'four']), false);
    });

    test('map', () {
      final s = StringSeriesView<String>.fromMap({
        'one': 'ett',
        'two': 'två',
        'three': 'tre',
      });
      expect(s.labels, ['one', 'two', 'three']);
      expect(s.data, ['ett', 'två', 'tre']);
      expect(s.length, 3);
      expect(s.containsLabel('one'), true);
      expect(s.containsLabel('four'), false);
      expect(s['one'], 'ett');
      expect(s['two'], 'två');
      expect(s['three'], 'tre');
      expect(() => s['four'], throwsA(isA<LabelNotFound>()));
      expect(s.get('one'), 'ett');
      expect(() => s.get('four'), throwsA(isA<LabelNotFound>()));
      expect(s.getByPos(1), 'två');
      expect(s.labelAt(1), 'two');
      expect(s.posOf('two'), 1);
      expect(s.labelsMatch(<String>['one', 'two', 'three']), true);
      expect(s.labelsMatch(<String>['one', 'two']), false);
      expect(s.labelsMatch(<String>['one', 'two', 'three', 'four']), false);
    });
  });
}
