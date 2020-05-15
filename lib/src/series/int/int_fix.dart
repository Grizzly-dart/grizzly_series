part of grizzly.series;

abstract class IntSeriesFixMixin<LT> implements NumericSeriesFix<LT, int> {
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
          /* E | NumericSeriesView<E> | Iterable<E> */ other) =>
      truncDiv(other);

  @override
  void truncDiv(
      /* E | NumericSeriesView<E> | Iterable<E> */ other) {
    if (other is SeriesView<LT, num>) {
      for (int i = 0; i < length; i++) {
        LT label = labelAt(i);
        if (other.containsLabel(label)) {
          data[i] ~/= other[label];
        } else {
          data[i] = null;
        }
      }
      return;
    } else if (other is num || other is Iterable<num>) {
      data.truncDiv(other);
      return;
    }
    throw UnimplementedError();
  }
}

class IntSeriesFix<LT> extends Object
    with
        SeriesViewMixin<LT, int>,
        SeriesFixMixin<LT, int>,
        IntSeriesFixMixin<LT>
    implements NumericSeriesFix<LT, int>, IntSeriesView<LT> {
  final List<LT> _labels;

  final Int1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  IntSeriesFix._(this._labels, this._data, this._name, this._mapper);

  IntSeriesFix._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory IntSeriesFix(Iterable<int> data,
      {dynamic name, Iterable<LT> labels}) {
    Int1D d = Int1D(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return IntSeriesFix._build(madeLabels, d, name);
  }

  factory IntSeriesFix.fromNums(Iterable<num> data,
      {dynamic name, Iterable<LT> labels}) {
    Int1D d = Int1D.fromNums(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return IntSeriesFix._build(madeLabels, d, name);
  }

  factory IntSeriesFix.fromMap(Map<LT, int> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = List<LT>()..length = map.length;
    final data = Int1D.sized(map.length);
    final mapper = SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return IntSeriesFix._(labels, data, name, mapper);
  }

  factory IntSeriesFix.copy(SeriesView<LT, int> series, {name}) =>
      IntSeriesFix(series.data,
          name: name ?? series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  Int1DFix get data => _data;

  IntSeriesView<LT> _view;

  IntSeriesView<LT> get view =>
      _view ??= IntSeriesView<LT>._(_labels, _data, () => name, _mapper);

  @override
  SeriesFix<LT, int> get fixed => this;

  String get name => _name is Function ? _name() : _name.toString();

  Stats<int> get stats => _data.stats;

  @override
  void negate() {
    _data.negate();
  }

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
