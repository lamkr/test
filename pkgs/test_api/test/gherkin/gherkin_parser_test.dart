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
import 'package:test_api/src/gherkin/gherkin_parser.dart';

import 'utils.dart';

late Suite _suite;

void main() {
  setUp(() {
    _suite = Suite(Group.root([]), suitePlatform, ignoreTimeouts: false);
  });

  group('GherkinParser tests', ()
  {
    test('Parse int argument from a feature file', () async {
      var givenRun = false;
      var tests = declare(() {
        final script =
            'Feature:\n\n'
            '  Scenario:\n'
            '    Given the value 123';
        final featureFile = createFeatureFile(script);
        final parser = GherkinParser(featureFile);
        final stepDescription = 'the value {int}';

        final args = parser.parseArguments(stepDescription);

        expect(args.length, 1);
        expect(args[0], isA<int>());
        expect(args[0] as int, 123);
      });

      await _runTest(tests[0] as Test);
      expect(givenRun, isTrue);
    });

    /*TODO
    test('load and extract arguments in a feature file in portuguese', () async {
      var givenRun = false;
      var tests = declare(() {
        final step =
            '# language: pt\n'
            'Funcionalidade:\n\n'
            '  Cenário:\n'
            '    Dado o valor 123';
        final featureFile = createFeatureFile(step);
        final parser = GherkinParser(featureFile);
        final stepDescription = 'o valor {int}';

        final args = parser.parseArguments(stepDescription);

        expect(args.length, 1);
        expect(args[0], isA<int>());
        expect(args[0] as int, 123);
      });

      await _runTest(tests[0] as Test);
      expect(givenRun, isTrue);
    });

    test('test string regex', () {
      final rx = RegExp('".*?"|\'.*?\'');
      final str = 'When I press the "button" or push the \'alavanca\'';
      Iterable<RegExpMatch> matches = rx.allMatches(str);
      for (final m in matches) {
        print(m[0]);
      }
      expect( 2, matches.length );
    });

    test('load and extract arguments in a feature file using GherkinOptions', () async {

    });*/
  });
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
