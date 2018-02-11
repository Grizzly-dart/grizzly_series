part of grizzly.series;

class DoubleSeriesView<LT> extends Object
    with SeriesViewMixin<LT, double>, DoubleSeriesViewMixin<LT>
    implements NumericSeriesView<LT, double> {
  final _name;

  final Iterable<LT> labels;

  final Numeric1DView<double> data;

  final SplayTreeMap<LT, int> _mapper;

  DoubleSeriesView._(this.labels, this.data, this._name, this._mapper);

  DoubleSeriesView._build(this.labels, this.data, this._name)
      : _mapper = labelsToMapper(labels);

  factory DoubleSeriesView(/* Iterable<double> | IterView<double> */ data,
      {name, Iterable<LT> labels}) {
    Double1D d;
    if (data is Iterable<double>) {
      d = new Double1D(data);
    } else if (data is IterView<double>) {
      d = new Double1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new DoubleSeriesView._build(madeLabels, d, name);
  }

  factory DoubleSeriesView.fromMap(Map<LT, double> map, {dynamic name}) {
    final labels = new List<LT>(map.length);
    final data = new Double1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new DoubleSeriesView._(labels, data, name, mapper);
  }

  factory DoubleSeriesView.copy(SeriesView<LT, String> series) {}

  dynamic get name => _name is Function ? _name() : _name;

  DoubleSeriesView<LT> toView() => this;

  SeriesViewByPosition<LT, double> _pos;

  SeriesViewByPosition<LT, double> get byPos =>
      _pos ??= new SeriesViewByPosition<LT, double>(this);
}