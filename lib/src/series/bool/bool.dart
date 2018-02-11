part of grizzly.series;

class BoolSeries<LT> extends Object
    with
        SeriesViewMixin<LT, bool>,
        SeriesMixin<LT, bool>,
        BoolSeriesViewMixin<LT>
    implements Series<LT, bool> {
  final List<LT> _labels;

  final Bool1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic name;

  SeriesByPosition<LT, bool> _pos;

  BoolSeriesView<LT> _view;

  BoolSeries._(this._labels, this._data, this.name, this._mapper);

  BoolSeries._build(this._labels, this._data, this.name)
      : _mapper = labelsToMapper(_labels);

  factory BoolSeries(/* Iterable<String> | IterView<String> */ data,
      {dynamic name, Iterable<LT> labels}) {
    Bool1D d;
    if (data is Iterable<bool>) {
      d = new Bool1D(data);
    } else if (data is IterView<bool>) {
      d = new Bool1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new BoolSeries._build(madeLabels, d, name);
  }

  factory BoolSeries.fromMap(Map<LT, bool> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = new List<LT>()..length = map.length;
    final data = new Bool1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new BoolSeries._(labels, data, name, mapper);
  }

  factory BoolSeries.copy(SeriesView<LT, bool> series,
      {name, Iterable<LT> labels}) {
    // TODO
  }

  Iterable<LT> get labels => _labels;

  BoolArrayView get data => _data.view;

  SeriesByPosition<LT, bool> get byPos =>
      _pos ??= new SeriesByPosition<LT, bool>(this);

  BoolSeriesView<LT> toView() =>
      _view ??= new BoolSeriesView<LT>._(_labels, _data, () => name, _mapper);

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
