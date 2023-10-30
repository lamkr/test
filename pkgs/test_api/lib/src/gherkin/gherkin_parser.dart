import 'dart:convert';
import 'dart:io';

import 'package:gherkin/core.dart';
import 'package:gherkin/helpers.dart';
import 'package:gherkin/language.dart';
import 'package:gherkin/parser.dart';
import 'package:gherkin/tokens.dart';
import 'package:path/path.dart';

class GherkinParser
{
  late final languages = _loadGherkinLanguagesFromJsonAsset();
  late final dialectProvider = GherkinDialectProvider(languages);
  late final idGenerator = IdGenerator.incrementingGenerator;
  //late final docBuilder = GherkinDocumentBuilder(idGenerator);
  //late final docParser = Parser<GherkinDocument>(docBuilder);
  late final matcher = TokenMatcher(dialectProvider);
  late final List<String> tokens;
  //late final GherkinDocument doc;

  final File feature;

  GherkinParser(this.feature) {
    var tokenFormatterBuilder = TokenFormatterBuilder();
    var tokenParser = Parser<object>(tokenFormatterBuilder);
    var tokenScanner = FileTokenScanner(feature);
    tokenParser.parse(tokenScanner, matcher);
    var tokensText = tokenFormatterBuilder.getTokensText();
    tokens = LineEndingHelper.normalizeLineEndings(tokensText).split('\n');
  }

  Map<String, GherkinLanguageKeywords> _loadGherkinLanguagesFromJsonAsset() {
    final dialectsAsset = 'gherkin-languages.json';
    final assetPath = '/home/luciano/projects/lamkr/gherkin/dart/assets/$dialectsAsset';
    var path = join(Directory.current.path, assetPath);
    var file = File(path);
    if( ! file.existsSync() ) {
      throw Exception('Gherkin language resource not found: $dialectsAsset');
    }
    var languagesJson = file.readAsStringSync();
    return _parseLanguages(languagesJson);
  }

  Map<String, GherkinLanguageKeywords> _parseLanguages(String languagesString) {
    var map = json.decode(languagesString) as Map;
    var languages = <String, GherkinLanguageKeywords>{};
    for( var entry in map.entries) {
      languages[entry.key as String] = GherkinLanguageKeywords.fromJson(
          entry.value as Map<String, dynamic>
      );
    }
    return languages;
  }

  int _currentTokensIndex = 0;

  // See https://github.com/cucumber/cucumber-expressions#readme
  // See https://thepracticaldeveloper.com/cucumber-guide-1-intro-bdd-gherkin/
  List<dynamic> parseArguments(String stepDescription) {
    _currentTokensIndex = 0;
    stepDescription = _normalizeStepDescription(stepDescription);
    final stepToken = _findStepToken(stepDescription);
    if( stepToken.isNotEmpty ) {
      _extractArgs(stepToken, stepDescription);
    }
    return List.empty();
  }

  String _normalizeStepDescription(String stepDescription) {
    const syntaxes = <String,String>{
      '{int}': r'\d+',
      '{double}': r'[\d]*\.?[\d]+(e[-+][\d]+)?',
      '{string}': '".*?"|\'.*?\''
    };
    var index = 0;
    for( var syntax in syntaxes.entries ) {
      index = stepDescription.indexOf(syntax.key, index);
      if( index > -1 ) {
        stepDescription = stepDescription.replaceFirst(
          syntax.key,
          syntax.value,
          index,
        );
      }
      index = 0;
    }
    return stepDescription;
  }

  String _findStepToken(String stepDescription) {
    while( _currentTokensIndex < tokens.length ) {
      final stepToken = tokens[_currentTokensIndex];
      if( _isMatch(stepToken, stepDescription) ) {
        return stepToken;
      }
      _currentTokensIndex++;
    }
    return '';
  }

  bool _isMatch(String stepToken, String stepDescription) {
    final rx = RegExp(stepDescription);
    return rx.hasMatch(stepToken);
  }

  void _extractArgs(String stepToken, String stepDescription) {
    for( var syntax in syntaxes.entries ) {
      final valueInStep = _extractValue( stepDescription, syntax );
      print(valueInStep);
    }
  }

  ValueInStep _extractValue(String stepDescription, MapEntry<String,String> syntax) {
    int index = stepDescription.indexOf(syntax.key);
    if( index > -1 ) {
      stepDescription = stepDescription.substring(index);
    }
    final rx = RegExp(syntax.value);
    final match = rx.firstMatch(stepDescription);
    if( match != null ) {
      stepDescription = stepDescription.substring(0, match.end);
      final value = match.toString();
      return ValueInStep(stepDescription, value);
    }
    return ValueInStep.empty;
  }
}


class ValueInStep implements INullSafetyObject{
  static const empty = _EmptyValueInStep();

  final String stepDescription;
  final dynamic value;

  const ValueInStep(this.stepDescription, this.value);

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => !isEmpty;
}

class _EmptyValueInStep extends ValueInStep {
  const _EmptyValueInStep() : super('', '');

  @override
  bool get isEmpty => true;
}