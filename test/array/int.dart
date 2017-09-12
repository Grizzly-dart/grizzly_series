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
	});
}
