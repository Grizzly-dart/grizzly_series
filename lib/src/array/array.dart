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

part 'bool/bool_array.dart';
part 'bool/bool_fix_array.dart';
part 'bool/bool_view_array.dart';

part 'index.dart';
part 'numeric.dart';
part 'sample.dart';

//TODO DateTime
//TODO String

/// Creates a 1-dimensional array of integers from given [data]
Int1D int1D(/* Iterable<num> | double | int | Index1D */ data) {
  if (data is Iterable<int>) {
    return new Int1D(data);
  } else if (data is double) {
    return new Int1D.single(data.toInt());
  } else if (data is int) {
    return new Int1D.sized(data);
  } else if (data is Index1D) {
    return new Int1D.sized(data.x);
  } else {
    throw new ArgumentError.value(data, 'data', 'Invalid value!');
  }
}

/// Creates a 1-dimensional array of double from given [data]
Double1D double1D(/* Iterable<num> | double | int | Index1D */ data) {
  if (data is Iterable<num>) {
    return new Double1D.fromNum(data);
  } else if (data is double) {
    return new Double1D.single(data);
  } else if (data is int) {
    return new Double1D.sized(data);
  } else if (data is Index1D) {
    return new Double1D.sized(data.x);
  } else {
    throw new ArgumentError.value(data, 'data', 'Invalid value!');
  }
}

/// Creates a 1-dimensional array of double from given [data]
Double1D array(/* Iterable<num> | double | int | Index1D */ data) {
  if (data is Iterable<num>) {
    return new Double1D.fromNum(data);
  } else if (data is double) {
    return new Double1D.single(data);
  } else if (data is int) {
    return new Double1D.sized(data);
  } else if (data is Index1D) {
    return new Double1D.sized(data.x);
  } else {
    throw new ArgumentError.value(data, 'data', 'Invalid value!');
  }
}

/// A mutable 1 dimensional array of element [E]
abstract class Array<E> implements ArrayFix<E> {
  void add(E a);

  void insert(int index, E a);
}

/// A mutable 1 dimensional fixed sized array of element [E]
abstract class ArrayFix<E> implements ArrayView<E> {
  operator []=(int i, E val);

  // TODO [Index] based indexing

  ArrayFix<E> get fixed;
}

/// A read-only 1 dimensional array of element [E]
abstract class ArrayView<E> implements Iterable<E> {
  ArrayView<E> makeView(Iterable<E> newData);

  ArrayFix<E> makeFix(Iterable<E> newData);

  Array<E> makeArray(Iterable<E> newData);

  Index1D get shape;

  E operator [](int i);

  Array<E> slice(int start, [int end]);

  E get min;

  E get max;

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

  ArrayView<E> get view;

  IntSeries<E> valueCounts(
      {bool sortByValue: false,
      bool ascending: false,
      bool dropNull: false,
      dynamic name});
}
