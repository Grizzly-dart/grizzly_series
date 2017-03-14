// Copyright (c) 2017, SERAGUD. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

abstract class Series<T> {
  Series add(Series a, {fillVal});
}

class IntSeries implements Series<int> {
  Series add(Series a, {fillVal}) {
    //TODO
  }
}
