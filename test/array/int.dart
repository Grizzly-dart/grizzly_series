import 'package:grizzly_series/grizzly_series.dart';
import 'package:test/test.dart';

void main() {
  group('IntArray', () {
    setUp(() {});

    test('average', () {
      IntArray s1 = new IntArray.from([1, 5]);
      expect(s1.average([1, 2]), 3.6666666666666665);
      s1 = new IntArray.from([2, 6]);
      expect(s1.average([1, 2]), 4.6666666666666667);
      s1 = new IntArray.from([3, 7]);
      expect(s1.average([1, 2]), 5.6666666666666667);
      s1 = new IntArray.from([4, 8]);
      expect(s1.average([1, 2]), 6.6666666666666667);
    });

    test('to2D', () {
      IntArray s1 = new IntArray.from([1, 5]);
      expect(s1.to2D(), [
        [1, 5]
      ]);
      expect(s1.transpose(), [
        [1],
        [5]
      ]);
      expect(s1.to2D().shape, idx2D(1, 2));
      expect(s1.transpose().shape, idx2D(2, 1));
    });
  });
}
