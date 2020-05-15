part of grizzly.series;

abstract class IntSeriesViewMixin<LT> implements NumericSeriesView<LT, int> {
  IntSeries<LT> toSeries() => IntSeries(data, name: name, labels: labels);

  IntSeriesView<NLT> makeView<NLT>(Iterable<int> data,
          {dynamic name, Iterable<NLT> labels}) =>
      IntSeriesView<NLT>(data, name: name, labels: labels);

  IntSeries<NLT> make<NLT>(Iterable<int> data,
          {dynamic name, Iterable<NLT> labels}) =>
      IntSeries<NLT>(data, name: name, labels: labels);

  @override
  Int1D makeValueArraySized(int size) => Int1D.sized(size);

  @override
  Int1D makeValueArray(Iterable<int> data) => Int1D(data);

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
      DoubleSeries(data.log, name: name, labels: labels);

  NumericSeries<LT, double> get log10 =>
      DoubleSeries(data.log10, name: name, labels: labels);

  NumericSeries<LT, double> logN(num n) =>
      DoubleSeries(data.logN(n), name: name, labels: labels);

  NumericSeries<LT, double> get exp =>
      DoubleSeries(data.exp, name: name, labels: labels);

  NumericSeries<LT, double> get abs =>
      DoubleSeries.fromNums(data.abs(), name: name, labels: labels);

  DoubleSeries<LT> toDouble() =>
      DoubleSeries<LT>(data.toDouble(), name: name, labels: labels.toList());

  IntSeries<LT> toInt() =>
      IntSeries<LT>(data, name: name, labels: labels.toList());

  @override
  IntSeries<LT> operator +(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */ other) {
    if (other is int) {
      return IntSeries<LT>(data + other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] + other[label];
        }
      }
      return IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return IntSeries<LT>(data + other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  IntSeries<LT> operator -(
      /* int | Iterable<int> | NumericSeriesView<LT, int> | Numeric1DView<int> */ other) {
    if (other is int) {
      return IntSeries<LT>(data - other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] - other[label];
        }
      }
      return IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return IntSeries<LT>(data - other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  IntSeries<LT> operator *(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */ other) {
    if (other is int) {
      return IntSeries<LT>(data * other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] * other[label];
        }
      }
      return IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return IntSeries<LT>(data * other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  DoubleSeries<LT> operator /(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */ other) {
    if (other is num) {
      return DoubleSeries<LT>(data / other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, num>) {
      final list = List<double>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] / other[label];
        }
      }
      return DoubleSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<num>) {
      return DoubleSeries<LT>(data / other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  IntSeries<LT> operator ~/(
      /* int | Iterable<int> | NumericSeriesView<int> | Numeric1DView<int> */ other) {
    if (other is num) {
      return IntSeries<LT>(data ~/ other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, num>) {
      final list = List<int>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] ~/ other[label];
        }
      }
      return IntSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<num>) {
      return IntSeries<LT>(data ~/ other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  IntSeries<LT> operator -() => IntSeries.copy(this, name: name)..negate();

  @override
  BoolSeries<LT> operator >=(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return BoolSeries<LT>(data >= other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] >= other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return BoolSeries<LT>(data >= other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator >(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return BoolSeries<LT>(data > other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] > other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return BoolSeries<LT>(data > other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator <=(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return BoolSeries<LT>(data <= other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] <= other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return BoolSeries<LT>(data <= other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator <(
      /* E | Iterable<E> | NumericSeriesView<E> | Numeric1DView<E> */ other) {
    if (other is int) {
      return BoolSeries<LT>(data < other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, int>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] < other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<int>) {
      return BoolSeries<LT>(data < other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }
}
