library grizzly.series.primitives;

/// Data structure to hold a key-value pair
class Pair<KT, VT> {
	final KT key;

	final VT value;

	Pair(this.key, this.value);

	String toString() => '$key:$value';
}

class IntPair<VT> extends Pair<int, VT> {
	IntPair(int key, VT value): super(key, value);
}

Pair<KT, VT> pair<KT, VT>(KT key, VT value) => new Pair<KT, VT>(key, value);

IntPair<VT> intPair<VT>(int key, VT value) => new IntPair(key, value);

class Extent<E> {
	final E lower;

	final E upper;

	const Extent(this.lower, this.upper);

	List<E> toList() => <E>[lower, upper];

	static Extent<E> find<O, E extends Comparable<E>>(
			Iterable<O> data, E mapper(O o)) {
		E min;
		E max;
		for (O o in data) {
			final E d = mapper(o);

			if (d == null) continue;

			if (max == null || d.compareTo(max) > 0) max = d;
			if (min == null || d.compareTo(min) < 0) min = d;
		}
		return new Extent<E>(min, max);
	}

	String toString() => '[$lower, $upper]';
}