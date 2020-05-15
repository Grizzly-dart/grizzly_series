import 'package:grizzly_series/grizzly_series.dart';
import 'package:test/test.dart';

void main() {
  group('Series.remove', () {
    setUp(() {});

    test('drop.inplace', () {
      final s1 = IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      s1.drop('two');

      expect(s1['zero'], 1);
      expect(s1['one'], 2);
      expect(() => s1['two'], throwsA(isA<LabelNotFound>()));
      expect(s1['three'], 4);
    });

    test('dropMany', () {
      final s1 = IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      s1.dropMany(['zero', 'one']);

      expect(() => s1['zero'], throwsA(isA<LabelNotFound>()));
      expect(() => s1['one'], throwsA(isA<LabelNotFound>()));
      expect(s1['two'], 3);
      expect(s1['three'], 4);
    });

    test('remove', () {
      final s1 = IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      s1.remove(2);

      expect(s1['zero'], 1);
      expect(s1['one'], 2);
      expect(() => s1['two'], throwsA(isA<LabelNotFound>()));
      expect(s1['three'], 4);
    });

    test('removeMany', () {
      final s1 = IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      s1.removeMany([0, 1]);

      expect(() => s1['zero'], throwsA(isA<LabelNotFound>()));
      expect(() => s1['one'], throwsA(isA<LabelNotFound>()));
      expect(s1['two'], 3);
      expect(s1['three'], 4);
    });
  });
}
