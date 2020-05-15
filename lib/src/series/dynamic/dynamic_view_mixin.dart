part of grizzly.series;

abstract class DynamicSeriesViewMixin<LT> implements DynamicSeriesViewBase<LT> {
  DynamicSeries<LT> toSeries() =>
      DynamicSeries<LT>(data, name: name, labels: labels);

  DynamicSeriesView<LLT> makeView<LLT>(Iterable<dynamic> data,
          {dynamic name, Iterable<LLT> labels}) =>
      DynamicSeriesView(data, name: name, labels: labels);

  DynamicSeries<IIT> make<IIT>(Iterable<dynamic> data,
          {dynamic name, Iterable<IIT> labels}) =>
      DynamicSeries<IIT>(data, name: name, labels: labels);

  @override
  Dynamic1D makeValueArraySized(int size) => Dynamic1D.sized(size);

  @override
  Dynamic1D makeValueArray(Iterable<dynamic> data) => Dynamic1D(data);

  @override
  int compareValue(dynamic a, dynamic b) {
    throw UnimplementedError();
  }
}
