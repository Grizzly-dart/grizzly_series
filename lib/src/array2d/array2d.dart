library grizzly.series.array2d;

// TODO import 'dart:math' as math;
import 'dart:collection';
import 'package:grizzly_scales/grizzly_scales.dart';
import 'package:grizzly_series/grizzly_series.dart';

part 'double_array2d.dart';
part 'int_array2d.dart';

class Index2D implements Index {
  final int x;

  final int y;

  const Index2D(this.x, this.y);

  int get dim => 2;

  int operator [](int d) {
    if (d >= dim)
      throw new RangeError.range(d, 0, dim - 1, 'd', 'Out of range!');
    if (d == 0) return x;
    return y;
  }

  List<int> toList() => <int>[x, y];

  bool operator ==(other) {
    if (other is! Index2D) return false;

    if (other is Index2D) {
      return other.x == this.x && other.y == this.y;
    }

    return false;
  }

  Index2D makeWithY(int y) => new Index2D(x, y);

  Index2D makeWithX(int x) => new Index2D(x, y);
}

Index2D idx2D(int x, int y) => new Index2D(x, y);

abstract class Array2D<E> implements Iterable<Array<E>> {
  Array2D<E> makeFrom(Iterable<Iterable<E>> newData);

  /// Number of rows in the array
  int get numRows;

  /// Number of columns in the array
  int get numCols;

  /// Shape of the array
  Index2D get shape;

  ReadOnlyArray<E> operator [](int i);

  operator []=(int i, Array<E> val);

  Array<E> getRow(int r);

  void addRow(Iterable<E> row);

  void addRowScalar(E v);

  void assign(int index, Iterable<E> v, {bool column: false});

  void assignScalar(int index, E v, {bool column: false});

  void set(E v);

  E get min;

  Array<E> get minX;

  Array<E> get minY;

  E get max;

  Array<E> get maxX;

  Array<E> get maxY;

  Extent<E> get extent;

  Index2D get argMin;

  Index2D get argMax;

  void clip({E min, E max});

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

abstract class Numeric2DArray<E extends num> implements Array2D<E> {
  // TODO E get ptp;

  double get mean;

  DoubleArray get meanX;

  DoubleArray get meanY;

  // TODO E get sum;

  // TODO E get prod;

  double average(Iterable<Iterable<num>> weights);

  DoubleArray averageX(Iterable<num> weights);

  DoubleArray averageY(Iterable<num> weights);

  // TODO NumericArray<E> get cumsum;

  // TODO NumericArray<E> get cumprod;

  // TODO double get variance;

  // TODO double get std;
}
