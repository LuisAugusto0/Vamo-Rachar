
class Pair<A, B> {
  final A first;
  final B second;

  const Pair(this.first, this.second);
}

class StringFunctionPair<T> {
  final String name;
  final T function; // only type to control return types. Use typedef to ensure Functions are used

  const StringFunctionPair(this.name, this.function);
}