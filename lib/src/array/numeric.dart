part of grizzly.series.array;

/// A mutable 1 dimensional array of numbers
abstract class NumericArray<E extends num>
    implements Array<E>, NumericArrayFix<E> {
  NumericArrayFix<E> get fixed;
}

/// A mutable 1 dimensional fixed sized array of numbers
abstract class NumericArrayFix<E extends num>
    implements ArrayFix<E>, ReadOnlyNumericArray<E> {
  NumericArray<E> addition(/* E | Iterable<E> */ other, {bool self: false});

  NumericArray<E> subtract(/* E | Iterable<E> */ other, {bool self: false});

  NumericArray<E> multiple(/* E | Iterable<E> */ other, {bool self: false});

  NumericArray<double> divide(/* E | Iterable<E> */ other, {bool self: false});

  NumericArray<int> truncDiv(/* E | Iterable<E> */ other, {bool self: false});

  ReadOnlyNumericArray<E> get view;
}

/// A read-only 1 dimensional array of numbers
abstract class ReadOnlyNumericArray<E extends num> implements ReadOnlyArray<E> {
  E get ptp;

  double get mean;

  E get sum;

  E get prod;

  double average(Iterable<num> weights);

  NumericArray<E> get cumsum;

  NumericArray<E> get cumprod;

  double get variance;

  double get std;

  NumericArray<E> operator +(/* E | Iterable<E> */ other);

  NumericArray<E> addition(/* E | Iterable<E> */ other);

  NumericArray<E> operator -(/* E | Iterable<E> */ other);

  NumericArray<E> subtract(/* E | Iterable<E> */ other);

  NumericArray<E> operator *(/* E | Iterable<E> */ other);

  NumericArray<E> multiple(/* E | Iterable<E> */ other);

  NumericArray<double> operator /(/* E | Iterable<E> */ other);

  NumericArray<double> divide(/* E | Iterable<E> */ other);

  NumericArray<int> operator ~/(/* E | Iterable<E> */ other);

  NumericArray<int> truncDiv(/* E | Iterable<E> */ other);

  // TODO

  Numeric2DArray<E> transpose();

  E dot(NumericArray other);
}
