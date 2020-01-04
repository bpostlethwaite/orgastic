import "package:test/test.dart";
import 'package:orga/src/options.dart';
import 'package:orga/src/parser.dart';

void main() {


  test("Core functionality", () {
    var parser = OrgParser(
        ParseOptions(todos: ['TODO', 'DONE'], timezone: 'Pacific/Auckland'));
    var content = '''
* HEADLINE 1
Some Paragraph with multiline
text.
- one
- two
- three
  - nested one
  - nested two
- four
** TODO HEADLINE 1.1
*** DONE HEADLINE 1.1.1
some text about how done this is
** #HEADLINE# 1.2
* #HEADLINE# 2
** #HEADLINE# 2.2
''';

    var document = parser.parse(content);

    expect(document.toString(), content);
  });

  test("basic parser features", () {
    var parser = OrgParser(
        ParseOptions(todos: ['TODO', 'DONE'], timezone: 'Pacific/Auckland'));
    var content = '''
#+TITLE: hello world
#+TODO: TODO NEXT | DONE
#+DATE: 2018-01-01
* NEXT headline one
  DEADLINE: <2018-01-01 Mon>
  :PROPERTIES:
    key: value
    key: value
    :END:
  [[https://github.com/xiaoxinghu/orgajs][Here's]] to the *crazy* ones, the /misfits/, the _rebels_, the ~troublemakers~,
  the round pegs in the +round+ square holes...
''';
    var document = parser.parse(content);

    expect(document, '');
  });
}
