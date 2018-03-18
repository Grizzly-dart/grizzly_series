part of grizzly.series;

class BoolSeriesView<LT> extends Object
    with SeriesViewMixin<LT, bool>, BoolSeriesViewMixin<LT>
    implements SeriesView<LT, bool> {
  final _name;

  final Iterable<LT> labels;

  final BoolArrayView data;

  final SplayTreeMap<LT, int> _mapper;

  BoolSeriesView._(this.labels, this.data, this._name, this._mapper);

  BoolSeriesView._build(this.labels, this.data, this._name)
      : _mapper = labelsToMapper(labels);

  factory BoolSeriesView(/* Iterable<bool> | IterView<bool> */ data,
      {name, Iterable<LT> labels}) {
    Bool1D d;
    if (data is Iterable<bool>) {
      d = new Bool1D(data);
    } else if (data is IterView<bool>) {
      d = new Bool1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new BoolSeriesView._build(madeLabels, d, name);
  }

  factory BoolSeriesView.fromMap(Map<LT, bool> map, {dynamic name}) {
    final labels = new List<LT>(map.length);
    final data = new Bool1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new BoolSeriesView._(labels, data, name, mapper);
  }

  factory BoolSeriesView.copy(SeriesView<LT, bool> series) {}

  String get name => _name is Function ? _name() : _name;

  @override
  BoolSeriesView<LT> get view => this;
}

abstract class BoolSeriesViewMixin<LT> implements SeriesView<LT, bool> {
  BoolSeries<LT> toSeries() => new BoolSeries(data, name: name, labels: labels);

  BoolSeriesView<IIT> makeView<IIT>(
          /* Iterable<bool> | IterView<bool> */ data,
          {dynamic name,
          List<IIT> labels}) =>
      new BoolSeriesView(data, name: name, labels: labels);

  BoolSeries<IIT> make<IIT>(/* Iterable<bool> | IterView<bool> */ data,
          {dynamic name, List<IIT> labels}) =>
      new BoolSeries<IIT>(data, name: name, labels: labels);

  @override
  Bool1D makeVTArraySized(int size) => new Bool1D.sized(size);

  @override
  Bool1D makeVTArray(Iterable<bool> data) => new Bool1D(data);

  @override
  int compareVT(bool a, bool b) => a == b ? 0 : a ? 1 : -1;

  bool get max {
    for (bool v in data.asIterable) {
      if (v == null) continue;
      if (v) return true;
    }

    return false;
  }

  bool get min {
    for (bool v in data.asIterable) {
      if (v == null) continue;
      if (!v) return false;
    }

    return true;
  }
}
