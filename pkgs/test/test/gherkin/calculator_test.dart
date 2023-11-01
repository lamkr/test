import 'dart:io';
import 'package:test/gherkin.dart';
import 'package:test/test.dart';
import 'calculator.dart';

void main() {
  late Calculator calculator;

  GherkinOptions.set(features:File('test/assets/features/calculator.feature'));

  given('I have a Calculator', (_) {
    calculator = Calculator();
  });

  when('I add {int} and {int}', (args) {
    calculator.sum(args[0] as int);
    calculator.sum(args[1] as int);
  });

  then('the sum should be {int}', (args) {
    expect(calculator.result, args[0]);
  });

  test('Faz nada, apenas para referência', () {
    expect(true, isTrue);
  });
}
