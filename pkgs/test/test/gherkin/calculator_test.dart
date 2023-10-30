import 'dart:io';

import 'package:test/test.dart';
import 'package:test_core/gherkin.dart';

import 'calculator.dart';

void main() {
  var calculator = Calculator();

  GherkinOptions.set(features:File('test/assets/features/calculator.feature'));

  given('I have a Calculator', (_) {
  });

  when('I add 1 and 1', (args) {
    calculator.sum(args[0] as int);
    calculator.sum(args[1] as int);
  });

  then('the sum should be 2', (args) {
    expect(calculator.result, args[0]);
  });
}
