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

  factory IntSeriesView(/* Iterable<int> | IterView<int> */ data,
      {name, Iterable<LT> labels}) {
    Int1D d;
    if (data is Iterable<int>) {
      d = new Int1D(data);
    } else if (data is IterView<int>) {
      d = new Int1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new IntSeriesView._build(madeLabels, d, name);
  }

  factory IntSeriesView.fromMap(Map<LT, int> map, {dynamic name}) {
    final labels = new List<LT>(map.length);
    final data = new Int1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new IntSeriesView._(labels, data, name, mapper);
  }

  factory IntSeriesView.copy(SeriesView<LT, String> series) {}

  dynamic get name => _name is Function ? _name() : _name;

  IntSeriesView<LT> toView() => this;

  SeriesViewByPosition<LT, int> _pos;

  SeriesViewByPosition<LT, int> get byPos =>
      _pos ??= new SeriesViewByPosition<LT, int>(this);
}
