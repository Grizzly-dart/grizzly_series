part of grizzly.series;

class DynamicSeriesView<LT> extends Object
    with SeriesViewMixin<LT, dynamic>, DynamicSeriesViewMixin<LT>
    implements DynamicSeriesViewBase<LT> {
  final _name;

  final Iterable<LT> labels;

  final Dynamic1DView data;

  final SplayTreeMap<LT, int> _mapper;

  DynamicSeriesView._(this.labels, this.data, this._name, this._mapper);

  DynamicSeriesView._build(this.labels, this.data, this._name)
      : _mapper = labelsToMapper(labels);

  factory DynamicSeriesView(Iterable<dynamic> data,
      {name, Iterable<LT> labels}) {
    Dynamic1DView d = new Dynamic1DView(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new DynamicSeriesView._build(madeLabels, d, name);
  }

  factory DynamicSeriesView.constant(dynamic data,
          {name, Iterable<LT> labels, int length}) =>
      new DynamicSeriesView(
          ranger.ConstantIterable<dynamic>(data, length ?? labels.length),
          name: name,
          labels: labels);

  factory DynamicSeriesView.fromMap(Map<LT, dynamic> map, {dynamic name}) {
    final labels = new List<LT>(map.length);
    final data = new Dynamic1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new DynamicSeriesView._(labels, data, name, mapper);
  }

  factory DynamicSeriesView.copy(SeriesView<LT, dynamic> series) =>
      new DynamicSeriesView<LT>(series.data,
          name: series.name, labels: series.labels);

  String get name => _name is Function ? _name() : _name.toString();

  @override
  DynamicSeriesView<LT> get view => this;
}
