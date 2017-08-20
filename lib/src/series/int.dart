part of grizzly.series;

class IntSeries<IT> extends Object
    with SeriesBase<IT, int>, NumericSeries<IT, int>
    implements Series<IT, int> {
  final List<IT> _indices;

  final List<int> _data;

  final SplayTreeMap<IT, List<int>> _mapper;

  dynamic name;

  final UnmodifiableListView<IT> indices;

  final UnmodifiableListView<int> data;

  SeriesPositioned<IT, int> _pos;

  SeriesPositioned<IT, int> get pos => _pos;

  IntSeriesView<IT> _view;

  IntSeriesView<IT> toView() {
    if (_view == null) _view = new IntSeriesView<IT>(this);
    return _view;
  }

  IntSeries._(this._data, this._indices, this.name, this._mapper)
      : indices = new UnmodifiableListView(_indices),
        data = new UnmodifiableListView(_data) {
    _pos = new SeriesPositioned<IT, int>(this);
  }

  factory IntSeries(Iterable<int> data, {dynamic name, List<IT> indices}) {
    List<IT> madeIndices = indices;
    if (madeIndices == null) {
      if (IT.runtimeType == int) {
        throw new Exception("Indices are required for non-int indexing!");
      }
      madeIndices =
          new List<int>.generate(data.length, (int idx) => idx) as List<IT>;
    } else {
      if (indices.length != data.length) {
        throw new Exception("Indices and data must be same length!");
      }
      madeIndices = indices.toList();
    }

    final mapper = new SplayTreeMap<IT, List<int>>();

    for (int i = 0; i < madeIndices.length; i++) {
      final IT index = madeIndices[i];
      if (mapper.containsKey(index)) {
        mapper[index].add(i);
      } else {
        mapper[index] = new List<int>()..add(i);
      }
    }

    return new IntSeries._(data.toList(), madeIndices, name, mapper);
  }

  factory IntSeries.fromMap(Map<IT, List<int>> map, {dynamic name}) {
    final List<IT> indices = [];
    final List<int> data = [];
    final mapper = new SplayTreeMap<IT, List<int>>();

    for (IT index in map.keys) {
      mapper[index] = <int>[];
      for (num val in map[index]) {
        indices.add(index);
        data.add(val);
        mapper[index].add(data.length - 1);
      }
    }

    return new IntSeries._(data.toList(), indices, name, mapper);
  }

  IntSeries<IIT> makeNew<IIT>(Iterable<int> data,
          {dynamic name, List<IIT> indices}) =>
      new IntSeries<IIT>(data, name: name, indices: indices);

  int sum({bool skipNull: true}) {
    int ret = 0;
    for (int i = 0; i < _data.length; i++) {
      if (data[i] != null)
        ret += data[i];
      else if (!skipNull) return null;
    }
    return ret;
  }

  IntSeries<IT> _op(IntSeries<IT> a, int func(int a, int b),
      {int fillVal, dynamic name}) {
    final map = new SplayTreeMap<IT, List<int>>();

    for (IT index in _mapper.keys) {
      if (a._mapper.containsKey(index)) {
        List<int> sourcePos = _mapper[index];
        List<int> destPos = a._mapper[index];

        final List<int> res = [];

        if (sourcePos.length == destPos.length) {
          for (int i = 0; i < sourcePos.length; i++) {
            final int source = _data[sourcePos[i]];
            final int dest = a._data[destPos[i]];
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
            final int source = _data[sourcePos[i]];
            for (int j = 0; j < destPos.length; j++) {
              final int dest = a._data[destPos[j]];
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
          map[index] = new List<int>.filled(_mapper[index].length, null);
        } else {
          map[index] = _mapper[index].map((int pos) {
            final int data = _data[pos];
            if (data == null) return null;
            return func(data, fillVal);
          }).toList();
        }
      }
    }

    for (IT index in a._mapper.keys) {
      if (_mapper.containsKey(index)) continue;
      map[index] = new List<int>.filled(a._mapper[index].length, null);
    }

    return new IntSeries<IT>.fromMap(map, name: name);
  }

  IntSeries<IT> add(IntSeries<IT> a, {int fillVal, dynamic name}) =>
      _op(a, (int opa, int opb) => opa + opb, fillVal: fillVal, name: name);

  IntSeries<IT> sub(IntSeries<IT> a, {int fillVal, dynamic name}) =>
      _op(a, (int opa, int opb) => opa - opb, fillVal: fillVal, name: name);

  IntSeries<IT> mul(IntSeries<IT> a, {int fillVal, dynamic name}) =>
      _op(a, (int opa, int opb) => opa * opb, fillVal: fillVal, name: name);

  IntSeries<IT> floorDiv(IntSeries<IT> a, {int fillVal, dynamic name}) =>
      _op(a, (int opa, int opb) => (opa / opb).floor(),
          fillVal: fillVal, name: name);

  IntSeries<IT> ceilDiv(IntSeries<IT> a, {int fillVal, dynamic name}) =>
      _op(a, (int opa, int opb) => (opa / opb).ceil(),
          fillVal: fillVal, name: name);

  IntSeries<IT> mod(IntSeries<IT> a, {int fillVal, dynamic name}) =>
      _op(a, (int opa, int opb) => opa % opb, fillVal: fillVal, name: name);

  IntSeries<IT> pow(IntSeries<IT> a, {int fillVal, dynamic name}) =>
      _op(a, (int opa, int opb) => math.pow(opa, opb).toInt(),
          fillVal: fillVal, name: name);

  DoubleSeries<IT> toDouble() {
    return new DoubleSeries<IT>(_data.map((int v) => v.toDouble()).toList(),
        name: name, indices: _indices.toList());
  }

  IntSeries<IT> operator +(IntSeries<IT> a) => add(a);
}

abstract class SeriesView<IT, VT> implements Series<IT, VT> {
  Series<IT, VT> toSeries();
}

class IntSeriesView<IT> extends IntSeries<IT> implements SeriesView<IT, int> {
  IntSeriesView(IntSeries<IT> series)
      : super._(series._data, series._indices, null, series._mapper) {
    _nameGetter = () => series.name;
  }

  Function _nameGetter;

  dynamic get name => _nameGetter();

  set name(dynamic value) {
    throw new Exception('Cannot change name of SeriesView!');
  }

  @override
  operator []=(IT index, int value) {
    if (!_mapper.containsKey(index)) {
      throw new Exception('Cannot add new elements to SeriesView!');
    }

    _mapper[index].forEach((int position) {
      _data[position] = value;
    });
  }

  void append(IT index, int value) {
    throw new Exception('Cannot add new elements to SeriesView!');
  }

  IntSeries<IT> sortByValue({bool ascending: true, bool inplace: false, name}) {
    if (inplace) throw new Exception('Cannot sort SeriesView!');
    return sortByValue(ascending: ascending, name: name);
  }

  IntSeries<IT> sortByIndex({bool ascending: true, bool inplace: false, name}) {
    if (inplace) throw new Exception('Cannot sort SeriesView!');
    return sortByIndex(ascending: ascending, name: name);
  }

  IntSeries<IT> toSeries() =>
      new IntSeries(_data, name: name, indices: _indices);

  @override
  IntSeriesView<IT> toView() => this;
}
