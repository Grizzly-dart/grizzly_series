part of grizzly.series.array;

final math.Random _rand = new math.Random();

List<E> _sample<E>(Iterable<E> population, int k) {
  final int n = population.length;

  if (k < 0 || k > n)
    throw new ArgumentError.value(
        k, 'k', 'Must be between 0 and population.length');

  final samples = new List<E>(k);

  if (n < 1000) {
    final unpicked = new List<E>.from(population);
    for (int i = 0; i < k; i++) {
      final sampleIdx = _rand.nextInt(n - i);
      samples[i] = unpicked[sampleIdx];
      unpicked[sampleIdx] = unpicked[n - i - 1];
    }
  } else {
    final picked = new SplayTreeSet<int>();
    for (int i = 0; i < k; i++) {
      final int sampleIdx = () {
        int newIdx;
        do {
          newIdx = _rand.nextInt(n);
        } while (picked.contains(newIdx));
        return newIdx;
      }();
      picked.add(sampleIdx);
      samples[i] = population.elementAt(sampleIdx);
    }
  }

  return samples;
}
