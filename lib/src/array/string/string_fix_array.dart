part of grizzly.series.array;

class String1DFix extends String1DView implements ArrayFix<String> {
  String1DFix(Iterable<String> data) : super(data);

  String1DFix.make(List<String> data) : super.make(data);

  String1DFix.sized(int length, {String data: ''})
      : super.sized(length, data: data);

  String1DFix.single(String data) : super.single(data);

  String1DFix.shapedLike(Iterable d, {String data: ''})
      : super.sized(d.length, data: data);

  String1DFix.gen(int length, String maker(int index))
      : super.gen(length, maker);

  operator []=(int i, String val) {
    if (i > _data.length) {
      throw new RangeError.range(i, 0, _data.length, 'i', 'Out of range!');
    }

    _data[i] = val;
  }

  String1DView _view;
  String1DView get view => _view ??= new String1DView.make(_data);

  String1DFix get fixed => this;
}
