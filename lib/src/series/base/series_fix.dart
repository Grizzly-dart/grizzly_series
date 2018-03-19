part of grizzly.series;

abstract class SeriesFixMixin<LT, VT> implements SeriesFix<LT, VT> {
  List<LT> get _labels;

  ArrayFix<VT> get _data;

  SplayTreeMap<LT, int> get _mapper;

  operator []=(LT label, VT value) {
    if (!_mapper.containsKey(label)) throw labelNotFound(label);
    _data[_mapper[label]] = value;
  }

  void set(LT label, VT value) => this[label] = value;

  void setByPos(int position, VT value) {
    if (position >= length) throw new RangeError.range(position, 0, length);
    _data[position] = value;
  }

  void assign(/* Series<LT, VT> | IterView<VT> */ other) {
    if (other is Series<LT, VT>) {
      for (LT label in other.labels) {
        if (containsLabel(label)) {
          final int sourcePos = _mapper[label];
          _data[sourcePos] = other[label];
        }
      }
    } else if (other is IterView<VT>) {
      if (length != other.length)
        throw lengthMismatch(
            expected: length, found: other.length, subject: 'other');
      for (int i = 0; i < length; i++) {
        _data[i] = other[i];
      }
    } else {
      throw new UnsupportedError('Type not supported!');
    }
  }

  void assignMap(Map<LT, VT> other) {
    for (LT label in other.keys) {
      if (containsLabel(label)) {
        final int sourcePos = _mapper[label];
        _data[sourcePos] = other[label];
      }
    }
  }

  void apply(VT func(VT value)) {
    for (int i = 0; i < length; i++) {
      _data[i] = func(_data[i]);
    }
  }
}