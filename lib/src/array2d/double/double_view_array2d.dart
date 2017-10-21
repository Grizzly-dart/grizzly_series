part of grizzly.series.array2d;

class Double2DView extends Object
    with IterableMixin<ArrayView<double>>, Double2DMixin
    implements Numeric2DView<double> {
  final List<Double1DView> _data;

  Double2DView(Iterable<Iterable<double>> data) : _data = <Double1D>[] {
    if (data.length != 0) {
      final int len = data.first.length;
      for (Iterable<double> item in data) {
        if (item.length != len) {
          throw new Exception('All rows must have same number of columns!');
        }
      }

      for (Iterable<double> item in data) {
        _data.add(new Double1D(item));
      }
    }
  }

  Double2DView.make(this._data);

  Iterator<Numeric1DView<double>> get iterator => _data.iterator;

  covariant Double2DColView _col;

  Double2DColView get col => _col ??= new Double2DColView(this);

  covariant Double2DRowView _row;

  Double2DRowView get row => _row ??= new Double2DRowView(this);

  Double2DView get view => this;
}

abstract class Double2DMixin {
  List<Double1DView> get _data;

  int get length;

  Double2DColView get col;

  Double2DRowView get row;

  Double2DView get view;

  Double2DView makeView(Iterable<Iterable<double>> newData) =>
      new Double2DView(newData);

  Double2DFix makeFix(Iterable<Iterable<double>> newData) =>
      new Double2DFix(newData);

  Double2D make(Iterable<Iterable<double>> newData) => new Double2D(newData);

  int get numCols {
    if (numRows == 0) return 0;
    return _data.first.length;
  }

  int get numRows => length;

  Index2D get shape => new Index2D(numRows, numCols);

  bool get isSquare => numRows == numCols;

  Double1DView operator [](int i) => _data[i].view;

  Double2D slice(Index2D start, [Index2D end]) {
    final Index2D myShape = shape;
    if (end == null) {
      end = myShape;
    } else {
      if (end < Index2D.zero)
        throw new ArgumentError.value(end, 'end', 'Index out of range!');
      if (end >= myShape)
        throw new ArgumentError.value(end, 'end', 'Index out of range!');
      if (start > end)
        throw new ArgumentError.value(
            end, 'end', 'Must be greater than start!');
    }
    if (start < Index2D.zero)
      throw new ArgumentError.value(start, 'start', 'Index out of range!');
    if (start >= myShape)
      throw new ArgumentError.value(start, 'start', 'Index out of range!');

    final list = <Double1D>[];

    for (int c = start.row; c < end.row; c++) {
      list.add(_data[c].slice(start.column, end.column));
    }

    return new Double2D.make(list);
  }

  double get min {
    if (numRows == 0) return null;
    double min;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) min = d;
      }
    }
    return min;
  }

  double get max {
    if (numRows == 0) return null;
    double max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
      }
    }
    return max;
  }

  Extent<double> get extent {
    if (numRows == 0) return null;
    double min;
    double max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) max = d;
        if (min == null || d < min) min = d;
      }
    }
    return new Extent<double>(min, max);
  }

  Index2D get argMin {
    if (numRows == 0) return null;
    Index2D ret;
    double min;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (min == null || d < min) {
          min = d;
          ret = idx2D(i, j);
        }
      }
    }
    return ret;
  }

  Index2D get argMax {
    if (numRows == 0) return null;
    Index2D ret;
    double max;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];

        if (d == null) continue;

        if (max == null || d > max) {
          max = d;
          ret = idx2D(i, j);
        }
      }
    }
    return ret;
  }

  double get mean {
    if (numRows == 0) return 0.0;

    double sum = 0.0;
    for (int i = 0; i < numRows; i++) {
      sum += _data[i].sum;
    }

    return sum / (length * numCols);
  }

  double average(Iterable<Iterable<num>> weights) {
    if (weights.length != length) {
      throw new Exception('Weights have mismatching length!');
    }
    if (numRows == 0) return 0.0;

    final int yL = numCols;

    double sum = 0.0;
    num denom = 0.0;
    for (int i = 0; i < numRows; i++) {
      final weightsI = weights.elementAt(i);

      if (weightsI.length != yL) {
        throw new Exception('Weights have mismatching length!');
      }

      for (int j = 0; j < _data.first.length; j++) {
        final double d = _data[i][j];
        final num w = weightsI.elementAt(j);
        if (d == null) continue;
        if (w == null) continue;
        sum += d * w;
        denom += w;
      }
    }
    return sum / denom;
  }

  double get sum {
    if (numRows == 0) return 0.0;

    double sum = 0.0;
    for (int i = 0; i < numRows; i++) {
      sum += _data[i].sum;
    }

    return sum;
  }

  Double2D operator +(/* num | Iterable<num> | Numeric2DArray */ other) {
    if (other is num) {
      Double2D ret = new Double2D(_data);
      for (int r = 0; r < numRows; r++) {
        for (int c = 0; c < numCols; c++) {
          ret[r][c] += other;
        }
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != numCols)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Double2D ret = new Double2D(_data);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] + other;
      }
      return ret;
    } else if (other is Numeric2D) {
      if (shape != other.shape)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Double2D ret = new Double2D(_data);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] + other[r];
      }
      return ret;
    }

    throw new ArgumentError.value(other, 'other', 'Unsupported type!');
  }

  Double2D operator -(/* num | Iterable<num> | Numeric2DArray */ other) {
    if (other is num) {
      Double2D ret = new Double2D(_data);
      for (int r = 0; r < numRows; r++) {
        for (int c = 0; c < numCols; c++) {
          ret[r][c] -= other;
        }
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != numCols)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Double2D ret = new Double2D(_data);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] - other;
      }
      return ret;
    } else if (other is Numeric2D) {
      if (shape != other.shape)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Double2D ret = new Double2D(_data);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] - other[r];
      }
      return ret;
    }

    throw new ArgumentError.value(other, 'other', 'Unsupported type!');
  }

  Double2D operator *(/* num | Iterable<num> | Numeric2DArray */ other) {
    if (other is num) {
      Double2D ret = new Double2D(_data);
      for (int r = 0; r < numRows; r++) {
        for (int c = 0; c < numCols; c++) {
          ret[r][c] *= other;
        }
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != numCols)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Double2D ret = new Double2D(_data);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] * other;
      }
      return ret;
    } else if (other is Numeric2D) {
      return dot(other);
    }

    throw new ArgumentError.value(other, 'other', 'Unsupported type!');
  }

  Double2D operator /(/* num | Iterable<num> | Numeric2DArray */ other) {
    if (other is num) {
      Double2D ret = new Double2D(_data);
      for (int r = 0; r < numRows; r++) {
        for (int c = 0; c < numCols; c++) {
          ret[r][c] /= other;
        }
      }
      return ret;
    } else if (other is Iterable<num>) {
      if (other.length != numCols)
        throw new ArgumentError.value(other, 'other', 'Size mismatch!');
      Double2D ret = new Double2D(_data);
      for (int r = 0; r < numRows; r++) {
        ret[r] = ret[r] / other;
      }
      return ret;
    } else if (other is Numeric2D) {
      throw new ArgumentError.value(other, 'other', 'Unsupported type!');
    }

    throw new ArgumentError.value(other, 'other', 'Unsupported type!');
  }

  Double2D dot(Numeric2D other) {
    if (numCols != other.numRows)
      throw new ArgumentError.value(other, 'other', 'Invalid shape!');

    final ret = new Double2D.sized(numRows, other.numCols);

    for (int r = 0; r < ret.numRows; r++) {
      for (int c = 0; c < ret.numCols; c++) {
        ret[r][c] = _data[r].dot(other.col[c]);
      }
    }

    return ret;
  }

  Array2D<double> head([int count = 10]) {
    // TODO
    throw new UnimplementedError();
  }

  Array2D<double> tail([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  Array2D<double> sample([int count = 10]) {
    //TODO
    throw new UnimplementedError();
  }

  Double2D get transpose {
    final ret = new Double2D.sized(numCols, length);
    for (int j = 0; j < _data.first.length; j++) {
      for (int i = 0; i < numRows; i++) {
        ret[j][i] = _data[i][j];
      }
    }
    return ret;
  }

  Double1D get diagonal {
    int dim = numCols;
    if (dim > numRows) dim = numRows;

    final ret = new Double1D.sized(dim);
    for (int i = 0; i < dim; i++) {
      ret[i] = _data[i][i];
    }
    return ret;
  }

  Double2D get toDouble => new Double2D(_data);

  String toString() {
    final sb = new StringBuffer();
    //TODO print as table
    sb.writeln('Double[$numRows][$numCols] [');
    for (int r = 0; r < numRows; r++) {
      sb.write('[');
      for (int c = 0; c < numCols; c++) {
        sb.write('${_data[r][c]}\t\t');
      }
      sb.writeln('],');
    }
    sb.writeln(']');

    return sb.toString();
  }

  double get variance {
    if (numRows == 0) return 0.0;
    final double mean = this.mean;
    double sum = 0.0;
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        final double v = _data[i][j] - mean;
        sum += v * v;
      }
    }
    return sum / (numRows * numCols);
  }

  double get std => math.sqrt(variance);

  IntSeries<double> valueCounts(
      {bool sortByValue: false,
      bool ascending: false,
      bool dropNull: false,
      dynamic name: ''}) {
    final groups = new Map<double, List<int>>();
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        final double v = _data[r][c];
        if (!groups.containsKey(v)) groups[v] = <int>[0];
        groups[v][0]++;
      }
    }
    final ret = new IntSeries<double>.fromMap(groups, name: name);
    // Sort
    if (sortByValue) {
      ret.sortByIndex(ascending: ascending, inplace: true);
    } else {
      ret.sortByValue(ascending: ascending, inplace: true);
    }
    return ret;
  }

  Double2D get covMatrix {
    final ret = new Double2D.sized(numCols, numCols);
    for (int c = 0; c < numCols; c++) {
      ret[c] = col[c].covMatrix(view);
    }
    return ret;
  }

  Double2D get corrcoefMatrix {
    final ret = new Double2D.sized(numCols, numCols);
    for (int c = 0; c < numCols; c++) {
      ret[c] = col[c].corrcoefMatrix(view);
    }
    return ret;
  }

  bool isAllClose(Numeric2D v, {double absTol: 1e-8}) {
    if (v.shape != shape) return false;
    for (int i = 0; i < numRows; i++) {
      if (_data[i].isAllClose(v[i])) return false;
    }
    return true;
  }

  bool isAllCloseVector(Iterable<num> v, {double absTol: 1e-8}) {
    for (int i = 0; i < length; i++) {
      if (!_data[i].isAllClose(v, absTol: absTol)) return false;
    }
    return true;
  }

  bool isAllCloseScalar(num v, {double absTol: 1e-8}) {
    for (int i = 0; i < length; i++) {
      if (!_data[i].isAllCloseScalar(v, absTol: absTol)) return false;
    }
    return true;
  }
}
