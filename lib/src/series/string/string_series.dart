part of grizzly.series;

class StringSeries<LT> extends Object
    with
        SeriesViewMixin<LT, String>,
        SeriesFixMixin<LT, String>,
        SeriesMixin<LT, String>
    implements StringSeriesFix<LT>, StringSeriesBase<LT> {
  final List<LT> _labels;

  final String1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic _name;

  StringSeries._(this._labels, this._data, this._name, this._mapper);

  StringSeries._build(this._labels, this._data, this._name)
      : _mapper = labelsToMapper(_labels);

  factory StringSeries(Iterable<String> data,
      {dynamic name, Iterable<LT> labels}) {
    String1D d = String1D(data);
    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return StringSeries._build(madeLabels, d, name);
  }

  factory StringSeries.fromMap(Map<LT, String> map,
      {dynamic name, Iterable<LT> labels}) {
    // TODO take labels into account
    final labels = List<LT>()..length = map.length;
    final data = String1D.sized(map.length);
    final mapper = SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return StringSeries._(labels, data, name, mapper);
  }

  factory StringSeries.copy(SeriesView<LT, String> series,
          {name, Iterable<LT> labels}) =>
      StringSeries<LT>(series.data, name: series.name, labels: series.labels);

  Iterable<LT> get labels => _labels;

  String1DFix get data => _data.fixed;

  StringSeriesView<LT> _view;

  StringSeriesView<LT> get view =>
      _view ??= StringSeriesView<LT>._(_labels, _data, () => name, _mapper);

  StringSeriesFix<LT> _fixed;

  StringSeriesFix<LT> get fixed =>
      _fixed ??= StringSeriesFix<LT>._(_labels, _data, () => name, _mapper);

  String get name => _name is Function ? _name() : _name.toString();

  StringSeries<LT> toSeries() =>
      StringSeries<LT>(data, name: name, labels: labels);

  StringSeriesView<IIT> makeView<IIT>(Iterable<String> data,
          {dynamic name, Iterable<IIT> labels}) =>
      StringSeriesView(data, name: name, labels: labels);

  StringSeries<IIT> make<IIT>(Iterable<String> data,
          {dynamic name, Iterable<IIT> labels}) =>
      StringSeries<IIT>(data, name: name, labels: labels);

  @override
  String1D makeValueArraySized(int size) => String1D.sized(size);

  @override
  String1D makeValueArray(Iterable<String> data) => String1D(data);

  @override
  int compareValue(String a, String b) => a.compareTo(b);

  @override
  DoubleSeries<LT> toDouble(
          {double defaultValue, double onError(String source)}) =>
      DoubleSeries<LT>(
          data.toDouble(defaultValue: defaultValue, onError: onError),
          name: name,
          labels: labels);

  @override
  IntSeries<LT> toInt(
          {int radix, int defaultValue, int onError(String source)}) =>
      IntSeries<LT>(
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
