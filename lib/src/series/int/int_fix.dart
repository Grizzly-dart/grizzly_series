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
    throw new UnimplementedError();
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
    throw new UnimplementedError();
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
    throw new UnimplementedError();
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
    throw new UnimplementedError();
  }
}

class IntSeriesFix<LT> extends Object
    with
        SeriesViewMixin<LT, int>,
        SeriesFixMixin<LT, int>,
        IntSeriesViewMixin<LT>,
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
    Int1D d = new Int1D(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new IntSeriesFix._build(madeLabels, d, name);
  }

  factory IntSeriesFix.fromNums(Iterable<num> data,
      {dynamic name, Iterable<LT> labels}) {
    Int1D d = new Int1D.fromNums(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new IntSeriesFix._build(madeLabels, d, name);
  }

  factory IntSeriesFix.fromMap(Map<LT, int> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = new List<LT>()..length = map.length;
    final data = new Int1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new IntSeriesFix._(labels, data, name, mapper);
  }

  factory IntSeriesFix.copy(SeriesView<LT, int> series, {name}) =>
      new IntSeriesFix(series.data,
          name: name ?? series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  Int1DFix get data => _data;

  IntSeriesView<LT> _view;

  IntSeriesView<LT> get view =>
      _view ??= new IntSeriesView<LT>._(_labels, _data, () => name, _mapper);

  @override
  SeriesFix<LT, int> get fixed => this;

  String get name => _name is Function ? _name() : _name.toString();

  Stats<int> get stats => _data.stats;

  @override
  void negate() {
    _data.negate();
  }
}
