part of grizzly.series;

class BoolSeries<IT> extends Object
    with SeriesBase<IT, bool>
    implements Series<IT, bool> {
  final List<IT> _indices;

  final List<bool> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> indices;

  final UnmodifiableListView<bool> data;

  SeriesPositioned<IT, bool> _pos;

  SeriesPositioned<IT, bool> get pos => _pos;

  BoolSeriesView<IT> _view;

  BoolSeriesView<IT> toView() {
    if (_view == null) _view = new BoolSeriesView<IT>(this);
    return _view;
  }

  BoolSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, bool>(this);
  }

  factory BoolSeries(Iterable<bool> data, {dynamic name, List<IT> indices}) {
    if (indices == null) {
      if (IT.runtimeType == int) {
        throw new Exception("Indices are required for non-int indexing!");
      }
      indices =
          new List<int>.generate(data.length, (int idx) => idx) as List<IT>;
    } else {
      if (indices.length != data.length) {
        throw new Exception("Indices and data must be same length!");
      }
    }

    final mapper = new SplayTreeMap<IT, List<int>>();

    for (int i = 0; i < indices.length; i++) {
      final IT index = indices[i];
      if (mapper.containsKey(index)) {
        mapper[index].add(i);
      } else {
        mapper[index] = new List<int>()..add(i);
      }
    }

    return new BoolSeries._(data.toList(), indices, name, mapper);
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
      {dynamic name, List<IIT> indices}) =>
      new BoolSeries<IIT>(data, name: name, indices: indices);

  bool max() {
    for(bool v in _data) {
      if(v == null) continue;
      if(v) return true;
    }

    return false;
  }

  bool min() {
    for(bool v in _data) {
      if(v == null) continue;
      if(!v) return false;
    }

    return true;
  }

  IntSeries<IT> toInt({int radix, int fillVal}) {
    return new IntSeries<IT>(_data.map((bool v) => v ? 1 : 0).toList(),
        name: name, indices: _indices.toList());
  }

  DoubleSeries<IT> toDouble({double fillVal}) {
    return new DoubleSeries<IT>(_data.map((bool v) => v ? 1.0 : 0.0).toList(),
        name: name, indices: _indices.toList());
  }
}

class BoolSeriesView<IT> extends BoolSeries<IT> implements SeriesView<IT, bool> {
  BoolSeriesView(BoolSeries<IT> series)
      : super._(series._data, series._indices, null, series._mapper) {
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

  void append(IT index, bool value) {
    throw new Exception('Cannot add new elements to SeriesView!');
  }

  BoolSeries<IT> sortByValue(
      {bool ascending: true, bool inplace: false, name}) {
    if (inplace) throw new Exception('Cannot sort SeriesView!');
    return sortByValue(ascending: ascending, name: name);
  }

  BoolSeries<IT> sortByIndex(
      {bool ascending: true, bool inplace: false, name}) {
    if (inplace) throw new Exception('Cannot sort SeriesView!');
    return sortByIndex(ascending: ascending, name: name);
  }

  BoolSeries<IT> toSeries() =>
      new BoolSeries(_data, name: name, indices: _indices);

  @override
  BoolSeriesView<IT> toView() => this;
}
