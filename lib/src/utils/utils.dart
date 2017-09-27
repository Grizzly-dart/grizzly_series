import 'dart:collection';

List<IT> makeLabels<IT>(int dataLength, List<IT> indices, Type itType) {
  if (dataLength == 0) return <IT>[];

  List<IT> madeIndices;
  if (indices == null) {
    if (itType != int) {
      throw new Exception("Indices are required for non-int indexing!");
    }
    madeIndices =
        new List<int>.generate(dataLength, (int idx) => idx) as List<IT>;
  } else {
    if (indices.length != dataLength) {
      throw new Exception("Indices and data must be same length!");
    }
    madeIndices = indices.toList();
  }

  return madeIndices;
}

SplayTreeMap<IT, List<int>> labelsToPosMapper<IT>(List<IT> indices) {
  final mapper = new SplayTreeMap<IT, List<int>>();

  for (int i = 0; i < indices.length; i++) {
    final IT index = indices[i];
    if (mapper.containsKey(index)) {
      mapper[index].add(i);
    } else {
      mapper[index] = new List<int>()..add(i);
    }
  }

  return mapper;
}

void sortList(List list, bool ascending) {
  dynamic firstVal = list.firstWhere((v) => v != null, orElse: () => null);
  if (firstVal == null) return;

  if (firstVal is Comparable) {
    if (ascending) {
      (list as List<Comparable>)
          .sort((Comparable a, Comparable b) => a.compareTo(b));
    } else {
      (list as List<Comparable>)
          .sort((Comparable a, Comparable b) => b.compareTo(a));
    }
  } else if (firstVal is bool) {
    if (ascending) {
      (list as List<bool>)
          .sort((bool a, bool b) => a == b ? 0 : a == true ? 1 : -1);
    } else {
      (list as List<bool>)
          .sort((bool a, bool b) => a == b ? 0 : b == true ? 1 : -1);
    }
  } else {
    throw new Exception('Can only sort Comparable!');
  }
}

class SeriesValueSortItem<IT, VT>
    implements Comparable<SeriesValueSortItem<IT, VT>> {
  final IT label;

  final VT value;

  SeriesValueSortItem(this.label, this.value);

  int compareTo(SeriesValueSortItem<IT, VT> other) =>
      SeriesValueSortItem.compare<IT, VT>(this, other);

  static int compare<IT, VT>(
      SeriesValueSortItem<IT, VT> first, SeriesValueSortItem<IT, VT> second) {
    if (first.value != null) {
      if (first.value is! Comparable)
        throw new Exception('Can only compare Comparable values!');
    } else {
      if (second.value != null) {
        if (second.value is! Comparable)
          throw new Exception('Can only compare Comparable values!');
      } else {
        return 0;
      }
    }
    return (first.value as Comparable<VT>).compareTo(second.value);
  }
}
