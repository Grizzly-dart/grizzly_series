library grizzly.series.array2d;

// TODO import 'dart:math' as math;
import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:grizzly_scales/grizzly_scales.dart';
import 'package:grizzly_series/grizzly_series.dart';

part 'index.dart';
part 'double_array2d.dart';
part 'int_array2d.dart';
part 'numeric.dart';

abstract class Array2D<E> implements Array2DFixBase<E>, Iterable<Array<E>> {
  void addRow(Iterable<E> row);

  void addRowScalar(E v);
}

abstract class Array2DFix<E>
    implements Array2DFixBase<E>, Iterable<ArrayFix<E>> {
  operator []=(int i, Array<E> val);

  void assign(int index, Iterable<E> v, {bool column: false});

  void assignScalar(int index, E v, {bool column: false});

  void set(E v);

  void clip({E min, E max});
}

abstract class Array2DFixBase<E> implements Array2DBase<E> {
  operator []=(int i, Array<E> val);

  void assign(int index, Iterable<E> v, {bool column: false});

  void assignScalar(int index, E v, {bool column: false});

  void set(E v);

  void clip({E min, E max});
}

abstract class Array2DView<E>
    implements Array2DBase<E>, Iterable<ArrayView<E>> {}

abstract class Array2DBase<E> {
  Array2D<E> makeFrom(Iterable<Iterable<E>> newData);

  /// Number of rows in the array
  int get numRows;

  /// Number of columns in the array
  int get numCols;

  /// Shape of the array
  Index2D get shape;

  ArrayView<E> operator [](int i);

  Array<E> getRow(int r);

  E get min;

  Array<E> get minX;

  Array<E> get minY;

  E get max;

  Array<E> get maxX;

  Array<E> get maxY;

  Extent<E> get extent;

  Index2D get argMin;

  Index2D get argMax;

  IntPair<Array<E>> pairAt(int index);

  Iterable<IntPair<Array<E>>> enumerate();

  /// Returns a new  [Array] containing first [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Array2D<E> head([int count = 10]);

  /// Returns a new  [Array] containing last [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Array2D<E> tail([int count = 10]);

  /// Returns a new  [Array] containing random [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  Array2D<E> sample([int count = 10]);

  Array2D<E> get transpose;
}
