@Deprecated('package:test_core is not intended for general use. '
    'Please use package:test.')
library test_core.gherkin_scaffolding;

import 'dart:async';

import 'package:meta/meta.dart' show isTest, isTestGroup;
import 'package:path/path.dart' as p;
import 'package:test_api/backend.dart'; //ignore: deprecated_member_use
import 'package:test_api/gherkin.dart';
import 'package:test_api/scaffolding.dart' show Timeout, pumpEventQueue;
import 'package:test_api/src/backend/invoker.dart'; // ignore: implementation_imports

import '../runner/engine.dart';
import '../runner/plugin/environment.dart';
import '../runner/reporter/expanded.dart';
import '../runner/runner_suite.dart';
import '../runner/suite.dart';
import '../util/async.dart';
import '../util/os.dart';
import '../util/print_sink.dart';

/// The global declarer.
///
/// This is used if a test file is run directly, rather than through the runner.
GherkinDeclarer? _globalDeclarer;

/// Gets the declarer for the current scope.
///
/// When using the runner, this returns the [Zone]-scoped declarer that's set by
/// [RemoteListener]. If the test file is run directly, this returns
/// [_globalDeclarer] (and sets it up on the first call).
GherkinDeclarer get _declarer {
  var declarer = GherkinDeclarer.current;
  if (declarer != null) return declarer;
  if (_globalDeclarer != null) return _globalDeclarer!;

  // Since there's no Zone-scoped declarer, the test file is being run directly.
  // In order to run the tests, we set up our own Declarer via
  // [_globalDeclarer], and pump the event queue as a best effort to wait for
  // all tests to be defined before starting them.
  _globalDeclarer = GherkinDeclarer();

      () async {
    await pumpEventQueue();

    var suite = RunnerSuite(const PluginEnvironment(), SuiteConfiguration.empty,
        _globalDeclarer!.build(), SuitePlatform(Runtime.vm, os: currentOSGuess),
        path: p.prettyUri(Uri.base));

    var engine = Engine();
    engine.suiteSink.add(suite);
    engine.suiteSink.close();
    ExpandedReporter.watch(engine, PrintSink(),
        color: true, printPath: false, printPlatform: false);

    var success = await runZoned(() => Invoker.guard(engine.run),
        zoneValues: {#test.declarer: _globalDeclarer});
    if (success == true) return null;
    print('');
    unawaited(Future.error('Dummy exception to set exit code.'));
  }();

  return _globalDeclarer!;
}

@isTest
void given(description, dynamic Function(List<dynamic> args) body,
    {String? testOn,
      Timeout? timeout,
      skip,
      tags,
      Map<String, dynamic>? onPlatform,
      int? retry,
      @Deprecated('Debug only') bool solo = false})
{
  _declarer.given(description.toString(), body,
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      onPlatform: onPlatform,
      tags: tags,
      retry: retry,
      solo: solo);
}

@isTest
void when(description, dynamic Function(List<dynamic> args) body,
    {String? testOn,
      Timeout? timeout,
      skip,
      tags,
      Map<String, dynamic>? onPlatform,
      int? retry,
      @Deprecated('Debug only') bool solo = false})
{
  /* TODO
  _declarer.when(description.toString(), body,
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      onPlatform: onPlatform,
      tags: tags,
      retry: retry,
      solo: solo);*/
}

@isTest
void then(description, dynamic Function(List<dynamic> args) body,
    {String? testOn,
      Timeout? timeout,
      skip,
      tags,
      Map<String, dynamic>? onPlatform,
      int? retry,
      @Deprecated('Debug only') bool solo = false})
{
  /* TODO
  _declarer.then(description.toString(), body,
      testOn: testOn,
      timeout: timeout,
      skip: skip,
      onPlatform: onPlatform,
      tags: tags,
      retry: retry,
      solo: solo);*/
}

