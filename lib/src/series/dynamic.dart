part of grizzly.series;

class DynamicSeries<IT> extends Object
    with SeriesBase<IT, dynamic>
    implements Series<IT, dynamic> {
  final List<IT> _labels;

  final List<dynamic> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> labels;

  final UnmodifiableListView<dynamic> data;

  SeriesPositioned<IT, dynamic> _pos;

  SeriesPositioned<IT, dynamic> get pos => _pos;

  DynamicSeriesView<IT> _view;

  DynamicSeriesView<IT> toView() {
    if (_view == null) _view = new DynamicSeriesView<IT>(this);
    return _view;
  }

  DynamicSeries._(this._data, this._labels, this.name, this._mapper)
      : labels = new UnmodifiableListView(_labels),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, dynamic>(this);
  }

  factory DynamicSeries(Iterable<dynamic> data,
      {dynamic name, List<IT> labels}) {
    final List<IT> madeIndices = makeLabels<IT>(data.length, labels, IT);
    final mapper = labelsToPosMapper(madeIndices);

    return new DynamicSeries._(data.toList(), madeIndices, name, mapper);
  }

  factory DynamicSeries.fromMap(Map<IT, List<dynamic>> map, {dynamic name}) {
    final List<IT> indices = [];
    final List<dynamic> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (dynamic val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new DynamicSeries._(data.toList(), indices, name, mapper);
  }

  DynamicSeries<IIT> makeNew<IIT>(Iterable<dynamic> data,
          {dynamic name, List<IIT> labels}) =>
      new DynamicSeries<IIT>(data, name: name, labels: labels);

  dynamic max({bool skipNan: true}) {
    dynamic ret;
    bool seenNan = false;

    for (dynamic v in _data) {
      if (v == null) continue;
      if (v == double.NAN) {
        if (skipNan) {
          seenNan = true;
          continue;
        } else {
          return double.NAN as dynamic;
        }
      }
      if (ret == null)
        ret = v;
      else if (ret < v) ret = v;
    }

    if (ret == null && seenNan) return double.NAN as dynamic;

    return ret;
  }

  dynamic min({bool skipNan: true}) {
    dynamic ret;
    bool seenNan = false;

    for (dynamic v in _data) {
      if (v == null) continue;
      if (v == double.NAN) {
        if (skipNan) {
          seenNan = true;
          continue;
        } else {
          return double.NAN as dynamic;
        }
      }
      if (ret == null)
        ret = v;
      else if (ret > v) ret = v;
    }

    if (ret == null && seenNan) return double.NAN as dynamic;

    return ret;
  }
}

class DynamicSeriesView<IT> extends DynamicSeries<IT>
    implements SeriesView<IT, dynamic> {
  DynamicSeriesView(DynamicSeries<IT> series)
      : super._(series._data, series._labels, null, series._mapper) {
    _nameGetter = () => series.name;
  }

  Function _nameGetter;

  dynamic get name => _nameGetter();

  set name(dynamic value) {
    throw new Exception('Cannot change name of SeriesView!');
  }

  @override
  operator []=(IT index, dynamic value) {
    if (!_mapper.containsKey(index)) {
      throw new Exception('Cannot add new elements to SeriesView!');
    }

    _mapper[index].forEach((int position) {
      _data[position] = value;
    });
  }

  DynamicSeries<IT> toSeries() =>
      new DynamicSeries(_data, name: name, labels: _labels);

  DynamicSeriesView<IT> toView() => this;
}
