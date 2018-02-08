part of grizzly.series;

/*
class BoolSeries<LT> extends Object
    with SeriesMixin<LT, bool>, SeriesViewMixin<LT, bool>
    implements Series<LT, bool> {
  final List<LT> _labels;

  final List<bool> _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic name;

  final UnmodifiableListView<LT> labels;

  final UnmodifiableListView<bool> data;

  SeriesByPosition<LT, bool> _pos;

  SeriesByPosition<LT, bool> get byPos => _pos;

  BoolSeriesView<LT> _view;

  BoolSeriesView<LT> get toView {
    if (_view == null) _view = new BoolSeriesView<LT>.from(this);
    return _view;
  }

  BoolSeries._(this._data, this._labels, this.name, this._mapper)
      : labels = new UnmodifiableListView(_labels),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesByPosition<LT, bool>(this);
  }

  factory BoolSeries(Iterable<bool> data, {dynamic name, List<LT> labels}) {
    final List<LT> madeIndices = makeLabels<LT>(data.length, labels, LT);
    final mapper = labelsToMapper(madeIndices);

    return new BoolSeries._(data.toList(), madeIndices, name, mapper);
  }

  factory BoolSeries.fromMap(Map<LT, bool> map, {dynamic name}) {
    final List<LT> labels = [];
    final List<bool> data = [];
    final mapper = new SplayTreeMap<LT, int>();

    for (LT label in map.keys) {
      labels.add(label);
      data.add(map[label]);
      mapper[label] = data.length - 1;
    }

    return new BoolSeries._(data.toList(), labels, name, mapper);
  }

  bool get max {
    for (bool v in _data) {
      if (v == null) continue;
      if (v) return true;
    }

    return false;
  }

  bool get min {
    for (bool v in _data) {
      if (v == null) continue;
      if (!v) return false;
    }

    return true;
  }

  IntSeries<LT> toInt({int radix, int fillVal}) {
    return new IntSeries<LT>(_data.map((bool v) => v ? 1 : 0).toList(),
        name: name, labels: _labels.toList());
  }

  DoubleSeries<LT> toDouble({double fillVal}) {
    return new DoubleSeries<LT>(_data.map((bool v) => v ? 1.0 : 0.0).toList(),
        name: name, labels: _labels.toList());
  }

  BoolSeries<LT> get toSeries =>
      new BoolSeries(_data, name: name, labels: _labels);

  BoolSeriesView<ILT> makeView<ILT>(Iterable<bool> data,
          {dynamic name, List<ILT> labels}) =>
      new BoolSeriesView<ILT>(data, name: name, labels: labels);

  BoolSeries<IIT> make<IIT>(Iterable<bool> data,
          {dynamic name, List<IIT> labels}) =>
      new BoolSeries<IIT>(data, name: name, labels: labels);
}
*/