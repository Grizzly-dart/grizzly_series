// Copyright (c) 2017, Teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:grizzly/grizzly.dart';

main() {
  final ages =
      new IntSeries<String>([20, 22, 35], indices: ['Jon', 'Dany', 'Tyrion']);
  final house = new StringSeries<String>(['Stark', 'Targaryan', 'Lannister'],
      indices: ['Jon', 'Dany', 'Tyrion']);

  final df = new DataFrame<String, String>(
      {'age': ages.data, 'house': house.data},
      indices: ages.indices);

  print(df['age']);
  print(df.indexed('Jon'));
  print(df.pos(2));
}
