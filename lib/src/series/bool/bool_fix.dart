part of grizzly.series;

class BoolSeriesFix<LT> extends Object
    with
        SeriesViewMixin<LT, bool>,
        SeriesFixMixin<LT, bool>,
        BoolSeriesViewMixin<LT>
    implements BoolSeriesView<LT>, BoolSeriesFixBase<LT> {
  final List<LT> _labels;

  final Bool1DFix _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  BoolSeriesView<LT> _view;

  BoolSeriesFix._(this._labels, this._data, this._name, this._mapper);

  BoolSeriesFix._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory BoolSeriesFix(Iterable<bool> data,
      {dynamic name, Iterable<LT> labels}) {
    Bool1DFix d = Bool1DFix(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return BoolSeriesFix._build(madeLabels, d, name);
  }

  factory BoolSeriesFix.fromMap(Map<LT, bool> map,
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
    return BoolSeriesFix._(labels, data, name, mapper);
  }

  factory BoolSeriesFix.copy(SeriesView<LT, bool> series,
          {name, Iterable<LT> labels}) =>
      BoolSeriesFix<LT>(series.data, name: series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  Bool1DFix get data => _data;

  BoolSeriesView<LT> get view =>
      _view ??= BoolSeriesView<LT>._(_labels, _data, () => name, _mapper);

  @override
  SeriesFix<LT, bool> get fixed => this;

  String get name => _name is Function ? _name() : _name;
}
