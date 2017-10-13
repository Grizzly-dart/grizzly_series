part of grizzly.series.array2d;

abstract class Numeric2DArray<E extends num> implements Array2D<E> {
  // TODO E get ptp;

  double get mean;

  DoubleArray get meanRow;

  DoubleArray get meanCol;

  // TODO E get sum;

  // TODO E get prod;

  double average(Iterable<Iterable<num>> weights);

  DoubleArray averageRow(Iterable<num> weights);

  DoubleArray averageCol(Iterable<num> weights);

// TODO NumericArray<E> get cumsum;

// TODO NumericArray<E> get cumprod;

// TODO double get variance;

// TODO double get std;
}
