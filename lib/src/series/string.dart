part of grizzly.series;

class StringSeries<IT> extends Object
    with SeriesBase<IT, String>
    implements Series<IT, String> {
  final List<IT> _labels;

  final List<String> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> labels;

  final UnmodifiableListView<String> data;

  SeriesPositioned<IT, String> _pos;

  SeriesPositioned<IT, String> get pos => _pos;

  StringSeriesView<IT> _view;

  StringSeriesView<IT> toView() {
    if (_view == null) _view = new StringSeriesView<IT>(this);
    return _view;
  }

  StringSeries._(this._data, this._labels, this.name, this._mapper)
      : labels = new UnmodifiableListView(_labels),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, String>(this);
  }

  factory StringSeries(Iterable<String> data, {dynamic name, List<IT> labels}) {
    final List<IT> madeIndices = makeLabels<IT>(data.length, labels, IT);
    final mapper = labelsToPosMapper(madeIndices);

    return new StringSeries._(data.toList(), madeIndices, name, mapper);
  }

  factory StringSeries.fromMap(Map<IT, List<String>> map, {dynamic name}) {
    final List<IT> labels = [];
    final List<String> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (String val in map[index]) {
        labels.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new StringSeries._(data.toList(), labels, name, mapper);
  }

  StringSeries<IIT> makeNew<IIT>(Iterable<String> data,
          {dynamic name, List<IIT> labels}) =>
      new StringSeries<IIT>(data, name: name, labels: labels);

  String max() {
    String ret;

    for (String v in _data) {
      if (v == null) continue;
      if (ret == null)
        ret = v;
      else if (ret.compareTo(v) < 0) ret = v;
    }

    return ret;
  }

  String min() {
    String ret;

    for (String v in _data) {
      if (v == null) continue;
      if (ret == null)
        ret = v;
      else if (ret.compareTo(v) > 0) ret = v;
    }

    return ret;
  }

  IntSeries<IT> toInt({int radix, int fillVal}) {
    return new IntSeries<IT>(
        _data
            .map((String v) =>
                int.parse(v, radix: radix, onError: (_) => fillVal))
            .toList(),
        name: name,
        labels: _labels.toList());
  }

  DoubleSeries<IT> toDouble({double fillVal}) {
    return new DoubleSeries<IT>(
        _data.map((String v) => double.parse(v, (_) => fillVal)).toList(),
        name: name,
        labels: _labels.toList());
  }
}

class StringSeriesView<IT> extends StringSeries<IT>
    implements SeriesView<IT, String> {
  StringSeriesView(StringSeries<IT> series)
      : super._(series._data, series._labels, null, series._mapper) {
    _nameGetter = () => series.name;
  }

  Function _nameGetter;

  dynamic get name => _nameGetter();

  set name(dynamic value) {
    throw new Exception('Cannot change name of SeriesView!');
  }

  @override
  operator []=(IT index, String value) {
    if (!_mapper.containsKey(index)) {
      throw new Exception('Cannot add new elements to SeriesView!');
    }

    _mapper[index].forEach((int position) {
      _data[position] = value;
    });
  }

  StringSeries<IT> toSeries() =>
      new StringSeries(_data, name: name, labels: _labels);

  StringSeriesView<IT> toView() => this;
}
