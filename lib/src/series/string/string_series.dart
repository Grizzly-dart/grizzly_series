part of grizzly.series;

class StringSeries<LT> extends Object
    with
        SeriesViewMixin<LT, String>,
        SeriesMixin<LT, String>,
        StringSeriesViewMixin<LT>
    implements Series<LT, String> {
  final List<LT> _labels;

  final String1D _data;

  final SplayTreeMap<LT, int> _mapper;

  dynamic name;

  SeriesByPosition<LT, String> _pos;

  StringSeriesView<LT> _view;

  StringSeries._(this._labels, this._data, this.name, this._mapper);

  StringSeries._build(this._labels, this._data, this.name)
      : _mapper = labelsToMapper(_labels) {
    ;
  }

  factory StringSeries(/* Iterable<String> | IterView<String> */ data,
      {dynamic name, Iterable<LT> labels}) {
    String1D d;
    if (data is Iterable<String>) {
      d = new String1D(data);
    } else if (data is IterView<String>) {
      d = new String1D.copy(data);
    } else {
      throw new UnsupportedError('Type not supported!');
    }

    final List<LT> madeLabels = makeLabels<LT>(d.length, labels);
    return new StringSeries._build(madeLabels, d, name);
  }

  factory StringSeries.fromMap(Map<LT, String> map, {dynamic name}) {
    final labels = new List<LT>()..length = map.length;
    final data = new String1D.sized(map.length);
    final mapper = new SplayTreeMap<LT, int>();

    for (int i = 0; i < map.length; i++) {
      LT label = map.keys.elementAt(i);
      labels[i] = label;
      data[i] = map[label];
      mapper[label] = i;
    }
    return new StringSeries._(labels, data, name, mapper);
  }

  factory StringSeries.copy(SeriesView<LT, String> series) {}

  Iterable<LT> get labels => _labels;

  StringArrayView get data => _data.view;

  SeriesByPosition<LT, String> get byPos =>
      _pos ??= new SeriesByPosition<LT, String>(this);

  @override
  int compareVT(String a, String b) => a.compareTo(b);

  /* TODO
  IntSeries<LT> toInt({int radix, int fillVal}) {
    return new IntSeries<LT>(
        _data
            .map((String v) =>
                int.parse(v, radix: radix, onError: (_) => fillVal))
            .toList(),
        name: name,
        labels: _labels.toList());
  }

  DoubleSeries<LT> toDouble({double fillVal}) {
    return new DoubleSeries<LT>(
        _data.map((String v) => double.parse(v, (_) => fillVal)).toList(),
        name: name,
        labels: _labels.toList());
  }
  */

  StringSeriesView<LT> toView() =>
      _view ??= new StringSeriesView<LT>._(_labels, _data, () => name, _mapper);
}
