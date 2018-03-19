part of grizzly.series;

abstract class DoubleSeriesViewMixin<LT>
    implements NumericSeriesView<LT, double> {
  DoubleSeries<LT> toSeries() =>
      new DoubleSeries(data, name: name, labels: labels);

  DoubleSeriesView<IIT> makeView<IIT>(
          /* Iterable<int> | IterView<int> */ data,
          {dynamic name,
          Iterable<IIT> labels}) =>
      new DoubleSeriesView(data, name: name, labels: labels);

  DoubleSeries<IIT> make<IIT>(/* Iterable<String> | IterView<String> */ data,
          {dynamic name, Iterable<IIT> labels}) =>
      new DoubleSeries<IIT>(data, name: name, labels: labels);

  @override
  Double1D makeValueArraySized(int size) => new Double1D.sized(size);

  @override
  Double1D makeValueArray(Iterable<double> data) => new Double1D(data);

  @override
  int compareVT(double a, double b) => a.compareTo(b);

  double get max => data.max;

  double get min => data.min;

  double get sum => data.sum;

  double get prod => data.prod;

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
      new DoubleSeries(data.abs, name: name, labels: labels);

  DoubleSeries<LT> get toDouble =>
      new DoubleSeries<LT>(data.toDouble, name: name, labels: labels.toList());

  IntSeries<LT> get toInt =>
      new IntSeries<LT>(data, name: name, labels: labels.toList());

  @override
  DoubleSeries<LT> operator +(
      /* double | IterView<double> | NumericSeriesView<double> | Numeric1DView<double> */ other) {
    if (other is double) {
      return new DoubleSeries<LT>(data + other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = new List<double>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] + other[label];
        } else {
          list[i] = data[i];
        }
      }
      return new DoubleSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<double>) {
      return new DoubleSeries<LT>(data + other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  DoubleSeries<LT> operator -(
      /* double | IterView<double> | NumericSeriesView<double> | Numeric1DView<double> */ other) {
    if (other is double) {
      return new DoubleSeries<LT>(data - other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = new List<double>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] - other[label];
        } else {
          list[i] = data[i];
        }
      }
      return new DoubleSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<double>) {
      return new DoubleSeries<LT>(data - other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  DoubleSeries<LT> operator *(
      /* double | IterView<double> | NumericSeriesView<double> | Numeric1DView<double> */ other) {
    if (other is double) {
      return new DoubleSeries<LT>(data * other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = new List<double>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] * other[label];
        } else {
          list[i] = data[i];
        }
      }
      return new DoubleSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<double>) {
      return new DoubleSeries<LT>(data * other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  DoubleSeries<LT> operator -() =>
      new DoubleSeries.copy(this, name: name)..negate();

  @override
  BoolSeriesBase<LT> operator >=(other) {
    if (other is double) {
      return new BoolSeries<LT>(data >= other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] >= other[label];
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<double>) {
      return new BoolSeries<LT>(data >= other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator >(other) {
    if (other is double) {
      return new BoolSeries<LT>(data > other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] > other[label];
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<double>) {
      return new BoolSeries<LT>(data > other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator <=(other) {
    if (other is double) {
      return new BoolSeries<LT>(data <= other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] <= other[label];
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<double>) {
      return new BoolSeries<LT>(data <= other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }

  @override
  BoolSeriesBase<LT> operator <(other) {
    if (other is double) {
      return new BoolSeries<LT>(data < other, name: name, labels: labels);
    } else if (other is NumericSeriesView<LT, double>) {
      final list = new List<bool>()..length = length;
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          list[i] = data[i] < other[label];
        }
      }
      return new BoolSeries<LT>(list, name: name, labels: labels);
    } else if (other is IterView<double>) {
      return new BoolSeries<LT>(data < other, name: name, labels: labels);
    }
    throw new UnimplementedError();
  }
}
