part of grizzly.series.array;

class Bool1DFix extends Bool1DView implements ArrayFix<bool> {
  Bool1DFix(Iterable<bool> data) : super(data);

  Bool1DFix.make(List<bool> data) : super.make(data);

  Bool1DFix.sized(int length, {bool data: false})
      : super.sized(length, data: data);

  Bool1DFix.single(bool data) : super.single(data);

  Bool1DFix.shapedLike(Iterable d, {bool data: false})
      : super.sized(d.length, data: data);

  Bool1DFix.gen(int length, bool maker(int index)) : super.gen(length, maker);

  operator []=(int i, bool val) {
    if (i > _data.length) {
      throw new RangeError.range(i, 0, _data.length, 'i', 'Out of range!');
    }

    _data[i] = val;
  }

  Bool1DView _view;
  Bool1DView get view => _view ??= new Bool1DView.make(_data);

  Bool1DFix get fixed => this;
}
