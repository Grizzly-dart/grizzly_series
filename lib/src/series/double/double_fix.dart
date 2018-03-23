part of grizzly.series;

abstract class DoubleSeriesFixMixin<LT>
    implements NumericSeriesFix<LT, double> {
  @override
  void addition(
      /* E | IterView<E> | NumericSeriesView<E> | Iterable<E> */ other) {
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
    } else if (other is num ||
        other is IterView<num> ||
        other is Iterable<num>) {
      data.addition(other);
      return;
    }
    throw new UnimplementedError();
  }

  @override
  void subtract(
      /* E | IterView<E> | NumericSeriesView<E> | Iterable<E> */ other) {
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
    } else if (other is num ||
        other is IterView<num> ||
        other is Iterable<num>) {
      data.subtract(other);
      return;
    }
    throw new UnimplementedError();
  }

  @override
  void multiply(
      /* E | IterView<E> | NumericSeriesView<E> | Iterable<E> */ other) {
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
    } else if (other is num ||
        other is IterView<num> ||
        other is Iterable<num>) {
      data.multiply(other);
      return;
    }
    throw new UnimplementedError();
  }

  @override
  void divide(
      /* E | IterView<E> | NumericSeriesView<E> | Iterable<E> */ other) {
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
    } else if (other is num ||
        other is IterView<num> ||
        other is Iterable<num>) {
      data.divide(other);
      return;
    }
    throw new UnimplementedError();
  }

  @override
  void truncDiv(
          /* E | IterView<E> | NumericSeriesView<E> | Iterable<E> */ other) =>
      divide(other);
}

class DoubleSeriesFix<LT> extends Object
    with
        SeriesViewMixin<LT, double>,
        SeriesFixMixin<LT, double>,
        DoubleSeriesViewMixin<LT>,
        DoubleSeriesFixMixin<LT>
    implements DoubleSeriesView<LT>, NumericSeriesFix<LT, double> {
  final List<LT> _labels;

  final Double1DFix _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  DoubleSeriesView<LT> _view;

  DoubleSeriesFix._(this._labels, this._data, this._name, this._mapper);

  DoubleSeriesFix._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory DoubleSeriesFix(/* Iterable<int> | IterView<int> */ data,
      {dynamic name, Iterable<LT> labels}) {
    Double1DFix d;
    if (data is Iterable<double>) {
      d = new Double1DFix(data);
    } else if (data is IterView<double>) {
      d = new Double1DFix.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new DoubleSeriesFix._build(madeLabels, d, name);
  }

  factory DoubleSeriesFix.fromMap(Map<LT, double> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = new List<LT>()..length = map.length;
    final data = new Double1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new DoubleSeriesFix._(labels, data, name, mapper);
  }

  factory DoubleSeriesFix.copy(SeriesView<LT, double> series,
          {name, Iterable<LT> labels}) =>
      new DoubleSeriesFix<LT>(series.data,
          name: series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  Double1DFix get data => _data;

  Stats<double> get stats => data.stats;

  DoubleSeriesView<LT> get view =>
      _view ??= new DoubleSeriesView<LT>._(_labels, _data, () => name, _mapper);

  DoubleSeriesFix<LT> get fixed => this;

  String get name => _name is Function ? _name() : _name;

  @override
  void negate() {
    _data.negate();
  }
}
