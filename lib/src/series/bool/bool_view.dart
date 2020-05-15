part of grizzly.series;

class BoolSeriesView<LT> extends Object
    with SeriesViewMixin<LT, bool>, BoolSeriesViewMixin<LT>
    implements BoolSeriesViewBase<LT> {
  final _name;

  final Iterable<LT> labels;

  final Bool1DView data;

  final SplayTreeMap<LT, int> _mapper;

  BoolSeriesView._(this.labels, this.data, this._name, this._mapper);

  BoolSeriesView._build(this.labels, this.data, this._name)
      : _mapper = labelsToMapper(labels);

  factory BoolSeriesView(Iterable<bool> data, {name, Iterable<LT> labels}) {
    Bool1DView d = new Bool1DView(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new BoolSeriesView._build(madeLabels, d, name);
  }

  factory BoolSeriesView.constant(bool data,
          {name, Iterable<LT> labels, int length}) =>
      new BoolSeriesView(
          ranger.ConstantIterable<bool>(data, length ?? labels.length),
          name: name,
          labels: labels);

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

  factory BoolSeriesView.copy(SeriesView<LT, bool> series) =>
      new BoolSeriesView<LT>(series.data,
          name: series.name, labels: series.labels);

  String get name => _name is Function ? _name() : _name;

  @override
  BoolSeriesView<LT> get view => this;
}

abstract class BoolSeriesViewMixin<LT> implements SeriesView<LT, bool> {
  BoolSeries<LT> toSeries() => new BoolSeries(data, name: name, labels: labels);

  BoolSeriesView<IIT> makeView<IIT>(Iterable<bool> data,
          {dynamic name, Iterable<IIT> labels}) =>
      new BoolSeriesView(data, name: name, labels: labels);

  BoolSeries<IIT> make<IIT>(Iterable<bool> data,
          {dynamic name, Iterable<IIT> labels}) =>
      new BoolSeries<IIT>(data, name: name, labels: labels);

  @override
  Bool1D makeValueArraySized(int size) => new Bool1D.sized(size);

  @override
  Bool1D makeValueArray(Iterable<bool> data) => new Bool1D(data);

  @override
  int compareValue(bool a, bool b) => a == b ? 0 : a ? 1 : -1;

  bool get max {
    for (bool v in data) {
      if (v == null) continue;
      if (v) return true;
    }

    return false;
  }

  bool get min {
    for (bool v in data) {
      if (v == null) continue;
      if (!v) return false;
    }

    return true;
  }
}
