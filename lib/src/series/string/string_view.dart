part of grizzly.series;

class StringSeriesView<LT> extends Object
    with SeriesViewMixin<LT, String>, StringSeriesViewMixin<LT>
    implements SeriesView<LT, String> {
  dynamic _name;

  final Iterable<LT> labels;

  final StringArrayView data;

  final SplayTreeMap<LT, int> _mapper;

  StringSeriesView._(this.labels, this.data, this._name, this._mapper);

  StringSeriesView._build(this.labels, this.data, this._name)
      : _mapper = labelsToMapper(labels);

  factory StringSeriesView(/* Iterable<String> | IterView<String> */ data,
      {name, Iterable<LT> labels}) {
    String1D d;
    if (data is Iterable<String>) {
      d = new String1D(data);
    } else if (data is IterView<String>) {
      d = new String1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new StringSeriesView._build(madeLabels, d, name);
  }

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

  factory StringSeriesView.copy(SeriesView<LT, String> series) {}

  dynamic get name => _name is Function ? _name() : _name;

  StringSeriesView<LT> toView() => this;

  SeriesViewByPosition<LT, String> _pos;

  SeriesViewByPosition<LT, String> get byPos =>
      _pos ??= new SeriesViewByPosition<LT, String>(this);

  String max() {
    String ret;

    for (String v in data.asIterable) {
      if (v == null) continue;
      if (ret == null)
        ret = v;
      else if (ret.compareTo(v) < 0) ret = v;
    }

    return ret;
  }

  String min() {
    String ret;

    for (String v in data.asIterable) {
      if (v == null) continue;
      if (ret == null)
        ret = v;
      else if (ret.compareTo(v) > 0) ret = v;
    }

    return ret;
  }
}

abstract class StringSeriesViewMixin<LT> implements SeriesView<LT, String> {
  StringSeries<LT> toSeries() =>
      new StringSeries(data, name: name, labels: labels);

  StringSeriesView<IIT> makeView<IIT>(
          /* Iterable<String> | IterView<String> */ data,
          {dynamic name,
          List<IIT> labels}) =>
      new StringSeriesView(data, name: name, labels: labels);

  StringSeries<IIT> make<IIT>(/* Iterable<String> | IterView<String> */ data,
          {dynamic name, List<IIT> labels}) =>
      new StringSeries<IIT>(data, name: name, labels: labels);

  @override
  String1D makeVTArraySized(int size) => new String1D.sized(size);

  @override
  String1D makeVTArray(Iterable<String> data) => new String1D(data);

  @override
  int compareVT(String a, String b) => a.compareTo(b);
}
