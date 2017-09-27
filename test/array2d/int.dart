import 'package:grizzly_series/grizzly_series.dart';
import 'package:test/test.dart';

void main() {
  group('IntArray2D', () {
    setUp(() {});

    test('construct', () {
      final s1 = new Int2DArray.from([
        [1, 2, 3, 4],
        [5, 6, 7, 8]
      ]);

      expect(s1.shape, idx2D(2, 4));
      expect(s1.min, 1);
      expect(s1.max, 8);

      expect(s1[0], new IntArray.from([1, 2, 3, 4]));
      expect(s1[1], new IntArray.from([5, 6, 7, 8]));
    });

    test('average', () {
      final s1 = new Int2DArray.from([
        [15, 2],
        [5, 6]
      ]);
      expect(
          s1.average([
            [7, 2],
            [3, 4]
          ]),
          9.25);
    });

    test('transpose', () {
      final s1 = new Int2DArray.from([
        [15, 2],
        [5, 6]
      ]);
      expect(s1.transpose(), [
        [15, 5],
        [2, 6]
      ]);
    });
  });
}
