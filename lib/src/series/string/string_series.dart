part of grizzly.series;

class StringSeries<LT> extends Object
    with
        SeriesViewMixin<LT, String>,
        SeriesFixMixin<LT, String>,
        SeriesMixin<LT, String>,
        StringSeriesViewMixin<LT>
    implements StringSeriesFix<LT>, StringSeriesBase<LT> {
  final List<LT> _labels;

  final String1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  StringSeries._(this._labels, this._data, this._name, this._mapper);

  StringSeries._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory StringSeries(/* Iterable<String> | IterView<String> */ data,
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
    return new StringSeries._build(madeLabels, d, name);
  }

  factory StringSeries.fromMap(Map<LT, String> map,
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
    return new StringSeries._(labels, data, name, mapper);
  }

  factory StringSeries.copy(SeriesView<LT, String> series,
          {name, Iterable<LT> labels}) =>
      new StringSeries<LT>(series.data,
          name: series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  String1DFix get data => _data.fixed;

  StringSeriesView<LT> _view;

  StringSeriesView<LT> get view =>
      _view ??= new StringSeriesView<LT>._(_labels, _data, () => name, _mapper);

  StringSeriesFix<LT> _fixed;

  StringSeriesFix<LT> get fixed =>
      _fixed ??= new StringSeriesFix<LT>._(_labels, _data, () => name, _mapper);

  String get name => _name is Function ? _name() : _name.toString();
}
