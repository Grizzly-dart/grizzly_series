library grizzly.series.array;

import 'dart:collection';
import 'dart:typed_data';

part 'num_array.dart';

class Extent<E> {
	final E lower;

	final E upper;

	Extent(this.lower, this.upper);
}

abstract class Array<E> implements Iterable<E> {
	E min();

	E max();

	Extent<E> extent();

	int argMin();

	int argMax();

	void clip({E min, E max});
}

abstract class NumericArray<E extends num> implements Array<E> {
	E ptp();

	double mean();

	E sum();

	E prod();

	NumericArray<E> cumsum();

	NumericArray<E> cumprod();

	double variance();

	double std();
}