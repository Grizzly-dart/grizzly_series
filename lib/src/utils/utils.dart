import 'dart:collection';
import 'package:grizzly_primitives/grizzly_primitives.dart';

List<LT> makeLabels<LT>(int dataLength, List<LT> labels) {
  List<LT> madeLabels;
  if (labels == null) {
    madeLabels =
        new List<int>.generate(dataLength, (int idx) => idx) as List<LT>;
  } else {
    if (labels.length != dataLength) {
      throw lengthMismatch(
          expected: dataLength, found: labels.length, subject: 'labels');
    }
    madeLabels = labels.toList();
  }
  return madeLabels;
}

SplayTreeMap<LT, int> labelsToMapper<LT>(List<LT> labels) {
  final mapper = new SplayTreeMap<LT, int>();

  for (int i = 0; i < labels.length; i++) {
    final LT label = labels[i];
    if (mapper.containsKey(label))
      throw new Exception('Duplicate label found!');
    mapper[label] = i;
  }

  return mapper;
}
