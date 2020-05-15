// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:grizzly_series/grizzly_series.dart';
import 'package:grizzly_array/grizzly_array.dart';
import 'package:test/test.dart';

void main() {
  group('StringSeries', () {
    test('default', () {
      final s = new StringSeries<String>(['ett', 'två', 'tre'],
          labels: ['one', 'two', 'three']);
      expect(s.labels, ['one', 'two', 'three']);
      expect(s.toList(), ['ett', 'två', 'tre']);
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

    test('fromMap', () {
      final s = new StringSeries<String>.fromMap({
        'one': 'ett',
        'two': 'två',
        'three': 'tre',
      });
      expect(s.labels, ['one', 'two', 'three']);
      expect(s.toList(), ['ett', 'två', 'tre']);
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

    test('ops', () {
      final s = new StringSeries<String>.fromMap({
        'one': 'ett',
        'two': 'två',
        'three': 'tre',
      });
      s['one'] = '1';
      expect(s.labels, ['one', 'two', 'three']);
      expect(s.toList(), ['1', 'två', 'tre']);
      s.set('one', 'ett');
      expect(s.labels, ['one', 'two', 'three']);
      expect(s.toList(), ['ett', 'två', 'tre']);
      s['five'] = 'fem';
      expect(s.labels, ['one', 'two', 'three', 'five']);
      expect(s.toList(), ['ett', 'två', 'tre', 'fem']);
      s.set('ten', 'tie');
      expect(s.labels, ['one', 'two', 'three', 'five', 'ten']);
      expect(s.toList(), ['ett', 'två', 'tre', 'fem', 'tie']);
      s.append('fifteen', 'femton');
      expect(s.labels, ['one', 'two', 'three', 'five', 'ten', 'fifteen']);
      expect(s.toList(), ['ett', 'två', 'tre', 'fem', 'tie', 'femton']);
      expect(
          () => s.append('ten', 'tie'), throwsA(isA<Exception>()));
      s.remove(4);
      expect(s.labels, ['one', 'two', 'three', 'five', 'fifteen']);
      expect(s.toList(), ['ett', 'två', 'tre', 'fem', 'femton']);
      s.removeMany([3, 4]);
      expect(s.labels, ['one', 'two', 'three']);
      expect(s.toList(), ['ett', 'två', 'tre']);
      s.drop('two');
      expect(s.labels, ['one', 'three']);
      expect(s.toList(), ['ett', 'tre']);
      s.assignMap({'five': 'fem', 'ten': 'tie'});
      expect(s.labels, ['one', 'three', 'five', 'ten']);
      expect(s.toList(), ['ett', 'tre', 'fem', 'tie']);
      s.dropMany(['one', 'three']);
      expect(s.labels, ['five', 'ten']);
      expect(s.toList(), ['fem', 'tie']);
      s.apply((s) => s + '.');
      expect(s.labels, ['five', 'ten']);
      expect(s.toList(), ['fem.', 'tie.']);
      s.apply((s) => s.substring(0, s.length - 1));
      expect(s.labels, ['five', 'ten']);
      expect(s.toList(), ['fem', 'tie']);
      s.assign(new StringSeriesView.fromMap(
          {'one': 'ett', 'two': 'två', 'three': 'tre'}));
      expect(s.labels, ['five', 'ten', 'one', 'two', 'three']);
      expect(s.toList(), ['fem', 'tie', 'ett', 'två', 'tre']);
      s.sortByLabel();
      expect(s.labels, ['five', 'one', 'ten', 'three', 'two']);
      expect(s.toList(), ['fem', 'ett', 'tie', 'tre', 'två']);
      s.sortByLabel(descending: true);
      expect(s.labels, ['two', 'three', 'ten', 'one', 'five']);
      expect(s.toList(), ['två', 'tre', 'tie', 'ett', 'fem']);
      s.sortByValue();
      expect(s.labels, ['one', 'five', 'ten', 'three', 'two']);
      expect(s.toList(), ['ett', 'fem', 'tie', 'tre', 'två']);
      s.sortByValue(descending: true);
      expect(s.labels, ['two', 'three', 'ten', 'five', 'one']);
      expect(s.toList(), ['två', 'tre', 'tie', 'fem', 'ett']);
      /* TODO
      s.keepIf([true, false, true, false, true]);
      expect(s.labels, ['two', 'ten', 'one']);
      expect(s.toList(), ['två', 'tie', 'ett']);
      */
    });
  });
}
