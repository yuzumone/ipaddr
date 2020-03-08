Iterable<int> range(int low, int high) sync* {
  for (var i = low; i < high; ++i) {
    yield i;
  }
}
