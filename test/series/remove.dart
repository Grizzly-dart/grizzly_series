import 'package:grizzly_series/grizzly_series.dart';
import 'package:test/test.dart';

void main() {
  group('Series.remove', () {
    setUp(() {});

    test('drop.inplace', () {
      final s1 = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      final serRes = s1.drop('two', inplace: true);

      expect(s1, serRes);

      expect(s1['zero'], 1);
      expect(s1['one'], 2);
      expect(() => s1['two'], throwsA(isException));
      expect(s1['three'], 4);
    });

    test('drop', () {
      final s1 = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      final serRes = s1.drop('two');

      expect(s1, isNot(equals(serRes)));

      expect(s1['zero'], 1);
      expect(s1['one'], 2);
      expect(s1['two'], 3);
      expect(s1['three'], 4);

      expect(serRes['zero'], 1);
      expect(serRes['one'], 2);
      expect(() => serRes['two'], throwsA(isException));
      expect(serRes['three'], 4);
    });

    test('drop.inplace with duplicate', () {
      final s1_dup = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'two']);

      final serRes = s1_dup.drop('two', inplace: true);

      expect(s1_dup, serRes);

      expect(s1_dup['zero'], 1);
      expect(s1_dup['one'], 2);
      expect(() => s1_dup['two'], throwsA(isException));
    });

    test('drop with duplicate', () {
      final s1_dup = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'two']);

      final serRes = s1_dup.drop('two');

      expect(s1_dup, isNot(equals(serRes)));

      expect(s1_dup['zero'], 1);
      expect(s1_dup['one'], 2);
      expect(s1_dup['two'], 3);
      expect(s1_dup.getByLabelMulti('two'), [3, 4]);

      expect(serRes['zero'], 1);
      expect(serRes['one'], 2);
      expect(() => serRes['two'], throwsA(isException));
    });

    test('dropMany.inplace', () {
      final s1 = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      final serRes = s1.dropMany(['zero', 'one'], inplace: true);

      expect(s1, serRes);

      expect(() => s1['zero'], throwsA(isException));
      expect(() => s1['one'], throwsA(isException));
      expect(s1['two'], 3);
      expect(s1['three'], 4);
    });

    test('dropMany', () {
      final s1 = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      final serRes = s1.dropMany(['zero', 'one']);

      expect(s1, isNot(equals(serRes)));

      expect(s1['zero'], 1);
      expect(s1['one'], 2);
      expect(s1['two'], 3);
      expect(s1['three'], 4);

      expect(() => serRes['zero'], throwsA(isException));
      expect(() => serRes['one'], throwsA(isException));
      expect(serRes['two'], 3);
      expect(serRes['three'], 4);
    });

    test('drop.inplace with duplicate', () {
      final s1_dup = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'two']);

      final serRes = s1_dup.dropMany(['zero', 'two'], inplace: true);

      expect(s1_dup, serRes);

      expect(() => s1_dup['zero'], throwsA(isException));
      expect(s1_dup['one'], 2);
      expect(() => s1_dup['two'], throwsA(isException));
    });

    test('drop with duplicate', () {
      final s1_dup = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'two']);

      final serRes = s1_dup.dropMany(['zero', 'two']);

      expect(s1_dup, isNot(equals(serRes)));

      expect(s1_dup['zero'], 1);
      expect(s1_dup['one'], 2);
      expect(s1_dup['two'], 3);
      expect(s1_dup.getByLabelMulti('two'), [3, 4]);

      expect(() => serRes['zero'], throwsA(isException));
      expect(serRes['one'], 2);
      expect(() => serRes['two'], throwsA(isException));
    });

    test('remove.inplace', () {
      final s1 = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      final serRes = s1.remove(2, inplace: true);

      expect(s1, serRes);

      expect(s1['zero'], 1);
      expect(s1['one'], 2);
      expect(() => s1['two'], throwsA(isException));
      expect(s1['three'], 4);
    });

    test('remove', () {
      final s1 = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      final serRes = s1.remove(2);

      expect(s1, isNot(equals(serRes)));

      expect(s1['zero'], 1);
      expect(s1['one'], 2);
      expect(s1['two'], 3);
      expect(s1['three'], 4);

      expect(serRes['zero'], 1);
      expect(serRes['one'], 2);
      expect(() => serRes['two'], throwsA(isException));
      expect(serRes['three'], 4);
    });

    test('remove.inplace with duplicate', () {
      final s1_dup = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'two']);

      final serRes = s1_dup.remove(2, inplace: true);

      expect(s1_dup, serRes);

      expect(s1_dup['zero'], 1);
      expect(s1_dup['one'], 2);
      expect(s1_dup.getByLabelMulti('two'), [4]);
    });

    test('remove with duplicate', () {
      final s1_dup = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'two']);

      final serRes = s1_dup.remove(2);

      expect(s1_dup, isNot(equals(serRes)));

      expect(s1_dup['zero'], 1);
      expect(s1_dup['one'], 2);
      expect(s1_dup['two'], 3);
      expect(s1_dup.getByLabelMulti('two'), [3, 4]);

      expect(serRes['zero'], 1);
      expect(serRes['one'], 2);
      expect(serRes.getByLabelMulti('two'), [4]);
    });

    test('removeMany.inplace', () {
      final s1 = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      final serRes = s1.removeMany([0, 1], inplace: true);

      expect(s1, serRes);

      expect(() => s1['zero'], throwsA(isException));
      expect(() => s1['one'], throwsA(isException));
      expect(s1['two'], 3);
      expect(s1['three'], 4);
    });

    test('removeMany', () {
      final s1 = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'three']);

      final serRes = s1.removeMany([0, 1]);

      expect(s1, isNot(equals(serRes)));

      expect(s1['zero'], 1);
      expect(s1['one'], 2);
      expect(s1['two'], 3);
      expect(s1['three'], 4);

      expect(() => serRes['zero'], throwsA(isException));
      expect(() => serRes['one'], throwsA(isException));
      expect(serRes['two'], 3);
      expect(serRes['three'], 4);
    });

    /* TODO
    test('drop.inplace with duplicate', () {
      final s1_dup = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'two']);

      final serRes = s1_dup.removeMany([0, 1], inplace: true);

      expect(s1_dup, serRes);

      expect(() => s1_dup['zero'], throwsA(isException));
      expect(s1_dup['one'], 2);
      expect(() => s1_dup['two'], throwsA(isException));
    });

    test('drop with duplicate', () {
      final s1_dup = new IntSeries<String>([1, 2, 3, 4],
          labels: ['zero', 'one', 'two', 'two']);

      final serRes = s1_dup.removeMany([0, 2]);

      expect(s1_dup, isNot(equals(serRes)));

      expect(s1_dup['zero'], 1);
      expect(s1_dup['one'], 2);
      expect(s1_dup['two'], 3);
      expect(s1_dup.getByIndexMulti('two'), [3, 4]);

      expect(() => serRes['zero'], throwsA(isException));
      expect(serRes['one'], 2);
      expect(() => serRes['two'], throwsA(isException));
    });
    */
  });
}
