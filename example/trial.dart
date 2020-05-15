// Copyright (c) 2017, Teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:grizzly_series/grizzly_series.dart';

main() {
  final df = DataFrame<int>({
    'num': IntSeries([1, 2, 3, 4, 5]),
  });
  print(df);
  print(df['num']);

  df['num*2'] = (df['num'] as IntSeriesView) * 2;
  print(df);

  df['english'] = ['one', 'two', 'three', 'four', 'five'];
  print(df);

  df.set<String>('swedish', ['Ett', 'Två', 'Tre', 'Fyra', 'Fem']);
  print(df);
}
