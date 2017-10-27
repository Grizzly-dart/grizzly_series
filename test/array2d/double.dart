import 'package:grizzly_series/grizzly_series.dart';
import 'package:test/test.dart';

void main() {
  group('DoubleArray2D', () {
    setUp(() {});

    test('multiply', () {
      final res = array2D([
            [3.0, 1.0],
            [1.0, 2.0]
          ]) *
          array2D([
            [2.0],
            [3.0]
          ]);

      expect(res, [
        [9.0],
        [8.0],
      ]);
    });
  });
}
