part of grizzly.series;

class BoolSeriesView<LT> extends Object
    with SeriesViewMixin<LT, bool>
    implements SeriesView<LT, bool> {
  final name;

  final List<LT> _labels;

  final List<bool> _data;

  final SplayTreeMap<LT, int> _mapper;

  final UnmodifiableListView<LT> labels;

  final UnmodifiableListView<bool> data;

  SeriesViewByPosition<LT, bool> _pos;

  SeriesViewByPosition<LT, bool> get byPos => _pos;

  BoolSeriesView._(this._data, this._labels, this.name, this._mapper)
      : labels = new UnmodifiableListView(_labels),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesViewByPosition<LT, bool>(this);
  }

  factory BoolSeriesView(Iterable<bool> data, {dynamic name, List<LT> labels}) {
    final List<LT> madeLabels = makeLabels<LT>(data.length, labels, LT);
    final mapper = labelsToMapper(madeLabels);

    return new BoolSeriesView._(data.toList(), madeLabels, name, mapper);
  }

  factory BoolSeriesView.from(BoolSeries<LT> series) =>
      new BoolSeriesView(series.data, name: series.name, labels: series.labels);

  BoolSeries<LT> get toSeries =>
      new BoolSeries(_data, name: name, labels: _labels);

  @override
  BoolSeriesView<LT> get toView => this;

  BoolSeriesView<ILT> makeView<ILT>(Iterable<bool> data,
          {dynamic name, List<ILT> labels}) =>
      new BoolSeriesView<ILT>(data, name: name, labels: labels);

  BoolSeries<IIT> make<IIT>(Iterable<bool> data,
          {dynamic name, List<IIT> labels}) =>
      new BoolSeries<IIT>(data, name: name, labels: labels);
}
