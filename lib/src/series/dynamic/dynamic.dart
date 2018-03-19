part of grizzly.series;

class DynamicSeries<LT> extends Object
    with
        SeriesViewMixin<LT, dynamic>,
        SeriesFixMixin<LT, dynamic>,
        SeriesMixin<LT, dynamic>,
        DynamicSeriesViewMixin<LT>
    implements DynamicSeriesBase<LT> {
  final List<LT> _labels;

  final Dynamic1D _data;

  final SplayTreeMap<LT, int> _mapper;

  String name;

  DynamicSeries._(this._labels, this._data, this.name, this._mapper);

  DynamicSeries._build(this._labels, this._data, this.name)
      : _mapper = labelsToMapper(_labels);

  factory DynamicSeries(/* Iterable<dynamic> | IterView<dynamic> */ data,
      {dynamic name, Iterable<LT> labels}) {
    Dynamic1D d;
    if (data is Iterable<bool>) {
      d = new Dynamic1D(data);
    } else if (data is IterView<bool>) {
      d = new Dynamic1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new DynamicSeries._build(madeLabels, d, name);
  }

  factory DynamicSeries.fromMap(Map<LT, bool> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = new List<LT>()..length = map.length;
    final data = new Dynamic1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new DynamicSeries._(labels, data, name, mapper);
  }

  factory DynamicSeries.copy(SeriesView<LT, bool> series,
          {name, Iterable<LT> labels}) =>
      new DynamicSeries<LT>(series.data,
          name: series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  DynamicArrayView get data => _data.view;

  DynamicSeriesView<LT> _view;

  DynamicSeriesView<LT> get view => _view ??=
      new DynamicSeriesView<LT>._(_labels, _data, () => name, _mapper);

  DynamicSeriesFix<LT> _fixed;

  DynamicSeriesFix<LT> get fixed => _fixed ??=
      new DynamicSeriesFix<LT>._(_labels, _data, () => name, _mapper);

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
