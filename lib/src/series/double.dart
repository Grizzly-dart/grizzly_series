part of grizzly.series;

class DoubleSeries<IT> extends Object
    with SeriesBase<IT, double>, NumericSeries<IT, double>
    implements Series<IT, double> {
  final List<IT> _indices;

  final List<double> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> indices;

  final UnmodifiableListView<double> data;

  SeriesPositioned<IT, double> _pos;

  SeriesPositioned<IT, double> get pos => _pos;

  DoubleSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, double>(this);
  }

  factory DoubleSeries(Iterable<double> data, {dynamic name, List<IT> indices}) {
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

    return new DoubleSeries._(data.toList(), indices, name, mapper);
  }

  factory DoubleSeries.fromMap(Map<IT, List<double>> map, {dynamic name}) {
    final List<IT> indices = [];
    final List<double> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (double val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new DoubleSeries._(data.toList(), indices, name, mapper);
  }

  double sum({bool skipNull: true}) {
    double ret = 0.0;
    for (int i = 0; i < _data.length; i++) {
      if (data[i] != null)
        ret += data[i];
      else if (!skipNull) return null;
    }
    return ret;
  }

  DoubleSeries<IT> _op<VVT extends num>(
      NumericSeries<IT, VVT> a, num func(double a, num b),
      {int fillVal, dynamic name}) {
    final map = new SplayTreeMap<IT, List<double>>();

    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        List<int> sourcePos = _mapper[index];
        List<int> destPos = a._mapper[index];

        final List<double> res = [];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final double source = _data[sourcePos[i]];
            final num dest = a._data[destPos[i]];
            if (source == null)
              res.add(null);
            else if (dest == null) {
              if (fillVal == null)
                res.add(null);
              else
                res.add(func(source, fillVal));
            } else
              res.add(func(source, dest));
          }
        } else {
          for (int i = 0; i < sourcePos.length; i++) {
            final double source = _data[sourcePos[i]];
            for (int j = 0; j < destPos.length; j++) {
              final num dest = a._data[destPos[j]];
              if (source == null)
                res.add(null);
              else if (dest == null) {
                if (fillVal == null)
                  res.add(null);
                else
                  res.add(func(source, fillVal));
              } else
                res.add(func(source, dest));
            }
          }
        }
        map[index] = res;
      } else {
        if (fillVal == null) {
          map[index] = new List<double>.filled(_mapper[index].length, null);
        } else {
          map[index] = _mapper[index].map((int pos) {
            final double data = _data[pos];
            if (data == null) return null;
            return func(data, fillVal);
          }).toList();
        }
      }
    }

    for (IT index in a._mapper.keys) {
      if (_mapper.containsKey(index)) continue;
      map[index] = new List<double>.filled(a._mapper[index].length, null);
    }

    return new DoubleSeries<IT>.fromMap(map, name: name);
  }

  DoubleSeries<IT> add<VVT extends num>(NumericSeries<IT, VVT> a,
      {int fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => opa + opb, fillVal: fillVal, name: name);

  DoubleSeries<IT> sub<VVT extends num>(NumericSeries<IT, VVT> a,
      {int fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => opa - opb, fillVal: fillVal, name: name);

  DoubleSeries<IT> mul<VVT extends num>(NumericSeries<IT, VVT> a,
      {int fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => opa * opb, fillVal: fillVal, name: name);

  DoubleSeries<IT> div<VVT extends num>(NumericSeries<IT, VVT> a,
      {int fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => opa / opb, fillVal: fillVal, name: name);

  DoubleSeries<IT> floorDiv<VVT extends num>(NumericSeries<IT, VVT> a,
      {int fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => (opa / opb).floor(),
          fillVal: fillVal, name: name);

  DoubleSeries<IT> ceilDiv<VVT extends num>(NumericSeries<IT, VVT> a,
      {int fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => (opa / opb).ceil(),
          fillVal: fillVal, name: name);

  DoubleSeries<IT> mod<VVT extends num>(NumericSeries<IT, VVT> a,
      {int fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => opa % opb, fillVal: fillVal, name: name);

  DoubleSeries<IT> pow<VVT extends num>(NumericSeries<IT, VVT> a,
      {int fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => math.pow(opa, opb),
          fillVal: fillVal, name: name);

  IntSeries<IT> toInt() {
    return new IntSeries<IT>(_data.map((double v) => v.toInt()).toList(),
        name: name, indices: _indices.toList());
  }
}