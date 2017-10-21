import 'package:grizzly_series/grizzly_series.dart';
import 'package:test/test.dart';

void main() {
  group('IntArray', () {
    setUp(() {});

    test('average', () {
      Int1D s1 = new Int1D([1, 5]);
      expect(s1.average([1, 2]), 3.6666666666666665);
      s1 = new Int1D([2, 6]);
      expect(s1.average([1, 2]), 4.6666666666666667);
      s1 = new Int1D([3, 7]);
      expect(s1.average([1, 2]), 5.6666666666666667);
      s1 = new Int1D([4, 8]);
      expect(s1.average([1, 2]), 6.6666666666666667);
    });

    test('to2D', () {
      Int1D s1 = new Int1D([1, 5]);
      expect(s1.to2D(), [
        [1, 5]
      ]);
      expect(s1.transpose, [
        [1],
        [5]
      ]);
      expect(s1.to2D().shape, idx2D(1, 2));
      expect(s1.transpose.shape, idx2D(2, 1));
    });

    test('covariance', () {
      final s1 = int1D([1, 5]);
      // TODO
    });
  });
}
