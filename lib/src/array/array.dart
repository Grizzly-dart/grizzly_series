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

abstract class Array<E> implements Iterable<E> {
  Array<E> makeFrom(Iterable<E> newData);

  E min();

  E max();

  Extent<E> extent();

  int argMin();

  int argMax();

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
  E ptp();

  double mean();

  E sum();

  E prod();

  NumericArray<E> cumsum();

  NumericArray<E> cumprod();

  double variance();

  double std();
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
