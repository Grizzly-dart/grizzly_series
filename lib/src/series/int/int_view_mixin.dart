part of grizzly.series;

abstract class IntSeriesViewMixin<LT> implements NumericSeriesView<LT, int> {
  IntSeries<LT> toSeries() => new IntSeries(data, name: name, labels: labels);

  IntSeriesView<IIT> makeView<IIT>(
          /* Iterable<int> | IterView<int> */ data,
          {dynamic name,
          List<IIT> labels}) =>
      new IntSeriesView(data, name: name, labels: labels);

  IntSeries<IIT> make<IIT>(/* Iterable<String> | IterView<String> */ data,
          {dynamic name, List<IIT> labels}) =>
      new IntSeries<IIT>(data, name: name, labels: labels);

  @override
  Int1D makeVTArraySized(int size) => new Int1D.sized(size);

  @override
  Int1D makeVTArray(Iterable<int> data) => new Int1D(data);

  @override
  int compareVT(int a, int b) => a.compareTo(b);

  int get max => data.max;

  int get min => data.min;

  int get sum => data.sum;

  int get prod => data.prod;

  double average(Iterable<num> weights) => data.average(weights);

  double get variance => data.variance;

  double get std => data.std;

  NumericSeries<LT, double> get log =>
      new DoubleSeries(data.log, name: name, labels: labels);

  NumericSeries<LT, double> get log10 =>
      new DoubleSeries(data.log10, name: name, labels: labels);

  NumericSeries<LT, double> logN(num n) =>
      new DoubleSeries(data.logN(n), name: name, labels: labels);

  NumericSeries<LT, double> get exp =>
      new DoubleSeries(data.exp, name: name, labels: labels);

  NumericSeries<LT, double> get abs =>
      new DoubleSeries(data.abs, name: name, labels: labels);

  DoubleSeries<LT> get toDouble =>
      new DoubleSeries<LT>(data.toDouble, name: name, labels: labels.toList());

  IntSeries<LT> get toInt =>
      new IntSeries<LT>(data, name: name, labels: labels.toList());
}
