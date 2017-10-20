part of grizzly.series.array;

/// A mutable 1 dimensional array of numbers
abstract class Numeric1D<E extends num>
    implements Array<E>, Numeric1DFix<E> {
  Numeric1D<E> addition(/* E | Iterable<E> */ other, {bool self: false});

  Numeric1D<E> subtract(/* E | Iterable<E> */ other, {bool self: false});

  Numeric1D<E> multiply(/* E | Iterable<E> */ other, {bool self: false});

  Numeric1D<double> divide(/* E | Iterable<E> */ other, {bool self: false});

  Numeric1D<int> truncDiv(/* E | Iterable<E> */ other, {bool self: false});
}

/// A mutable 1 dimensional fixed sized array of numbers
abstract class Numeric1DFix<E extends num>
    implements ArrayFix<E>, Numeric1DView<E> {
  Numeric1DFix<E> operator +(/* E | Iterable<E> */ other);

  Numeric1DFix<E> addition(/* E | Iterable<E> */ other, {bool self: false});

  Numeric1DFix<E> operator -(/* E | Iterable<E> */ other);

  Numeric1DFix<E> subtract(/* E | Iterable<E> */ other, {bool self: false});

  Numeric1DFix<E> operator *(/* E | Iterable<E> */ other);

  Numeric1DFix<E> multiply(/* E | Iterable<E> */ other, {bool self: false});

  Numeric1DFix<double> operator /(/* E | Iterable<E> */ other);

  Numeric1DFix<double> divide(/* E | Iterable<E> */ other,
      {bool self: false});

  Numeric1DFix<int> operator ~/(/* E | Iterable<E> */ other);

  Numeric1DFix<int> truncDiv(/* E | Iterable<E> */ other,
      {bool self: false});
}

/// A read-only 1 dimensional array of numbers
abstract class Numeric1DView<E extends num> implements ArrayView<E> {
  E get ptp;

  double get mean;

  E get sum;

  E get prod;

  double average(Iterable<num> weights);

  Numeric1DView<E> get cumsum;

  Numeric1DView<E> get cumprod;

  double get variance;

  double get std;

  Numeric1DFix<E> operator +(/* E | Iterable<E> */ other);

  Numeric1DFix<E> addition(/* E | Iterable<E> */ other);

  Numeric1DFix<E> operator -(/* E | Iterable<E> */ other);

  Numeric1DFix<E> subtract(/* E | Iterable<E> */ other);

  Numeric1DFix<E> operator *(/* E | Iterable<E> */ other);

  Numeric1DFix<E> multiply(/* E | Iterable<E> */ other);

  Numeric1DFix<double> operator /(/* E | Iterable<E> */ other);

  Numeric1DFix<double> divide(/* E | Iterable<E> */ other);

  Numeric1DFix<int> operator ~/(/* E | Iterable<E> */ other);

  Numeric1DFix<int> truncDiv(/* E | Iterable<E> */ other);

  E dot(Iterable<num> other);

  Double1D get toDouble;

  double cov(Numeric1DView y);

  Double1D covMatrix(Numeric2DView y);

  double corrcoef(Numeric1DView y);

  Double1D corrcoefMatrix(Numeric2DView y);
}
