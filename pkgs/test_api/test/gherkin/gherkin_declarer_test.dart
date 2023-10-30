// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/suite.dart';
import 'package:test_api/src/backend/test.dart';
import 'package:test_core/gherkin.dart';

import 'utils.dart';

late Suite _suite;

void main() {
  setUp(() {
    _suite = Suite(Group.root([]), suitePlatform, ignoreTimeouts: false);
  });

  group('given tests', ()
  {
    test('declares a "given" with an int argument', () async {
      var givenRun = false;
      var tests = declare(() {
        final script =
            'Feature:\n\n'
            '  Scenario:\n'
            '    Given the value 123\n'
            '    Given the value 789\n';
        final featureFile = createFeatureFile(script);
        GherkinOptions.set(
          features: featureFile
        );
        given('the value {int}', (args) {
          expect(args[0], isA<int>());
          expect(args[0] as int, 123);
        });
      });

      await _runTest(tests[0] as Test);
      expect(givenRun, isTrue);
    });
  });

  /* TODO
  test('declares a Gherkin test with description and body', () async {
    var givenRun = false,
        whenRun = false,
        thenRun = false;
    var tests = declare(() {
      given('given description', (_) {
        givenRun = true;
      });
      when('when description', (_) {
        whenRun = true;
      });
      then('then description', (_) {
        thenRun = true;
      });
    });

    expect(tests, hasLength(3));
    expect(tests[0].name, equals('given description'));
    expect(tests[1].name, equals('when description'));
    expect(tests[2].name, equals('then description'));

    await _runTest(tests[0] as Test);
    expect(givenRun, isTrue);

    await _runTest(tests[1] as Test);
    expect(whenRun, isTrue);

    await _runTest(tests[2] as Test);
    expect(thenRun, isTrue);
  });*/
}

/// Creates a feature file with a content specified in [script].
File createFeatureFile(String script) {
  final path = p.join(Directory.systemTemp.path, 'test.feature');
  final featureFile = MemoryFileSystem().file(path);
  featureFile.createSync(recursive: true);
  featureFile.writeAsStringSync(script, flush:true);
  return featureFile;
}

/// Runs [test].
///
/// This automatically sets up an `onError` listener to ensure that the test
/// doesn't throw any invisible exceptions.
Future _runTest(Test test, {bool shouldFail = false}) {
  var liveTest = test.load(_suite);

  if (shouldFail) {
    liveTest.onError.listen(expectAsync1((_) {}));
  } else {
    liveTest.onError.listen((e) => registerException(e.error, e.stackTrace));
  }

  return liveTest.run();
}
