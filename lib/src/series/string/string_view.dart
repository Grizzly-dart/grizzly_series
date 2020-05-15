part of grizzly.series;

class StringSeriesView<LT> extends Object
    with SeriesViewMixin<LT, String>, StringSeriesViewMixin<LT>
    implements StringSeriesViewBase<LT> {
  final _name;

  final Iterable<LT> labels;

  final String1DView data;

  final SplayTreeMap<LT, int> _mapper;

  StringSeriesView._(this.labels, this.data, this._name, this._mapper);

  StringSeriesView._build(this.labels, this.data, this._name)
      : _mapper = labelsToMapper(labels);

  factory StringSeriesView(Iterable<String> data, {name, Iterable<LT> labels}) {
    String1DView d = new String1DView(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new StringSeriesView._build(madeLabels, d, name);
  }

  factory StringSeriesView.constant(String data,
          {name, Iterable<LT> labels, int length}) =>
      new StringSeriesView(
          ranger.ConstantIterable<String>(data, length ?? labels.length),
          name: name,
          labels: labels);

  factory StringSeriesView.fromMap(Map<LT, String> map, {dynamic name}) {
    final labels = new List<LT>(map.length);
    final data = new String1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new StringSeriesView._(labels, data, name, mapper);
  }

  factory StringSeriesView.copy(SeriesView<LT, String> series) =>
      new StringSeriesView<LT>(series.data,
          name: series.name, labels: series.labels);

  String get name => _name is Function ? _name() : _name;

  StringSeriesView<LT> get view => this;
}

abstract class StringSeriesViewMixin<LT> implements StringSeriesViewBase<LT> {
  StringSeries<LT> toSeries() =>
      new StringSeries<LT>(data, name: name, labels: labels);

  StringSeriesView<IIT> makeView<IIT>(Iterable<String> data,
          {dynamic name, Iterable<IIT> labels}) =>
      new StringSeriesView(data, name: name, labels: labels);

  StringSeries<IIT> make<IIT>(Iterable<String> data,
          {dynamic name, Iterable<IIT> labels}) =>
      new StringSeries<IIT>(data, name: name, labels: labels);

  @override
  String1D makeValueArraySized(int size) => new String1D.sized(size);

  @override
  String1D makeValueArray(Iterable<String> data) => new String1D(data);

  @override
  int compareValue(String a, String b) => a.compareTo(b);

  @override
  DoubleSeries<LT> toDouble(
          {double defaultValue, double onError(String source)}) =>
      new DoubleSeries<LT>(
          data.toDouble(defaultValue: defaultValue, onError: onError),
          name: name,
          labels: labels);

  @override
  IntSeries<LT> toInt(
          {int radix, int defaultValue, int onError(String source)}) =>
      new IntSeries<LT>(
          data.toInt(
              radix: radix, defaultValue: defaultValue, onError: onError),
          name: name,
          labels: labels);

  String max() {
    String ret;

    for (String v in data) {
      if (v == null) continue;
      if (ret == null)
        ret = v;
      else if (ret.compareTo(v) < 0) ret = v;
    }

    return ret;
  }

  String min() {
    String ret;

    for (String v in data) {
      if (v == null) continue;
      if (ret == null)
        ret = v;
      else if (ret.compareTo(v) > 0) ret = v;
    }

    return ret;
  }
}
