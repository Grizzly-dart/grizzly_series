library grizzly.series.array;

import 'dart:math' as math;
import 'dart:collection';
import 'dart:typed_data';
import 'package:meta/meta.dart';
import 'package:grizzly_scales/grizzly_scales.dart';
import 'package:grizzly_series/grizzly_series.dart';

part 'int/int_array.dart';
part 'int/int_fix_array.dart';
part 'int/int_view_array.dart';

part 'double/double_array.dart';
part 'double/double_view_array.dart';
part 'double/double_fix_array.dart';

part 'index.dart';
part 'numeric.dart';
part 'sample.dart';

//TODO DateTime
//TODO String
//TODO bool

/// A mutable 1 dimensional array of element [E]
abstract class Array<E> implements ArrayFix<E> {
  void add(E a);

  void insert(int index, E a);
}

/// A mutable 1 dimensional fixed sized array of element [E]
abstract class ArrayFix<E> implements ArrayView<E> {
  operator []=(int i, E val);

  // TODO [Index] based indexing

  void clip({E min, E max});

  ArrayFix<E> get fixed;
}

/// A read-only 1 dimensional array of element [E]
abstract class ArrayView<E> implements Iterable<E> {
  Array<E> makeFrom(Iterable<E> newData);

  Index1D get shape;

  E operator [](int i);

  Array<E> slice(int start, [int end]);

  E get min;

  E get max;

  Extent<E> get extent;

  int get argMin;

  int get argMax;

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

  Array2D<E> to2D();

  Array2D<E> repeat({int repeat: 1, bool transpose: false});

  Array2D<E> get transpose;

  // TODO

  ArrayView<E> get view;
}
