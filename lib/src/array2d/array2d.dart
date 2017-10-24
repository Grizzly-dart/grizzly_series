library grizzly.series.array2d;

import 'dart:math' as math;
import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:grizzly_scales/grizzly_scales.dart';
import 'package:grizzly_series/grizzly_series.dart';

part 'int/int_array2d.dart';
part 'int/int_fix_array2d.dart';
part 'int/int_view_array2d.dart';
part 'int/int_axis.dart';

part 'double/double_array2d.dart';
part 'double/double_fix_array2d.dart';
part 'double/double_axis.dart';
part 'double/double_view_array2d.dart';

part 'bool/bool_array2d.dart';
part 'bool/bool_fix_array2d.dart';
part 'bool/bool_axis.dart';
part 'bool/bool_view_array2d.dart';

part 'string/string_array2d.dart';
part 'string/string_fix_array2d.dart';
part 'string/string_axis.dart';
part 'string/string_view_array2d.dart';

part 'index.dart';
part 'double_array2d.dart';
part 'numeric.dart';

Double2D array2D(Iterable<Iterable<num>> matrix) =>
    new Double2D.fromNum(matrix);

Int2D int2D(Iterable<Iterable<int>> matrix) => new Int2D(matrix);

abstract class Array2D<E> implements Iterable<Array<E>>, Array2DFix<E> {
  ArrayFix<E> operator [](int i);

  Axis2D<E> get row;

  Axis2D<E> get col;

  void add(Iterable<E> row);

  void addScalar(E v);

  void insert(int index, Iterable<E> row);

  void insertScalar(int index, E v);

  Array<E> firstWhere(covariant bool test(Array<E> element),
      {covariant Array<E> orElse()});

  Array<E> lastWhere(covariant bool test(Array<E> element),
      {covariant Array<E> orElse()});

  Array<E> reduce(
      covariant Array<E> combine(ArrayView<E> value, ArrayView<E> element));
}

abstract class Array2DFix<E> implements Iterable<ArrayFix<E>>, Array2DView<E> {
  ArrayFix<E> operator [](int i);

  operator []=(int i, ArrayView<E> val);

  Axis2DFix<E> get row;

  Axis2DFix<E> get col;

  void set(E v);

  void assign(Array2DView<E> other);

  Array2DView<E> get view;

  Array2DFix<E> get fixed;

  ArrayFix<E> firstWhere(covariant bool test(ArrayFix<E> element),
      {covariant ArrayFix<E> orElse()});

  ArrayFix<E> lastWhere(covariant bool test(ArrayFix<E> element),
      {covariant ArrayFix<E> orElse()});

  ArrayFix<E> reduce(
      covariant ArrayFix<E> combine(ArrayView<E> value, ArrayView<E> element));
}

abstract class Array2DView<E> implements Iterable<ArrayView<E>> {
  Array2DView<E> makeView(Iterable<Iterable<E>> newData);

  Array2DFix<E> makeFix(Iterable<Iterable<E>> newData);

  Array2D<E> make(Iterable<Iterable<E>> newData);

  /// Number of rows in the array
  int get numCols;

  /// Number of columns in the array
  int get numRows;

  /// Shape of the array
  Index2D get shape;

  bool get isSquare;

  ArrayView<E> operator [](int i);

  Axis2DView<E> get row;

  Axis2DView<E> get col;

  E get min;

  E get max;

  Index2D get argMin;

  Index2D get argMax;

  // TODO IntPair<Array<E>> pairAt(int index);

  // TODO Iterable<IntPair<Array<E>>> enumerate();

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

  Array<E> get diagonal;

  Array2DView<E> get view;

  IntSeries<E> valueCounts(
      {bool sortByValue: false,
      bool ascending: false,
      bool dropNull: false,
      dynamic name});
}

abstract class Axis2D<E> implements Axis2DFix<E> {
  void add(Iterable<E> col);

  void addScalar(E v);

  void insert(int index, Iterable<E> col);

  void insertScalar(int index, E v);
}

abstract class Axis2DFix<E> implements Axis2DView<E> {
  ArrayFix<E> operator [](int r);

  operator []=(int index, Iterable<E> v);

  // TODO set?

  //TODO
}

abstract class Axis2DView<E> {
  ArrayView<E> operator [](int r);

  int get length;

  int get otherDLength;

  // TODO pairAt

  // TODO enumerate

  Array<E> get min;

  Array<E> get max;

  // TODO slice?
}
