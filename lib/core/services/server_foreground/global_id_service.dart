sealed class GlobalIdService {
  static int _counter = 1;

  static int get newId => _counter++;
}
