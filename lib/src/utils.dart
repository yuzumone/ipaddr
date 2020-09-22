Iterable<int> range(int low, int high) sync* {
  for (var i = low; i < high; ++i) {
    yield i;
  }
}

Iterable<int> stepRange(int a, [int stop, int step]) {
  int start;

  if (stop == null) {
    start = 0;
    stop = a;
  } else {
    start = a;
  }

  if (step == 0) {
    throw Exception('Step cannot be 0');
  }

  if (step == null) {
    start < stop ? step = 1 : step = -1;
  }

  return start < stop == step > 0
      ? List<int>.generate(
          ((start - stop) / step).abs().ceil(), (int i) => start + (i * step))
      : [];
}
