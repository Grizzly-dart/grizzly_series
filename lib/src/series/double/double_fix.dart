part of grizzly.series;

class DoubleSeriesFix<LT> extends Object
    with
        SeriesViewMixin<LT, double>,
        SeriesFixMixin<LT, double>,
        DoubleSeriesViewMixin<LT>
    implements NumericFixSeries<LT, double> {
  final List<LT> _labels;

  final Double1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  DoubleSeriesView<LT> _view;

  DoubleSeriesFix._(this._labels, this._data, this._name, this._mapper);

  DoubleSeriesFix._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory DoubleSeriesFix(/* Iterable<int> | IterView<int> */ data,
      {dynamic name, Iterable<LT> labels}) {
    Double1D d;
    if (data is Iterable<double>) {
      d = new Double1D(data);
    } else if (data is IterView<double>) {
      d = new Double1D.copy(data);
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

  Numeric1DView<double> get data => _data.view;

  DoubleSeriesView<LT> get view =>
      _view ??= new DoubleSeriesView<LT>._(_labels, _data, () => name, _mapper);

  DoubleSeriesFix<LT> get fixed => this;

  String get name => _name is Function ? _name() : _name;
}
