library grizzly.series.array;

import 'dart:math' as math;
import 'dart:collection';
import 'dart:typed_data';
import 'package:grizzly_scales/grizzly_scales.dart';
import 'package:grizzly_series/grizzly_series.dart';

part 'int_array.dart';
part 'double_array.dart';

//TODO DateTime
//TODO String
//TODO bool

abstract class Index {
  /// Number of dimensions
  int get dim;

  /// Get index at dimension [d]
  int operator[](int d);

  List<int> toList();
}

class Index1D {
  final int x;

  const Index1D(this.x);

  int get dim => 1;

  int operator[](int d) {
    if(d >= dim) throw new RangeError.range(d, 0, 0, 'd', 'Out of range!');
    return x;
  }

  List<int> toList() => <int>[x];

  bool operator==(other) {
    if(other is! Index1D) return false;

    if(other is Index1D) {
      return other.x == this.x;
    }

    return false;
  }
}

Index1D idx1D(int x) => new Index1D(x);

abstract class Array<E> implements Iterable<E> {
  Array<E> makeFrom(Iterable<E> newData);

  Index1D get shape;

  E operator[](int i);

  operator[]=(int i, E val);

  // TODO [Index] based indexing

  E get min;

  E get max;

  Extent<E> get extent;

  int get argMin;

  int get argMax;

  void clip({E min, E max});

  IntPair<E> pairAt(int index);

  Iterable<IntPair<E>> enumerate();

  /// Returns a new  [Array] containing first [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Array<E> head([int count = 10]);

  /// Returns a new  [Array] containing last [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Array<E> tail([int count = 10]);

  /// Returns a new  [Array] containing random [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Array<E> sample([int count = 10]);
}

abstract class NumericArray<E extends num> implements Array<E> {
  E get ptp;

  double get mean;

  E get sum;

  E get prod;

  NumericArray<E> get cumsum;

  NumericArray<E> get cumprod;

  double get variance;

  double get std;
}

final math.Random _rand = new math.Random();

List<E> _sample<E>(List<E> population, int k) {
  final int n = population.length;

  if (k < 0 || k > n)
    throw new ArgumentError.value(
        k, 'k', 'Must be between 0 and population.length');

  final samples = new List<E>(k);

  if(n < 1000) {
    final unpicked = new List<E>.from(population);
    for(int i = 0; i < k; i++) {
      final sampleIdx = _rand.nextInt(n - i);
      samples[i] = unpicked[sampleIdx];
      unpicked[sampleIdx] = unpicked[n-i-1];
    }
  } else {
    final picked = new SplayTreeSet<int>();
    for(int i = 0; i < k; i++) {
      final int sampleIdx = () {
        int newIdx;
        do {
          newIdx = _rand.nextInt(n);
        } while(picked.contains(newIdx));
        return newIdx;
      }();
      picked.add(sampleIdx);
      samples[i] = population[sampleIdx];
    }
  }

  return samples;
}
