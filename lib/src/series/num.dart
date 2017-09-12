part of grizzly.series;

class NumSeries<IT> extends Object
    with SeriesBase<IT, num>, NumericSeries<IT, num>
    implements Series<IT, num> {
  final List<IT> _labels;

  final List<num> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> labels;

  final UnmodifiableListView<num> data;

  SeriesPositioned<IT, num> _pos;

  SeriesPositioned<IT, num> get pos => _pos;

  NumSeriesView<IT> _view;

  NumSeriesView<IT> toView() {
    if (_view == null) _view = new NumSeriesView<IT>(this);
    return _view;
  }

  NumSeries._(this._data, this._labels, this.name, this._mapper)
      : labels = new UnmodifiableListView(_labels),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, num>(this);
  }

  factory NumSeries(Iterable<num> data, {dynamic name, List<IT> labels}) {
    final List<IT> madeIndices = makeLabels<IT>(data.length, labels, IT);
    final SplayTreeMap<IT, List<int>> mapper = labelsToPosMapper(madeIndices);

    return new NumSeries._(data.toList(), madeIndices, name, mapper);
  }

  factory NumSeries.fromMap(Map<IT, List<num>> map, {dynamic name}) {
    final List<IT> labels = [];
    final List<num> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (num val in map[index]) {
        labels.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new NumSeries._(data.toList(), labels, name, mapper);
  }

  NumSeries<IIT> makeNew<IIT>(Iterable<num> data,
          {dynamic name, List<IIT> labels}) =>
      new NumSeries<IIT>(data, name: name, labels: labels);

  num sum({bool skipNull: true}) {
    num ret = 0;
    for (int i = 0; i < _data.length; i++) {
      if (data[i] != null)
        ret += data[i];
      else if (!skipNull) return null;
    }
    return ret;
  }

  NumSeries<IT> _op<VVT extends num>(
      NumericSeries<IT, VVT> a, num func(num a, num b),
      {num fillVal, dynamic name}) {
    final map = new SplayTreeMap<IT, List<num>>();

    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        List<int> sourcePos = _mapper[index];
        List<int> destPos = a._mapper[index];

        final List<num> res = [];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final num source = _data[sourcePos[i]];
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
            final num source = _data[sourcePos[i]];
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
          map[index] = new List<num>.filled(_mapper[index].length, null);
        } else {
          map[index] = _mapper[index].map((int pos) {
            final num data = _data[pos];
            if (data == null) return null;
            return func(data, fillVal);
          }).toList();
        }
      }
    }

    for (IT index in a._mapper.keys) {
      if (_mapper.containsKey(index)) continue;
      map[index] = new List<num>.filled(a._mapper[index].length, null);
    }

    return new NumSeries<IT>.fromMap(map, name: name);
  }

  NumSeries<IT> add<VVT extends num>(NumericSeries<IT, VVT> a,
          {num fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => opa + opb, fillVal: fillVal, name: name);

  NumSeries<IT> sub<VVT extends num>(NumericSeries<IT, VVT> a,
          {num fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => opa - opb, fillVal: fillVal, name: name);

  NumSeries<IT> mul<VVT extends num>(NumericSeries<IT, VVT> a,
          {num fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => opa * opb, fillVal: fillVal, name: name);

  NumSeries<IT> div<VVT extends num>(NumericSeries<IT, VVT> a,
          {num fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => opa / opb, fillVal: fillVal, name: name);

  NumSeries<IT> floorDiv<VVT extends num>(NumericSeries<IT, VVT> a,
          {num fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => (opa / opb).floor(),
          fillVal: fillVal, name: name);

  NumSeries<IT> ceilDiv<VVT extends num>(NumericSeries<IT, VVT> a,
          {num fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => (opa / opb).ceil(),
          fillVal: fillVal, name: name);

  NumSeries<IT> mod<VVT extends num>(NumericSeries<IT, VVT> a,
          {num fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => opa % opb, fillVal: fillVal, name: name);

  NumSeries<IT> pow<VVT extends num>(NumericSeries<IT, VVT> a,
          {num fillVal, dynamic name}) =>
      _op(a, (num opa, num opb) => math.pow(opa, opb),
          fillVal: fillVal, name: name);

  IntSeries<IT> toInt() {
    return new IntSeries<IT>(_data.map((num v) => v.toInt()).toList(),
        name: name, labels: _labels.toList());
  }

  DoubleSeries<IT> toDouble() {
    return new DoubleSeries<IT>(_data.map((num v) => v.toDouble()).toList(),
        name: name, labels: _labels.toList());
  }
}

class NumSeriesView<IT> extends NumSeries<IT> implements SeriesView<IT, num> {
  NumSeriesView(NumSeries<IT> series)
      : super._(series._data, series._labels, null, series._mapper) {
    _nameGetter = () => series.name;
  }

  Function _nameGetter;

  dynamic get name => _nameGetter();

  set name(dynamic value) {
    throw new Exception('Cannot change name of SeriesView!');
  }

  @override
  operator []=(IT index, num value) {
    if (!_mapper.containsKey(index)) {
      throw new Exception('Cannot add new elements to SeriesView!');
    }

    _mapper[index].forEach((int position) {
      _data[position] = value;
    });
  }

  NumSeries<IT> toSeries() =>
      new NumSeries(_data, name: name, labels: _labels);

  NumSeriesView<IT> toView() => this;
}
