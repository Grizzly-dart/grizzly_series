import 'package:grizzly/grizzly.dart';
import 'package:test/test.dart';

void main() {
  group('DataFrame.Getters', () {
    final df = new DataFrame<String, String>({
      'age': [20, 22, 35],
      'house': ['Stark', 'Targaryan', 'Lannister']
    }, indices: [
      'Jon',
      'Dany',
      'Tyrion'
    ]);

    setUp(() {});

    test('Subscript', () {
      expect(df['age'].data, [20, 22, 35]);
      expect(df['age'].indices, ['Jon', 'Dany', 'Tyrion']);
      expect(df['age'].name, 'age');
      expect(df['house'].data, ['Stark', 'Targaryan', 'Lannister']);
      expect(df['house'].indices, ['Jon', 'Dany', 'Tyrion']);
      expect(df['house'].name, 'house');
      expect(() => df['unknown'], throwsA(isException));
    });

    test('getByPos', () {
      expect(df.getByPos(0).data, [20, 'Stark']);
      expect(df.getByPos(0).indices, ['age', 'house']);
      expect(df.getByPos(0).name, 'Jon');
      expect(df.getByPos(1).data, [22, 'Targaryan']);
      expect(df.getByPos(1).indices, ['age', 'house']);
      expect(df.getByPos(1).name, 'Dany');
      expect(df.getByPos(2).data, [35, 'Lannister']);
      expect(df.getByPos(2).indices, ['age', 'house']);
      expect(df.getByPos(2).name, 'Tyrion');
      expect(() => df.getByPos(3), throwsA(isRangeError));
    });

    test('getByIndex', () {
      expect(df.getByIndex('Jon').data, [20, 'Stark']);
      expect(df.getByIndex('Jon').indices, ['age', 'house']);
      expect(df.getByIndex('Jon').name, 'Jon');
      expect(df.getByIndex('Dany').data, [22, 'Targaryan']);
      expect(df.getByIndex('Dany').indices, ['age', 'house']);
      expect(df.getByIndex('Dany').name, 'Dany');
      expect(df.getByIndex('Tyrion').data, [35, 'Lannister']);
      expect(df.getByIndex('Tyrion').indices, ['age', 'house']);
      expect(df.getByIndex('Tyrion').name, 'Tyrion');
      expect(() => df.getByIndex('Cersei'), throwsA(isException));
    });

    /* TODO
    test('Subscript operator multiple', () {
      final series = new IntSeries<int>([1, 2, 3, 4], indices: [1, 2, 2, 3]);
      expect(series[1], 1);
      expect(series[2], 2);
      expect(series[3], 4);
    });

    test('Subscript operator with String index', () {
      final series = new IntSeries<String>([1, 2, 3, 4],
          indices: ['one', 'two', 'three', 'four']);
      expect(series['one'], 1);
      expect(series['two'], 2);
      expect(series['three'], 3);
      expect(series['four'], 4);
    });

    test('Subscript operator multiple with String index', () {
      final series = new IntSeries<String>([1, 2, 3, 4],
          indices: ['one', 'two', 'two', 'three']);
      expect(series['one'], 1);
      expect(series['two'], 2);
      expect(series['three'], 4);
    });

    test('add', () {
      final series1 = new IntSeries<int>([1, 2, 3, 4]);
      final series2 = new IntSeries<int>([1, 2, 3, 4]);
      final res = series1.add(series2);
      expect(res.indices, [0, 1, 2, 3]);
      expect(res.data, [2, 4, 6, 8]);
    });

    test('add dup1', () {
      final series1 = new IntSeries<int>([1, 2, 3, 4], indices: [1, 2, 2, 3]);
      final series2 = new IntSeries<int>([10, 20, 30], indices: [1, 2, 3]);
      final res = series1.add(series2);
      expect(res.indices, [1, 2, 2, 3]);
      expect(res.data, [11, 22, 23, 34]);
    });

    test('add dup2', () {
      final series1 = new IntSeries<int>([1, 2, 3, 4], indices: [1, 2, 2, 3]);
      final series2 =
          new IntSeries<int>([10, 20, 30, 40], indices: [1, 2, 2, 3]);
      final res = series1.add(series2);
      expect(res.indices, [1, 2, 2, 3]);
      expect(res.data, [11, 22, 33, 44]);
    });

    test('add dup3', () {
      final series1 = new IntSeries<int>([1, 2, 3, 4], indices: [1, 2, 2, 3]);
      final series2 =
          new IntSeries<int>([10, 20, 30, 40, 50], indices: [1, 2, 2, 2, 3]);
      final res = series1.add(series2);
      expect(res.indices, [1, 2, 2, 2, 2, 2, 2, 3]);
      expect(res.data, [11, 22, 32, 42, 23, 33, 43, 54]);
    });

    test('add other missing', () {
      final series1 =
          new IntSeries<int>([1, 2, 3, 4, 5], indices: [1, 2, 3, 4, 5]);
      final series2 = new IntSeries<int>([10, 20, 30], indices: [1, 2, 3]);
      final res = series1.add(series2);
      expect(res.indices, [1, 2, 3, 4, 5]);
      expect(res.data, [11, 22, 33, null, null]);
    });

    test('add self missing', () {
      final series1 = new IntSeries<int>([1, 2, 3], indices: [1, 2, 3]);
      final series2 =
          new IntSeries<int>([10, 20, 30, 40, 50], indices: [1, 2, 3, 4, 4]);
      final res = series1.add(series2);
      expect(res.indices, [1, 2, 3, 4, 4]);
      expect(res.data, [11, 22, 33, null, null]);
    });

    test('add other missing with fillValue', () {
      final series1 =
          new IntSeries<int>([1, 2, 3, 4, 5], indices: [1, 2, 3, 4, 4]);
      final series2 = new IntSeries<int>([10, 20, 30], indices: [1, 2, 3]);
      final res = series1.add(series2, fillVal: 100);
      expect(res.indices, [1, 2, 3, 4, 4]);
      expect(res.data, [11, 22, 33, 104, 105]);
    });
    */
  });
}
