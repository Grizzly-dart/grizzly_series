part of grizzly.series.array;

class String1D extends String1DFix implements Array<String> {
  String1D(Iterable<String> data) : super(data);

  String1D.make(List<String> data) : super.make(data);

  String1D.sized(int length, {String data: ''})
      : super.sized(length, data: data);

  String1D.shapedLike(Iterable d, {String data: ''})
      : super.sized(d.length, data: data);

  String1D.single(String data) : super.single(data);

  String1D.gen(int length, String maker(int index)) : super.gen(length, maker);

  operator []=(int i, String val) {
    if (i > _data.length) {
      throw new RangeError.range(i, 0, _data.length, 'i', 'Out of range!');
    }

    if (i == _data.length) {
      _data.add(val);
      return;
    }

    _data[i] = val;
  }

  @override
  void add(String a) => _data.add(a);

  @override
  void insert(int index, String a) => _data.insert(index, a);

  String1DFix _fixed;
  String1DFix get fixed => _fixed ??= new String1DFix.make(_data);
}
