// Copyright (c) 2017, Teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:math';
import 'package:grizzly_series/grizzly_series.dart';

main() {
  final df = new DataFrame<int>({
    'num': new IntSeries([0, 1, 2, 3, 4]),
  });
  print(df);
  // print(df['num']);

  // df['num*2'] = (df['num'] as ) * 2;
}