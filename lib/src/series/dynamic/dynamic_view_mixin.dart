part of grizzly.series;

abstract class DynamicSeriesViewMixin<LT> implements DynamicSeriesViewBase<LT> {
  DynamicSeries<LT> toSeries() =>
      new DynamicSeries<LT>(data, name: name, labels: labels);

  DynamicSeriesView<LLT> makeView<LLT>(
          /* Iterable<LLT> | IterView<LLT> */ data,
          {dynamic name,
          Iterable<LLT> labels}) =>
      new DynamicSeriesView(data, name: name, labels: labels);

  DynamicSeries<IIT> make<IIT>(/* Iterable<dynamic> | IterView<dynamic> */ data,
          {dynamic name, Iterable<IIT> labels}) =>
      new DynamicSeries<IIT>(data, name: name, labels: labels);

  @override
  Dynamic1D makeValueArraySized(int size) => new Dynamic1D.sized(size);

  @override
  Dynamic1D makeValueArray(Iterable<dynamic> data) => new Dynamic1D(data);

  @override
  int compareVT(dynamic a, dynamic b) {
    throw new UnimplementedError();
  }
}
