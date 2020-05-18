part of grizzly.series;

abstract class SeriesFixMixin<LT, VT> implements SeriesFix<LT, VT> {
  SplayTreeMap<LT, int> get _mapper;

  operator []=(LT label, VT value) {
    if (!_mapper.containsKey(label)) throw labelNotFound(label);
    data[_mapper[label]] = value;
  }

  void ensureLabels(/* Labeled<LT> | Iterable<LT> */ labels) {
    if (labels is Labeled) labels = labels.labels;

    for (final label in labels) {
      if (containsLabel(label)) continue;

      throw Exception('Cannot add new label to Fixed series');
    }
  }

  void set(LT label, VT value) => this[label] = value;

  void setByPos(int position, VT value) {
    if (position >= length) throw RangeError.range(position, 0, length);
    data[position] = value;
  }

  void assign(/* Series<LT, VT> | Iterable<VT> */ other) {
    if (other is Series<LT, VT>) {
      for (LT label in other.labels) {
        if (containsLabel(label)) {
          final int sourcePos = _mapper[label];
          data[sourcePos] = other[label];
        }
      }
    } else if (other is Iterable<VT>) {
      if (length != other.length)
        throw lengthMismatch(
            expected: length, found: other.length, subject: 'other');
      for (int i = 0; i < length; i++) {
        data[i] = other.elementAt(i);
      }
    } else if (other is VT) {
      for (int i = 0; i < length; i++) {
        data[i] = other;
      }
    } else {
      throw UnsupportedError('Type not supported!');
    }
  }

  void assignMap(Map<LT, VT> other) {
    for (LT label in other.keys) {
      if (containsLabel(label)) {
        final int sourcePos = _mapper[label];
        data[sourcePos] = other[label];
      }
    }
  }

  void apply(VT func(VT value), {bool ignoreNull = true}) {
    for (int i = 0; i < length; i++) {
      if (data[i] == null) continue;
      data[i] = func(data[i]);
    }
  }

  NumericSeriesFix<LT, int> get asInt => this as NumericSeriesFix<LT, int>;

  NumericSeriesFix<LT, double> get asDouble =>
      this as NumericSeriesFix<LT, double>;

  BoolSeriesFixBase<LT> get asBool => this as BoolSeriesFixBase<LT>;

  StringSeriesFixBase<LT> get asString => this as StringSeriesFixBase<LT>;

  DynamicSeriesFixBase<LT> get asDynamic => this as DynamicSeriesFixBase<LT>;
}
