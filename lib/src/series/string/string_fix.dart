part of grizzly.series;

class StringSeriesFix<LT> extends Object
    with
        SeriesViewMixin<LT, String>,
        SeriesFixMixin<LT, String>,
        StringSeriesViewMixin<LT>
    implements SeriesFix<LT, String> {
  final List<LT> _labels;

  final String1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  StringSeriesFix._(this._labels, this._data, this._name, this._mapper);

  StringSeriesFix._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory StringSeriesFix(/* Iterable<String> | IterView<String> */ data,
      {dynamic name, Iterable<LT> labels}) {
    String1D d;
    if (data is Iterable<String>) {
      d = new String1D(data);
    } else if (data is IterView<String>) {
      d = new String1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new StringSeriesFix._build(madeLabels, d, name);
  }

  factory StringSeriesFix.fromMap(Map<LT, String> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = new List<LT>()..length = map.length;
    final data = new String1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new StringSeriesFix._(labels, data, name, mapper);
  }

  factory StringSeriesFix.copy(SeriesView<LT, String> series,
          {name, Iterable<LT> labels}) =>
      new StringSeriesFix<LT>(series.data,
          name: series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  StringArrayView get data => _data.view;

  StringSeriesView<LT> _view;

  StringSeriesView<LT> get view =>
      _view ??= new StringSeriesView<LT>._(_labels, _data, () => name, _mapper);

  @override
  SeriesFix<LT, String> get fixed => this;

  String get name => _name is Function ? _name() : _name;
}
