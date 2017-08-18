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

  StringSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, String>(this);
  }

  factory StringSeries(Iterable<String> data,
      {dynamic name, List<IT> indices}) {
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

    return new StringSeries._(data.toList(), indices, name, mapper);
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
        _data
            .map((String v) =>
            double.parse(v, (_) => fillVal))
            .toList(),
        name: name,
        indices: _indices.toList());
  }
}
