part of grizzly.series;

abstract class IntSeriesViewMixin<LT> implements NumericSeriesView<LT, int> {
  IntSeries<LT> toSeries() => new IntSeries(data, name: name, labels: labels);

  IntSeriesView<NLT> makeView<NLT>(Iterable<int> data,
          {dynamic name, Iterable<NLT> labels}) =>
      new IntSeriesView<NLT>(data, name: name, labels: labels);

  IntSeries<NLT> make<NLT>(Iterable<int> data,
          {dynamic name, Iterable<NLT> labels}) =>
      new IntSeries<NLT>(data, name: name, labels: labels);

  @override
  Int1D makeValueArraySized(int size) => new Int1D.sized(size);

  @override
  Int1D makeValueArray(Iterable<int> data) => new Int1D(data);

  @override
  int compareValue(int a, int b) => a.compareTo(b);

  int get max => data.max;

  int get min => data.min;

  int get sum => data.sum;

  int get prod => data.prod;

  double average(Iterable<num> weights) => data.average(weights);

  double get variance => data.variance;

  double get std => data.std;

  NumericSeries<LT, double> get log =>
      new DoubleSeries(data.log, name: name, labels: labels);

  NumericSeries<LT, double> get log10 =>
      new DoubleSeries(data.log10, name: name, labels: labels);

  NumericSeries<LT, double> logN(num n) =>
      new DoubleSeries(data.logN(n), name: name, labels: labels);

  NumericSeries<LT, double> get exp =>
      new DoubleSeries(data.exp, name: name, labels: labels);

  NumericSeries<LT, double> get abs =>
      new DoubleSeries.fromNums(data.abs(), name: name, labels: labels);

  DoubleSeries<LT> toDouble() => new DoubleSeries<LT>(data.toDouble(),
      name: name, labels: labels.toList());

  IntSeries<LT> toInt() =>
      new IntSeries<LT>(data, name: name, labels: labels.toList());

  @override
  IntSeries<LT> operator +(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */ other) {
    if (other is int) {
      return new IntSeries<LT>(data + other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = new List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] + other[label];
        }
      }
      return new IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return new IntSeries<LT>(data + other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  IntSeries<LT> operator -(
      /* int | Iterable<int> | NumericSeriesView<LT, int> | Numeric1DView<int> */ other) {
    if (other is int) {
      return new IntSeries<LT>(data - other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = new List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] - other[label];
        }
      }
      return new IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return new IntSeries<LT>(data - other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  IntSeries<LT> operator *(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */ other) {
    if (other is int) {
      return new IntSeries<LT>(data * other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = new List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] * other[label];
        }
      }
      return new IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return new IntSeries<LT>(data * other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  DoubleSeries<LT> operator /(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */ other) {
    if (other is num) {
      return new DoubleSeries<LT>(data / other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, num>) {
      final list = new List<double>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] / other[label];
        }
      }
      return new DoubleSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<num>) {
      return new DoubleSeries<LT>(data / other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  IntSeries<LT> operator ~/(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */ other) {
    if (other is num) {
      return new IntSeries<LT>(data ~/ other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, num>) {
      final list = new List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] ~/ other[label];
        }
      }
      return new IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<num>) {
      return new IntSeries<LT>(data ~/ other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  IntSeries<LT> operator -() => new IntSeries.copy(this, name: name)..negate();

  @override
  BoolSeries<LT> operator >=(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return new BoolSeries<LT>(data >= other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] >= other[label];
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return new BoolSeries<LT>(data >= other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator >(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return new BoolSeries<LT>(data > other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] > other[label];
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return new BoolSeries<LT>(data > other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator <=(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return new BoolSeries<LT>(data <= other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] <= other[label];
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return new BoolSeries<LT>(data <= other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator <(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return new BoolSeries<LT>(data < other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] < other[label];
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return new BoolSeries<LT>(data < other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }
}
