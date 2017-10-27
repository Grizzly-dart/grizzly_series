part of grizzly.series.array;

class String1DView extends Object
    with IterableMixin<String>
    implements ArrayView<String> {
  List<String> _data;

  String1DView(Iterable<String> data) : _data = new List<String>.from(data);

  String1DView.make(this._data);

  String1DView.sized(int length, {String data: ''})
      : _data = new List<String>(length) {
    for (int i = 0; i < length; i++) {
      _data[i] = data;
    }
  }

  factory String1DView.shapedLike(Iterable d, {String data: ''}) =>
      new String1DView.sized(d.length, data: data);

  String1DView.single(String data) : _data = new List<String>(1) {
    _data[0] = data;
  }

  String1DView.gen(int length, String maker(int index))
      : _data = new List<String>(length) {
    for (int i = 0; i < length; i++) {
      _data[i] = maker(i);
    }
  }

  @override
  String1DView makeView(Iterable<String> newData) => new String1DView(newData);

  String1DFix makeFix(Iterable<String> newData) => new String1DFix(newData);

  String1D makeArray(Iterable<String> newData) => new String1D(newData);

  Iterator<String> get iterator => _data.iterator;

  Index1D get shape => new Index1D(_data.length);

  String operator [](int i) => _data[i];

  String1D slice(int start, [int end]) =>
      new String1D(_data.sublist(start, end));

  String get min {
    String ret;
    for (int i = 0; i < _data.length; i++) {
      final String d = _data[i];
      if (d == null) continue;
      if (ret == null || d.compareTo(ret) < 0) ret = d;
    }
    return ret;
  }

  String get max {
    String ret;
    for (int i = 0; i < _data.length; i++) {
      final String d = _data[i];
      if (d == null) continue;
      if (ret == null || d.compareTo(ret) > 0) ret = d;
    }
    return ret;
  }

  int get argMin {
    int ret;
    String min;
    for (int i = 0; i < _data.length; i++) {
      final String d = _data[i];
      if (d == null) continue;
      if (min == null || d.compareTo(min) < 0) {
        min = d;
        ret = i;
      }
    }
    return ret;
  }

  int get argMax {
    int ret;
    String max;
    for (int i = 0; i < _data.length; i++) {
      final String d = _data[i];
      if (d == null) continue;
      if (max == null || d.compareTo(max) > 0) {
        max = d;
        ret = i;
      }
    }
    return ret;
  }

  IntPair<String> pairAt(int index) => intPair<String>(index, _data[index]);

  Iterable<IntPair<String>> enumerate() =>
      Ranger.indices(_data.length).map((i) => intPair<String>(i, _data[i]));

  /// Returns a new  [Int1D] containing first [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  String1D head([int count = 10]) {
    if (length <= count) return makeArray(_data);
    return makeArray(_data.sublist(0, count));
  }

  /// Returns a new  [Int1D] containing last [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  String1D tail([int count = 10]) {
    if (length <= count) return makeArray(_data);
    return makeArray(_data.sublist(length - count));
  }

  /// Returns a new  [Array] containing random [count] elements of this array
  ///
  /// If the length of the array is shorter than [count], all elements are
  /// returned
  String1D sample([int count = 10]) => makeArray(_sample<String>(_data, count));

  String2D to2D() => new String2D.make([new String1D(_data)]);

  String2D repeat({int repeat: 1, bool transpose: false}) {
    if (!transpose) {
      return new String2D.repeatColumn(_data, repeat + 1);
    } else {
      return new String2D.repeatRow(_data, repeat + 1);
    }
  }

  String2D get transpose {
    final ret = new String2D.sized(length, 1);
    for (int i = 0; i < length; i++) {
      ret[i][0] = _data[i];
    }
    return ret;
  }

  bool operator ==(other) {
    if (other is! Array<int>) return false;

    if (other is Array<int>) {
      if (length != other.length) return false;
      for (int i = 0; i < length; i++) {
        if (_data[i] != other[i]) return false;
      }
      return true;
    }

    return false;
  }

  String1DView get view => this;

  @override
  IntSeries<String> valueCounts(
      {bool sortByValue: false,
      bool ascending: false,
      bool dropNull: false,
      dynamic name: ''}) {
    final groups = new Map<String, List<int>>();

    for (int i = 0; i < length; i++) {
      final String v = _data[i];
      if (!groups.containsKey(v)) groups[v] = <int>[0];
      groups[v][0]++;
    }

    final ret = new IntSeries<String>.fromMap(groups, name: name);
    // Sort
    if (sortByValue) {
      ret.sortByIndex(ascending: ascending, inplace: true);
    } else {
      ret.sortByValue(ascending: ascending, inplace: true);
    }

    return ret;
  }
}
