// Copyright (c) 2017, Teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:tandas/tandas.dart';

main() {
  {
    final series1 =
        new IntSeries<int>([1, 2, 3, 4, 5], indices: [1, 2, 3, 4, 4]);
    final series2 = new IntSeries<int>([10, 20, 30], indices: [1, 2, 3]);
    print(series1.add(series2, fillVal: 100));
  }
}
