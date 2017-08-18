part of grizzly.series;

abstract class NumericSeries<IT, VT extends num> implements Series<IT, VT> {
  List<IT> get _indices;

  List<VT> get _data;

  SplayTreeMap<IT, List<int>> get _mapper;

  void abs() {
    for (int i = 0; i < _data.length; i++) {
      if (_data[i] != null && _data[i] < 0) _data[i] = -_data[i];
    }
  }

  VT sum({bool skipNull: true});

  BoolSeries<IT> _relOp(NumericSeries<IT, num> other, bool func(num a, num b),
      {num fillVal}) {
    if (length != other.length)
      throw new Exception('Can only compare identically labeled Series!');

    final map = new SplayTreeMap<IT, List<bool>>();

    for (IT index in _mapper.keys) {
      if (!other._mapper.containsKey(index))
        throw new Exception('Can only compare identically labeled Series!');

      final List<int> sourcePos = _mapper[index];
      final List<int> destPos = other._mapper[index];

      if (sourcePos.length != destPos.length)
        throw new Exception('Can only compare identically labeled Series!');

      map[index] = <bool>[];
      for (int pos in sourcePos) {
        final num source = _data[pos];
        final num dest = other._data[pos];
        map[index].add(func(source, dest));
      }
    }

    for (IT index in other._mapper.keys) {
      if (!_mapper.containsKey(index))
        throw new Exception('Can only compare identically labeled Series!');
    }

    return new BoolSeries<IT>.fromMap(map);
  }

  BoolSeries<IT> gt(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a > b, fillVal: fillVal);

  BoolSeries<IT> lt(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a < b, fillVal: fillVal);

  BoolSeries<IT> le(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a <= b, fillVal: fillVal);

  BoolSeries<IT> ge(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a >= b, fillVal: fillVal);

  BoolSeries<IT> ne(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a != b, fillVal: fillVal);

  BoolSeries<IT> eq(NumericSeries<IT, num> other, {num fillVal}) =>
      _relOp(other, (num a, num b) => a == b, fillVal: fillVal);

/* TODO
  NumSeries<IT> _op(NumericSeries<IT, VT> a, VT func(VT a, VT b),
      {VT fillVal, dynamic name}) {
    final mapper = new SplayTreeMap<IT, List<num>>();

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
        mapper[index] = res;
      } else {
        if (fillVal == null) {
          mapper[index] = new List<int>.filled(_mapper[index].length, null);
        } else {
          mapper[index] = _mapper[index].map((int pos) {
            num data = _data[pos];
            if (data == null) return null;
            return func(data, fillVal);
          }).toList();
        }
      }
    }

    for (IT index in a._mapper.keys) {
      if (_mapper.containsKey(index)) continue;
      mapper[index] = new List<int>.filled(a._mapper[index].length, null);
    }

    return new NumSeries<IT>.fromMap(mapper, name: name);
  }

  NumSeries<IT> add(NumericSeries<IT, VT> a, {VT fillVal, dynamic name}) =>
      _op(a, (VT opa, VT opb) => opa + opb, fillVal: fillVal, name: name);

  NumSeries<IT> sub(NumericSeries<IT, VT> a, {VT fillVal, dynamic name}) =>
      _op(a, (VT opa, VT opb) => opa - opb, fillVal: fillVal, name: name);

  NumSeries<IT> mul(NumericSeries<IT, VT> a, {VT fillVal, dynamic name}) =>
      _op(a, (VT opa, VT opb) => opa * opb, fillVal: fillVal, name: name);

  NumSeries<IT> floorDiv(NumericSeries<IT, VT> a, {VT fillVal, dynamic name}) =>
      _op(a, (VT opa, VT opb) => (opa / opb).floor(), fillVal: fillVal, name: name);
      */
}
