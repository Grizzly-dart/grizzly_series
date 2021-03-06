part of grizzly.series;

class IntSeriesView<LT> extends Object
    with SeriesViewMixin<LT, int>, IntSeriesViewMixin<LT>
    implements NumericSeriesView<LT, int> {
  final _name;

  final Iterable<LT> labels;

  final Int1DView data;

  final SplayTreeMap<LT, int> _mapper;

  IntSeriesView._(this.labels, this.data, this._name, this._mapper);

  IntSeriesView._build(this.labels, this.data, this._name)
      : _mapper = labelsToMapper(labels);

  factory IntSeriesView(Iterable<int> data, {name, Iterable<LT> labels}) {
    Int1D d = Int1D(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return IntSeriesView._build(madeLabels, d, name);
  }

  factory IntSeriesView.fromNums(Iterable<num> data,
      {name, Iterable<LT> labels}) {
    Int1D d = Int1D.fromNums(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return IntSeriesView._build(madeLabels, d, name);
  }

  factory IntSeriesView.constant(int data,
          {name, Iterable<LT> labels, int length}) =>
      IntSeriesView(ranger.ConstantIterable<int>(data, length ?? labels.length),
          name: name, labels: labels);

  factory IntSeriesView.fromMap(Map<LT, int> map, {dynamic name}) {
    final labels = List<LT>(map.length);
    final data = Int1D.sized(map.length);
    final mapper = SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return IntSeriesView._(labels, data, name, mapper);
  }

  factory IntSeriesView.copy(SeriesView<LT, int> series) =>
      IntSeriesView<LT>(series.data, name: series.name, labels: series.labels);

  String get name => _name is Function ? _name() : _name.toString();

  Stats<int> get stats => data.stats;

  IntSeriesView<LT> get view => this;
}
