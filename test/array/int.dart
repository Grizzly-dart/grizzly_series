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
        [5],
      ]);
      expect(s1.to2D().shape, idx2D(1, 2));
      expect(s1.transpose.shape, idx2D(2, 1));
    });

    test('covariance', () {
      final s1 = int1D([1, 5]);
      // TODO
    });

    test('exp', () {
      {
        final x = double1D([-0.1, -0.2, -0.3, -0.4]);
        final y = (x.exp + 1).log;
        expect(y, [
          0.6443966600735709,
          0.5981388693815918,
          0.554355244468527,
          0.5130152523999526
        ]);
      }
      {
        final x = double1D([0.1, 0.2, 0.3, 0.4]);
        final y = -x.toDouble + (x.exp + 1).log;
        expect(y, [
          0.644396660073571,
          0.5981388693815917,
          0.5543552444685271,
          0.5130152523999526
        ]);
      }
    });
  });
}
