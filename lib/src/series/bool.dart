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

  IntSeries<IT> toInt({int radix, int fillVal}) {
    return new IntSeries<IT>(_data.map((bool v) => v ? 1 : 0).toList(),
        name: name, indices: _indices.toList());
  }

  DoubleSeries<IT> toDouble({double fillVal}) {
    return new DoubleSeries<IT>(_data.map((bool v) => v ? 1.0 : 0.0).toList(),
        name: name, indices: _indices.toList());
  }
}
