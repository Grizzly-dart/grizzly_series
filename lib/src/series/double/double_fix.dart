part of grizzly.series;

abstract class DoubleSeriesFixMixin<LT> implements DoubleNumericSeriesFix<LT> {
  @override
  void addition(
      /* E | NumericSeriesView<E> | Iterable<E> */ other) {
    if (other is SeriesView<LT, num>) {
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          data[i] += other[label];
        } else {
          data[i] = null;
        }
      }
      return;
    } else if (other is num || other is Iterable<num>) {
      data.addition(other);
      return;
    }
    throw UnimplementedError();
  }

  @override
  void subtract(
      /* E | NumericSeriesView<E> | Iterable<E> */ other) {
    if (other is SeriesView<LT, num>) {
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          data[i] -= other[label];
        } else {
          data[i] = null;
        }
      }
      return;
    } else if (other is num || other is Iterable<num>) {
      data.subtract(other);
      return;
    }
    throw UnimplementedError();
  }

  @override
  void multiply(
      /* E | NumericSeriesView<E> | Iterable<E> */ other) {
    if (other is SeriesView<LT, num>) {
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          data[i] *= other[label];
        } else {
          data[i] = null;
        }
      }
      return;
    } else if (other is num || other is Iterable<num>) {
      data.multiply(other);
      return;
    }
    throw UnimplementedError();
  }

  @override
  void divide(
      /* E | NumericSeriesView<E> | Iterable<E> */ other) {
    if (other is SeriesView<LT, num>) {
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          data[i] /= other[label];
        } else {
          data[i] = null;
        }
      }
      return;
    } else if (other is num || other is Iterable<num>) {
      data.divide(other);
      return;
    }
    throw UnimplementedError();
  }

  @override
  void truncDiv(
          /* E | IterView<E> | NumericSeriesView<E> | Iterable<E> */ other) =>
      divide(other);

  DoubleSeries<LT> normalized() {
    double s = sum;
    return DoubleSeries<LT>(this.data.map((e) => e / s), labels: labels);
  }

  void absSelf() {
    apply((value) => value.abs());
  }

  void normalizeSelf() {
    double s = sum;
    apply((value) => value / s);
  }

  void logSelf() {
    apply((value) => math.log(value));
  }

  void log10Self() {
    apply((value) => math.log(value) / math.ln10);
  }

  void logNSelf(num n) {
    final logOfN = math.log(n);
    apply((value) => math.log(value) / logOfN);
  }

  void expSelf() {
    apply((value) => math.exp(value));
  }
}

class DoubleSeriesFix<LT> extends Object
    with
        SeriesViewMixin<LT, double>,
        SeriesFixMixin<LT, double>,
        DoubleSeriesFixMixin<LT>
    implements
        DoubleNumericSeriesFix<LT>,
        DoubleSeriesView<LT>,
        NumericSeriesFix<LT, double> {
  final List<LT> _labels;

  final Double1DFix _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  DoubleSeriesView<LT> _view;

  DoubleSeriesFix._(this._labels, this._data, this._name, this._mapper);

  DoubleSeriesFix._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory DoubleSeriesFix(Iterable<double> data,
      {dynamic name, Iterable<LT> labels}) {
    Double1DFix d = Double1DFix(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return DoubleSeriesFix._build(madeLabels, d, name);
  }

  factory DoubleSeriesFix.fromNums(Iterable<num> data,
      {dynamic name, Iterable<LT> labels}) {
    Double1DFix d = Double1DFix.fromNums(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return DoubleSeriesFix._build(madeLabels, d, name);
  }

  factory DoubleSeriesFix.fromMap(Map<LT, double> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = List<LT>()..length = map.length;
    final data = Double1D.sized(map.length);
    final mapper = SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return DoubleSeriesFix._(labels, data, name, mapper);
  }

  factory DoubleSeriesFix.copy(SeriesView<LT, double> series,
          {name, Iterable<LT> labels}) =>
      DoubleSeriesFix<LT>(series.data,
          name: series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  Double1DFix get data => _data;

  Stats<double> get stats => data.stats;

  DoubleSeriesView<LT> get view =>
      _view ??= DoubleSeriesView<LT>._(_labels, _data, () => name, _mapper);

  DoubleSeriesFix<LT> get fixed => this;

  String get name => _name is Function ? _name() : _name;

  @override
  void negate() {
    _data.negate();
  }

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

  DoubleNumericSeries<LT> get log =>
      DoubleSeries(data.log, name: name, labels: labels);

  DoubleNumericSeries<LT> get log10 =>
      DoubleSeries(data.log10, name: name, labels: labels);

  DoubleNumericSeries<LT> logN(num n) =>
      DoubleSeries(data.logN(n), name: name, labels: labels);

  DoubleNumericSeries<LT> get exp =>
      DoubleSeries(data.exp, name: name, labels: labels);

  DoubleNumericSeries<LT> get abs =>
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
