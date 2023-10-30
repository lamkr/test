class Calculator {
  int _result = 0;

  int get result => _result;

  void sum(int value) {
    _result += value;
  }
}