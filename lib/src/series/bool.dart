part of grizzly.series;

class BoolSeries<IT> extends Object
    with SeriesBase<IT, bool>
    implements Series<IT, bool> {
  final List<IT> _labels;

  final List<bool> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> labels;

  final UnmodifiableListView<bool> data;

  SeriesPositioned<IT, bool> _pos;

  SeriesPositioned<IT, bool> get pos => _pos;

  BoolSeriesView<IT> _view;

  BoolSeriesView<IT> toView() {
    if (_view == null) _view = new BoolSeriesView<IT>(this);
    return _view;
  }

  BoolSeries._(this._data, this._labels, this.name, this._mapper)
      : labels = new UnmodifiableListView(_labels),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, bool>(this);
  }

  factory BoolSeries(Iterable<bool> data, {dynamic name, List<IT> indices}) {
    final List<IT> madeIndices = makeLabels<IT>(data.length, indices, IT);
    final mapper = labelsToPosMapper(madeIndices);

    return new BoolSeries._(data.toList(), madeIndices, name, mapper);
  }

  factory BoolSeries.fromMap(Map<IT, List<bool>> map, {dynamic name}) {
    final List<IT> indices = [];
    final List<bool> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (bool val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new BoolSeries._(data.toList(), indices, name, mapper);
  }

  BoolSeries<IIT> makeNew<IIT>(Iterable<bool> data,
          {dynamic name, List<IIT> labels}) =>
      new BoolSeries<IIT>(data, name: name, indices: labels);

  bool max() {
    for (bool v in _data) {
      if (v == null) continue;
      if (v) return true;
    }

    return false;
  }

  bool min() {
    for (bool v in _data) {
      if (v == null) continue;
      if (!v) return false;
    }

    return true;
  }

  IntSeries<IT> toInt({int radix, int fillVal}) {
    return new IntSeries<IT>(_data.map((bool v) => v ? 1 : 0).toList(),
        name: name, labels: _labels.toList());
  }

  DoubleSeries<IT> toDouble({double fillVal}) {
    return new DoubleSeries<IT>(_data.map((bool v) => v ? 1.0 : 0.0).toList(),
        name: name, labels: _labels.toList());
  }
}

class BoolSeriesView<IT> extends BoolSeries<IT>
    implements SeriesView<IT, bool> {
  BoolSeriesView(BoolSeries<IT> series)
      : super._(series._data, series._labels, null, series._mapper) {
    _nameGetter = () => series.name;
  }

  Function _nameGetter;

  dynamic get name => _nameGetter();

  set name(dynamic value) {
    throw new Exception('Cannot change name of SeriesView!');
  }

  @override
  operator []=(IT index, bool value) {
    if (!_mapper.containsKey(index)) {
      throw new Exception('Cannot add new elements to SeriesView!');
    }

    _mapper[index].forEach((int position) {
      _data[position] = value;
    });
  }

  BoolSeries<IT> toSeries() =>
      new BoolSeries(_data, name: name, indices: _labels);

  @override
  BoolSeriesView<IT> toView() => this;
}
