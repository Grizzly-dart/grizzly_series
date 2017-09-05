part of grizzly.series;

class StringSeries<IT> extends Object
    with SeriesBase<IT, String>
    implements Series<IT, String> {
  final List<IT> _indices;

  final List<String> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> indices;

  final UnmodifiableListView<String> data;

  SeriesPositioned<IT, String> _pos;

  SeriesPositioned<IT, String> get pos => _pos;

  StringSeriesView<IT> _view;

  StringSeriesView<IT> toView() {
    if (_view == null) _view = new StringSeriesView<IT>(this);
    return _view;
  }

  StringSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, String>(this);
  }

  factory StringSeries(Iterable<String> data,
      {dynamic name, List<IT> indices}) {
    final List<IT> madeIndices = makeIndices<IT>(data.length, indices, IT);
    final mapper = indicesToPosMapper(madeIndices);

    return new StringSeries._(data.toList(), madeIndices, name, mapper);
  }

  factory StringSeries.fromMap(Map<IT, List<String>> map, {dynamic name}) {
    final List<IT> indices = [];
    final List<String> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (String val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new StringSeries._(data.toList(), indices, name, mapper);
  }

  StringSeries<IIT> makeNew<IIT>(Iterable<String> data,
          {dynamic name, List<IIT> indices}) =>
      new StringSeries<IIT>(data, name: name, indices: indices);

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
        indices: _indices.toList());
  }

  DoubleSeries<IT> toDouble({double fillVal}) {
    return new DoubleSeries<IT>(
        _data.map((String v) => double.parse(v, (_) => fillVal)).toList(),
        name: name,
        indices: _indices.toList());
  }
}

class StringSeriesView<IT> extends StringSeries<IT>
    implements SeriesView<IT, String> {
  StringSeriesView(StringSeries<IT> series)
      : super._(series._data, series._indices, null, series._mapper) {
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
      new StringSeries(_data, name: name, indices: _indices);

  StringSeriesView<IT> toView() => this;
}
