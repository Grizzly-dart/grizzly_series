part of grizzly.series;

class IntSeriesFix<LT> extends Object
    with
        SeriesViewMixin<LT, int>,
        SeriesFixMixin<LT, int>,
        IntSeriesViewMixin<LT>
    implements NumericSeriesFix<LT, int>, IntSeriesView<LT> {
  final List<LT> _labels;

  final Int1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  IntSeriesFix._(this._labels, this._data, this._name, this._mapper);

  IntSeriesFix._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory IntSeriesFix(/* Iterable<int> | IterView<int> */ data,
      {dynamic name, Iterable<LT> labels}) {
    Int1D d;
    if (data is Iterable<int>) {
      d = new Int1D(data);
    } else if (data is IterView<int>) {
      d = new Int1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

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

  Int1DView get data => _data.view;

  IntSeriesView<LT> _view;

  IntSeriesView<LT> get view =>
      _view ??= new IntSeriesView<LT>._(_labels, _data, () => name, _mapper);

  @override
  SeriesFix<LT, int> get fixed => this;

  String get name => _name is Function ? _name() : _name.toString();

  Stats<int> _stats;

  Stats<int> get stats => _stats ??= new StatsImpl<int>(data);

  @override
  void negate() {
    _data.negate();
  }
}
