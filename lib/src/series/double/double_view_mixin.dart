part of grizzly.series;

abstract class DoubleSeriesViewMixin<LT>
    implements NumericSeriesView<LT, double> {
  DoubleSeries<LT> toSeries() => DoubleSeries(data, name: name, labels: labels);

  DoubleSeriesView<IIT> makeView<IIT>(Iterable<double> data,
          {dynamic name, Iterable<IIT> labels}) =>
      DoubleSeriesView(data, name: name, labels: labels);

  DoubleSeries<IIT> make<IIT>(Iterable<double> data,
          {dynamic name, Iterable<IIT> labels}) =>
      DoubleSeries<IIT>(data, name: name, labels: labels);

  @override
  Double1D makeValueArraySized(int size) => Double1D.sized(size);

  @override
  Double1D makeValueArray(Iterable<double> data) => Double1D(data);

  @override
  int compareValue(double a, double b) => a.compareTo(b);

  double get max => data.max;

  double get min => data.min;

  double get sum => data.sum;

  double get prod => data.prod;

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
      DoubleSeries(data.abs(), name: name, labels: labels);

  DoubleSeries<LT> toDouble() =>
      DoubleSeries<LT>(data.toDouble(), name: name, labels: labels.toList());

  IntSeries<LT> toInt() =>
      IntSeries<LT>.fromNums(data, name: name, labels: labels.toList());

  @override
  DoubleSeries<LT> operator +(
      /* double | Iterable<double> | NumericSeriesView<double> | Numeric1DView<double> */ other) {
    if (other is double) {
      return DoubleSeries<LT>(data + other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = List<double>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] + other[label];
        }
      }
      return DoubleSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<double>) {
      return DoubleSeries<LT>(data + other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  DoubleSeries<LT> operator -(
      /* double | Iterable<double> | NumericSeriesView<double> | Numeric1DView<double> */ other) {
    if (other is double) {
      return DoubleSeries<LT>(data - other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = List<double>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] - other[label];
        }
      }
      return DoubleSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<double>) {
      return DoubleSeries<LT>(data - other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  DoubleSeries<LT> operator *(
      /* double | Iterable<double> | NumericSeriesView<double> | Numeric1DView<double> */ other) {
    if (other is double) {
      return DoubleSeries<LT>(data * other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = List<double>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] * other[label];
        }
      }
      return DoubleSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<double>) {
      return DoubleSeries<LT>(data * other, name: name, labels: labels);
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
  DoubleSeries<LT> operator -() =>
      DoubleSeries.copy(this, name: name)..negate();

  @override
  BoolSeriesBase<LT> operator >=(other) {
    if (other is double) {
      return BoolSeries<LT>(data >= other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] >= other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<double>) {
      return BoolSeries<LT>(data >= other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator >(other) {
    if (other is double) {
      return BoolSeries<LT>(data > other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] > other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<double>) {
      return BoolSeries<LT>(data > other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator <=(other) {
    if (other is double) {
      return BoolSeries<LT>(data <= other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] <= other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<double>) {
      return BoolSeries<LT>(data <= other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator <(other) {
    if (other is double) {
      return BoolSeries<LT>(data < other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] < other[label];
        }
      }
      return BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is Iterable<double>) {
      return BoolSeries<LT>(data < other, name: name, labels: labels);
    }
    throw UnimplementedError();
  }
}
