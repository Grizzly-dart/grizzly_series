// Copyright (c) 2017, Teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:grizzly/grizzly.dart';

main() {
  /* TODO
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
  */

  /* TODO
  final s1 = new IntSeries<String>([1, 2, 3, 4], indices: ['one', 'two', 'three', 'four']);
  final s2 = new IntSeries<String>([1, 2, 3, 4], indices: ['one', 'three', 'four', 'two']);

  final IntSeries<String> s3 = s1 + s2;

  print(s3['one']);
  print(s3['two']);
  print(s3['three']);
  print(s3['four']);

  print(s3.indices);
  */

  /* TODO
  final s1 = new IntSeries<String>([1, 2, 1, 4], indices: ['A', 'B', 'C', 'D']);
  final g1 = s1.groupByMapping({2: [0, 1], 1: [2, 3]});
  print(g1.count(name: 'Count'));
  print(g1.max(name: 'Maxed'));
  print(g1.groups);
  print(g1.indices);

  final g2 = s1.groupByValue();

  print(g2.count(name: 'Count'));
  print(g2.max(name: 'Maxed'));
  print(g2.groups);
  print(g2.indices);

  final s2 = new IntSeries<int>([2, 2, 1, 1], indices: [0, 1, 2, 3]);

  final g3 = s1.groupBySeries(s2);

  print(g3.count(name: 'Count'));
  print(g3.max(name: 'Maxed'));
  print(g3.groups);
  print(g3.indices);
  */

  final s1 = new IntSeries<String>([2, 4, 2, 1, 4],
      indices: ['A', 'B', 'C', 'D', 'E']);
  print(s1.valueCounts(sortByValue: true));
  print(s1.valueCounts(sortByValue: true, ascending: true));
  print(s1.valueCounts());
  print(s1.valueCounts(ascending: true));

  print(s1.mode());

  final ret = new DataFrame<int, String>({
    'one': [1, 2, 1, 2],
    'two': ['five', 'two', 'two', 'four']
  });
  print(ret.mode());
}
