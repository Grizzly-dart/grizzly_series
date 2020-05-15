part of grizzly.series;

class DynamicSeriesFix<LT> extends Object
    with
        SeriesViewMixin<LT, dynamic>,
        SeriesFixMixin<LT, dynamic>,
        DynamicSeriesViewMixin<LT>
    implements DynamicSeriesView<LT>, DynamicSeriesFixBase<LT> {
  final List<LT> _labels;

  final Dynamic1DFix _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  DynamicSeriesView<LT> _view;

  DynamicSeriesFix._(this._labels, this._data, this._name, this._mapper);

  DynamicSeriesFix._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory DynamicSeriesFix(Iterable<dynamic> data,
      {dynamic name, Iterable<LT> labels}) {
    Dynamic1DFix d = Dynamic1DFix(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return DynamicSeriesFix._build(madeLabels, d, name);
  }

  factory DynamicSeriesFix.fromMap(Map<LT, dynamic> map,
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
    return DynamicSeriesFix._(labels, data, name, mapper);
  }

  factory DynamicSeriesFix.copy(SeriesView<LT, dynamic> series,
          {name, Iterable<LT> labels}) =>
      DynamicSeriesFix<LT>(series.data,
          name: series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  Dynamic1DFix get data => _data;

  DynamicSeriesView<LT> get view =>
      _view ??= DynamicSeriesView<LT>._(_labels, _data, () => name, _mapper);

  @override
  SeriesFix<LT, dynamic> get fixed => this;

  String get name => _name is Function ? _name() : _name.toString();

/* TODO
  IntSeries<LT> toInt({int radix, int fillVal}) {
    return IntSeries<LT>(_data.map((dynamic v) => v ? 1 : 0).toList(),
        name: name, labels: _labels.toList());
  }

  DoubleSeries<LT> toDouble({double fillVal}) {
    return DoubleSeries<LT>(_data.map((dynamic v) => v ? 1.0 : 0.0).toList(),
        name: name, labels: _labels.toList());
  }
  */
}
