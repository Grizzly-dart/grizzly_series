part of grizzly.series;

class BoolSeries<LT> extends Object
    with
        SeriesViewMixin<LT, bool>,
        SeriesFixMixin<LT, bool>,
        SeriesMixin<LT, bool>,
        BoolSeriesViewMixin<LT>
    implements BoolSeriesFix<LT>, BoolSeriesBase<LT> {
  final List<LT> _labels;

  final Bool1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  BoolSeries._(this._labels, this._data, this._name, this._mapper);

  BoolSeries._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory BoolSeries(Iterable<bool> data, {dynamic name, Iterable<LT> labels}) {
    Bool1D d = Bool1D(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return BoolSeries._build(madeLabels, d, name);
  }

  factory BoolSeries.fromMap(Map<LT, bool> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = List<LT>()..length = map.length;
    final data = Bool1D.sized(map.length);
    final mapper = SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return BoolSeries._(labels, data, name, mapper);
  }

  factory BoolSeries.copy(SeriesView<LT, bool> series,
          {name, Iterable<LT> labels}) =>
      BoolSeries<LT>(series.data, name: series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  Bool1DFix get data => _data.fixed;

  BoolSeriesView<LT> _view;

  BoolSeriesView<LT> get view =>
      _view ??= BoolSeriesView<LT>._(_labels, _data, () => name, _mapper);

  BoolSeriesFix<LT> _fixed;

  BoolSeriesFix<LT> get fixed =>
      _fixed ??= BoolSeriesFix<LT>._(_labels, _data, () => name, _mapper);

  String get name => _name is Function ? _name() : _name.toString();

/* TODO
  IntSeries<LT> toInt({int radix, int fillVal}) {
    return new IntSeries<LT>(_data.map((bool v) => v ? 1 : 0).toList(),
        name: name, labels: _labels.toList());
  }

  DoubleSeries<LT> toDouble({double fillVal}) {
    return new DoubleSeries<LT>(_data.map((bool v) => v ? 1.0 : 0.0).toList(),
        name: name, labels: _labels.toList());
  }
  */
}
