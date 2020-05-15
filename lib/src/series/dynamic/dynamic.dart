part of grizzly.series;

class DynamicSeries<LT> extends Object
    with
        SeriesViewMixin<LT, dynamic>,
        SeriesFixMixin<LT, dynamic>,
        SeriesMixin<LT, dynamic>,
        DynamicSeriesViewMixin<LT>
    implements DynamicSeriesFix<LT>, DynamicSeriesBase<LT> {
  final List<LT> _labels;

  final Dynamic1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  DynamicSeries._(this._labels, this._data, this._name, this._mapper);

  DynamicSeries._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory DynamicSeries(Iterable<dynamic> data,
      {dynamic name, Iterable<LT> labels}) {
    Dynamic1D d = Dynamic1D(data);

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return DynamicSeries._build(madeLabels, d, name);
  }

  factory DynamicSeries.fromMap(Map<LT, bool> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = List<LT>()..length = map.length;
    final data = Dynamic1D.sized(map.length);
    final mapper = SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return DynamicSeries._(labels, data, name, mapper);
  }

  factory DynamicSeries.copy(SeriesView<LT, bool> series,
          {name, Iterable<LT> labels}) =>
      DynamicSeries<LT>(series.data, name: series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  Dynamic1DFix get data => _data.fixed;

  String get name => _name is Function ? _name() : _name.toString();

  DynamicSeriesView<LT> _view;

  DynamicSeriesView<LT> get view =>
      _view ??= DynamicSeriesView<LT>._(_labels, _data, () => name, _mapper);

  DynamicSeriesFix<LT> _fixed;

  DynamicSeriesFix<LT> get fixed =>
      _fixed ??= DynamicSeriesFix<LT>._(_labels, _data, () => name, _mapper);

/* TODO
  IntSeries<LT> toInt({int radix, int fillVal}) {
    return IntSeries<LT>(_data.map((bool v) => v ? 1 : 0).toList(),
        name: name, labels: _labels.toList());
  }

  DoubleSeries<LT> toDouble({double fillVal}) {
    return DoubleSeries<LT>(_data.map((bool v) => v ? 1.0 : 0.0).toList(),
        name: name, labels: _labels.toList());
  }
  */
}
