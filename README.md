# Grizzly Series

Pandas-like Series and DataFrames for Dart

## Usage

A simple usage example:

```dart
main() {
  final ages =
      new IntSeries<String>([20, 22, 35], indices: ['Jon', 'Dany', 'Tyrion']);
  final house = new StringSeries<String>(['Stark', 'Targaryan', 'Lannister'],
      indices: ['Jon', 'Dany', 'Tyrion']);

  final df = new DataFrame<String, String>(
      {'age': ages.data, 'house': house.data},
      indices: ages.indices);

  print(df['age']);
  print(df.index['Jon']);
  print(df.pos[2]);
}
```

## TODO

[ ] Series
[ ] DataFrame
[ ] Plotting
[ ] Loading data
[ ] Numpy functionality
[ ] Interactive web interface
[ ] Statistical functions

### Advanced

[ ] Linear regression
[ ] Logistic regression
[ ] Classification
