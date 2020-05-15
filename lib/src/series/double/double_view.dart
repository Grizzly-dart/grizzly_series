part of grizzly.series;

class DoubleSeriesView<LT> extends Object
    with SeriesViewMixin<LT, double>, DoubleSeriesViewMixin<LT>
    implements NumericSeriesView<LT, double> {
  final _name;

  final Iterable<LT> labels;

  final Double1DView data;

  final SplayTreeMap<LT, int> _mapper;

  DoubleSeriesView._(this.labels, this.data, this._name, this._mapper);

  DoubleSeriesView._build(this.labels, this.data, this._name)
      : _mapper = labelsToMapper(labels);

  factory DoubleSeriesView(Iterable<double> data, {name, Iterable<LT> labels}) {
    Double1DView d = Double1DView(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return DoubleSeriesView._build(madeLabels, d, name);
  }

  factory DoubleSeriesView.fromNums(Iterable<num> data,
      {name, Iterable<LT> labels}) {
    Double1DView d = Double1DView.fromNums(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return DoubleSeriesView._build(madeLabels, d, name);
  }

  factory DoubleSeriesView.constant(double data,
          {name, Iterable<LT> labels, int length}) =>
      DoubleSeriesView(
          ranger.ConstantIterable<double>(data, length ?? labels.length),
          name: name,
          labels: labels);

  factory DoubleSeriesView.fromMap(Map<LT, double> map, {dynamic name}) {
    final labels = List<LT>(map.length);
    final data = Double1D.sized(map.length);
    final mapper = SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return DoubleSeriesView._(labels, data, name, mapper);
  }

  factory DoubleSeriesView.copy(SeriesView<LT, double> series) =>
      DoubleSeriesView<LT>(series.data,
          name: series.name, labels: series.labels);

  String get name => _name is Function ? _name() : _name;

  Stats<double> get stats => data.stats;

  DoubleSeriesView<LT> get view => this;
}
