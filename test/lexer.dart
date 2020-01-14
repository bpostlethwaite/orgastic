import "package:test/test.dart";
import 'dart:mirrors';
import 'package:orga/src/options.dart';
import 'package:orga/src/lexer.dart';

class TokenTester {
  Token token;
  TokenTester(this.token);

  equals(Token token) {
    try {
      expect(this.token.name, token.name);
    } catch (e) {
      throw (TestFailure("token.name: ${e.message}"));
    }

    try {
      expect(this.token.raw, token.raw);
    } catch (e) {
      throw (TestFailure("token.raw: ${e.message}"));
    }

    InstanceMirror expectIm = reflect(token.data);
    InstanceMirror testIm = reflect(this.token.data);
    var expectFields =
        expectIm.type.declarations.values.where((d) => d is VariableMirror);
    for (var field in expectFields) {
      var name = MirrorSystem.getName(field.simpleName);
      var expectValue = expectIm.getField(Symbol(name)).reflectee;
      if (expectValue == null) {
        continue;
      }

      var testValue;
      try {
        testValue = testIm.getField(Symbol(name)).reflectee;
      } catch (e) {
        testValue = null;
      }
      try {
        expect(testValue, expectValue);
      } catch (e) {
        throw (TestFailure("token.data.${name}: ${e.message}"));
      }
    }

    var testFields =
        testIm.type.declarations.values.where((d) => d is VariableMirror);
    for (var field in testFields) {
      var name = MirrorSystem.getName(field.simpleName);
      var testValue = testIm.getField(Symbol(name)).reflectee;
      if (testValue == null) {
        continue;
      }

      var expectValue;
      try {
        expectValue = expectIm.getField(Symbol(name)).reflectee;
      } catch (e) {
        expectValue = null;
      }

      try {
        expect(testValue, expectValue);
      } catch (e) {
        throw (TestFailure("token.data.${name}: ${e.message}"));
      }
    }
  }
}

TokenTester expectToken(Token token) {
  return TokenTester(token);
}

void main() {
  var lexer = Lexer(
      ParseOptions(todos: ['TODO', 'DONE'], timezone: "Pacific/Auckland"));

  test('knows table row', () {
    expectToken(lexer.tokenize('| batman | superman | wonder woman |'))
        .equals(Token());
  }, skip: true);

  test('knows blank', () {
    expectToken(lexer.tokenize(''))
        .equals(Token(name: "blank", raw: "", data: null));
    expectToken(lexer.tokenize('')).equals(Token(name: "blank", raw: ""));
    expectToken(lexer.tokenize(' ')).equals(Token(name: "blank", raw: " "));
    expectToken(lexer.tokenize('    '))
        .equals(Token(name: "blank", raw: "    "));
    expectToken(lexer.tokenize('\t')).equals(Token(name: "blank", raw: "\t"));
    expectToken(lexer.tokenize(' \t')).equals(Token(name: "blank", raw: " \t"));
    expectToken(lexer.tokenize('\t ')).equals(Token(name: "blank", raw: "\t "));
    expectToken(lexer.tokenize(' \t  '))
        .equals(Token(name: "blank", raw: " \t  "));
  });

  test('knows these are not blanks', () {
    expectToken(lexer.tokenize(' a ')).equals(Token(name: "line", raw: " a "));
  });

  test('knows headlines', () {
    expectToken(lexer.tokenize('** a headline')).equals(Token(
        name: "headline",
        raw: "** a headline",
        data: TokenData(content: "a headline", level: 2)));
    expectToken(lexer.tokenize('** _headline_')).equals(Token(
        name: "headline",
        raw: "** _headline_",
        data: TokenData(content: "_headline_", level: 2)));
    expectToken(lexer.tokenize('**   a headline')).equals(Token(
        name: "headline",
        raw: "**   a headline",
        data: TokenData(
          content: "a headline",
          level: 2,
        )));
    expectToken(lexer.tokenize('***** a headline')).equals(Token(
        name: "headline",
        raw: "***** a headline",
        data: TokenData(content: "a headline", level: 5)));
    expectToken(lexer.tokenize('* a 😀line')).equals(Token(
        name: "headline",
        raw: "* a 😀line",
        data: TokenData(
          content: "a 😀line",
          level: 1,
        )));
    expectToken(lexer.tokenize('* TODO [#A] a headline     :tag1:tag2:'))
        .equals(Token(
            name: "headline",
            raw: "* TODO [#A] a headline     :tag1:tag2:",
            data: TokenData(
              content: "a headline",
              keyword: "TODO",
              level: 1,
              priority: "A",
              tags: [
                "tag1",
                "tag2",
              ],
            )));
  });

  test('knows these are not headlines', () {
    expectToken(lexer.tokenize('*not a headline'))
        .equals(Token(name: "line", raw: "*not a headline"));
    expectToken(lexer.tokenize(' * not a headline'))
        .equals(Token(name: "line", raw: " * not a headline"));
    expectToken(lexer.tokenize('*_* not a headline'))
        .equals(Token(name: "line", raw: '*_* not a headline'));
    expectToken(lexer.tokenize('not a headline'))
        .equals(Token(name: "line", raw: 'not a headline'));
  });

  test('knows keywords', () {
    expectToken(lexer.tokenize('#+KEY: Value')).equals(Token(
        name: "keyword",
        raw: "#+KEY: Value",
        data: TokenData(keyword: "KEY", content: "Value")));
    expectToken(lexer.tokenize('#+KEY: Another Value')).equals(Token(
        name: "keyword",
        raw: "#+KEY: Another Value",
        data: TokenData(keyword: "KEY", content: "Another Value")));
    expectToken(lexer.tokenize('#+KEY: value : Value')).equals(Token(
        name: "keyword",
        raw: "#+KEY: value : Value",
        data: TokenData(keyword: "KEY", content: "value : Value")));
  });

  test('knows these are not keywords', () {
    expectToken(lexer.tokenize('#+KEY : Value'))
        .equals(Token(name: "line", raw: "#+KEY : Value"));
    expectToken(lexer.tokenize('#+KE Y: Value'))
        .equals(Token(name: "line", raw: "#+KE Y: Value"));
  });

  test('knows plannings', () {
    expectToken(lexer.tokenize('DEADLINE: <2018-01-01 Mon>')).equals(Token(
        name: "planning",
        raw: 'DEADLINE: <2018-01-01 Mon>',
        data: TokenData(
            date: DateTime.parse("2018-01-01 00:00:00.000"),
            keyword: "DEADLINE")));
    expectToken(lexer.tokenize('  DEADLINE: <2018-01-01 Mon>')).equals(Token(
        name: "planning",
        raw: '  DEADLINE: <2018-01-01 Mon>',
        data: TokenData(
            date: DateTime.parse("2018-01-01 00:00:00.000"),
            keyword: "DEADLINE")));
    expectToken(lexer.tokenize(' \tDEADLINE: <2018-01-01 Mon>')).equals(Token(
        name: "planning",
        raw: ' \tDEADLINE: <2018-01-01 Mon>',
        data: TokenData(
            date: DateTime.parse("2018-01-01 00:00:00.000"),
            keyword: "DEADLINE")));
    expectToken(lexer.tokenize(' \t DEADLINE: <2018-01-01 Mon>')).equals(Token(
        name: "planning",
        raw: ' \t DEADLINE: <2018-01-01 Mon>',
        data: TokenData(
            date: DateTime.parse("2018-01-01 00:00:00.000"),
            keyword: "DEADLINE")));
  });

  test('knows these are not plannings', () {
    expectToken(lexer.tokenize('dEADLINE: <2018-01-01 Mon>'))
        .equals(Token(name: 'line', raw: 'dEADLINE: <2018-01-01 Mon>'));
  });

  test('knows these are timestamps', () {
    expectToken(lexer.tokenize('<2019-08-19 Mon>')).equals(Token(
        name: "timestamp",
        raw: "<2019-08-19 Mon>",
        data: TokenData(date: DateTime.parse("2019-08-19"))));
    expectToken(lexer.tokenize('<2019-08-19 Mon 13:20>')).equals(Token(
        name: "timestamp",
        raw: "<2019-08-19 Mon 13:20>",
        data: TokenData(date: DateTime.parse("2019-08-19 13:20:00.00"))));
    expectToken(lexer.tokenize('<2019-08-19 Mon 13:20-14:00>')).equals(Token(
        name: "timestamp",
        raw: "<2019-08-19 Mon 13:20-14:00>",
        data: TokenData(
            date: DateTime.parse("2019-08-19 13:20:00.00"),
            end: DateTime.parse("2019-08-19 14:00:00.00"))));
    expectToken(lexer.tokenize('<2019-08-19 Mon>--<2019-08-20 Tue>')).equals(
        Token(
            name: "timestamp",
            raw: "<2019-08-19 Mon>--<2019-08-20 Tue>",
            data: TokenData(
                date: DateTime.parse("2019-08-19"),
                end: DateTime.parse("2019-08-20"))));
  });

  test('knows block begins', () {
    expectToken(lexer.tokenize('#+BEGIN_SRC swift')).equals(Token());
    expectToken(lexer.tokenize(' #+BEGIN_SRC swift')).equals(Token());
    expectToken(lexer.tokenize('#+begin_src swift')).equals(Token());
    expectToken(lexer.tokenize('#+begin_example')).equals(Token());
    expectToken(lexer.tokenize('#+begin_ex😀mple')).equals(Token());
    expectToken(lexer.tokenize('#+begin_src swift :tangle code.swift'))
        .equals(Token());
  }, skip: "not implemented");

  test('knows these are not block begins', () {
    expectToken(lexer.tokenize('#+begi😀n_src swift')).equals(Token());
  }, skip: "not implemented");

  test('knows block ends', () {
    expectToken(lexer.tokenize('#+END_SRC')).equals(Token());
    expectToken(lexer.tokenize('  #+END_SRC')).equals(Token());
    expectToken(lexer.tokenize('#+end_src')).equals(Token());
    expectToken(lexer.tokenize('#+end_SRC')).equals(Token());
    expectToken(lexer.tokenize('#+end_S😀RC')).equals(Token());
  }, skip: "not implemented");

  test('knows these are not block ends', () {
    expectToken(lexer.tokenize('#+end_SRC ')).equals(Token());
    expectToken(lexer.tokenize('#+end_src param')).equals(Token());
  }, skip: "not implemented");

  test('knows horizontal rules', () {
    expectToken(lexer.tokenize('-----')).equals(Token());
    expectToken(lexer.tokenize('------')).equals(Token());
    expectToken(lexer.tokenize('--------')).equals(Token());
    expectToken(lexer.tokenize('  -----')).equals(Token());
    expectToken(lexer.tokenize('-----   ')).equals(Token());
    expectToken(lexer.tokenize('  -----   ')).equals(Token());
    expectToken(lexer.tokenize('  -----  \t ')).equals(Token());
  }, skip: "not implemented");

  test('knows these are not horizontal rules', () {
    expectToken(lexer.tokenize('----')).equals(Token());
    expectToken(lexer.tokenize('- ----')).equals(Token());
    expectToken(lexer.tokenize('-----a')).equals(Token());
    expectToken(lexer.tokenize('_-----')).equals(Token());
    expectToken(lexer.tokenize('-----    a')).equals(Token());
  }, skip: "not implemented");

  test('knows comments', () {
    expectToken(lexer.tokenize('# a comment')).equals(Token());
    expectToken(lexer.tokenize('# ')).equals(Token());
    expectToken(lexer.tokenize('# a comment😯')).equals(Token());
    expectToken(lexer.tokenize(' # a comment')).equals(Token());
    expectToken(lexer.tokenize('  \t  # a comment')).equals(Token());
    expectToken(lexer.tokenize('#   a comment')).equals(Token());
    expectToken(lexer.tokenize('#    \t a comment')).equals(Token());
  }, skip: "not implemented");

  test('knows these are not comments', () {
    expectToken(lexer.tokenize('#not a comment')).equals(Token());
    expectToken(lexer.tokenize('  #not a comment')).equals(Token());
  }, skip: "not implemented");

  test('knows list items', () {
    // unordered
    expectToken(lexer.tokenize('- buy milk')).equals(Token());
    expectToken(lexer.tokenize('+ buy milk')).equals(Token());
    // ordered
    expectToken(lexer.tokenize('1. buy milk')).equals(Token());
    expectToken(lexer.tokenize('12. buy milk')).equals(Token());
    expectToken(lexer.tokenize('123) buy milk')).equals(Token());
    // checkbox
    expectToken(lexer.tokenize('- [x] buy milk checked')).equals(Token());
    expectToken(lexer.tokenize('- [X] buy milk checked')).equals(Token());
    expectToken(lexer.tokenize('- [-] buy milk checked')).equals(Token());
    expectToken(lexer.tokenize('- [ ] buy milk unchecked')).equals(Token());
    // indent
    expectToken(lexer.tokenize('  - buy milk')).equals(Token());
    // tag
    expectToken(lexer.tokenize('- item1 :: description here')).equals(Token());
    expectToken(lexer.tokenize('- item2\n :: description here'))
        .equals(Token());
    expectToken(lexer.tokenize('- [x] item3 :: description here'))
        .equals(Token());
  }, skip: "not implemented");

  test('knows these are not list items', () {
    expectToken(lexer.tokenize('-not item')).equals(Token());
    expectToken(lexer.tokenize('1.not item')).equals(Token());
    expectToken(lexer.tokenize('8)not item')).equals(Token());
    expectToken(lexer.tokenize('8a) not item')).equals(Token());
  }, skip: "not implemented");

  test('knows footnotes', () {
    expectToken(lexer.tokenize('[fn:1] a footnote')).equals(Token());
    expectToken(lexer.tokenize('[fn:word] a footnote')).equals(Token());
    expectToken(lexer.tokenize('[fn:word_] a footnote')).equals(Token());
    expectToken(lexer.tokenize('[fn:wor1d_] a footnote')).equals(Token());
  }, skip: "not implemented");

  test('knows these are not footnotes', () {
    expectToken(lexer.tokenize('[fn:1]: not a footnote')).equals(Token());
    expectToken(lexer.tokenize(' [fn:1] not a footnote')).equals(Token());
    expectToken(lexer.tokenize('[[fn:1] not a footnote')).equals(Token());
    expectToken(lexer.tokenize('\t[fn:1] not a footnote')).equals(Token());
  }, skip: "not implemented");

  test('knows table separators', () {
    expectToken(lexer.tokenize('|----+---+----|')).equals(Token());
    expectToken(lexer.tokenize('|--=-+---+----|')).equals(Token());
    expectToken(lexer.tokenize('  |----+---+----|')).equals(Token());
    expectToken(lexer.tokenize('|----+---+----')).equals(Token());
    expectToken(lexer.tokenize('|---')).equals(Token());
    expectToken(lexer.tokenize('|-')).equals(Token());
  }, skip: "not implemented");

  test('knows these are not table separators', () {
    expectToken(lexer.tokenize('----+---+----|')).equals(Token());
  }, skip: "not implemented");

  test('knows table rows', () {
    expectToken(lexer.tokenize('| hello | world | y\'all |')).equals(Token());
    expectToken(lexer.tokenize('   | hello | world | y\'all |'))
        .equals(Token());
    expectToken(lexer.tokenize('|    hello |  world   |y\'all |'))
        .equals(Token());
    // with empty cell
    expectToken(lexer.tokenize('||  world   | |')).equals(Token());
  }, skip: "not implemented");

  test('knows these are not table rows', () {
    expectToken(lexer.tokenize(' hello | world | y\'all |')).equals(Token());
    expectToken(lexer.tokenize('|+')).equals(Token());
  }, skip: "not implemented");

  test('knows drawer begins', () {
    expectToken(lexer.tokenize(':PROPERTIES:')).equals(Token());
    expectToken(lexer.tokenize('  :properties:')).equals(Token());
    expectToken(lexer.tokenize('  :properties:  ')).equals(Token());
    expectToken(lexer.tokenize('  :prop_erties:  ')).equals(Token());
  }, skip: "not implemented");

  test('knows these are not drawer begins', () {
    expectToken(lexer.tokenize('PROPERTIES:')).equals(Token());
    expectToken(lexer.tokenize(':PROPERTIES')).equals(Token());
    expectToken(lexer.tokenize(':PR OPERTIES:')).equals(Token());
  }, skip: "not implemented");

  test('knows drawer ends', () {
    expectToken(lexer.tokenize(':END:')).equals(Token());
    expectToken(lexer.tokenize('  :end:')).equals(Token());
    expectToken(lexer.tokenize('  :end:  ')).equals(Token());
    expectToken(lexer.tokenize('  :end:  ')).equals(Token());
  }, skip: "not implemented");

  test('knows these are not drawer ends', () {
    expectToken(lexer.tokenize('END:')).equals(Token());
    expectToken(lexer.tokenize(':END')).equals(Token());
    expectToken(lexer.tokenize(':ENDed')).equals(Token());
  }, skip: "not implemented");
}
