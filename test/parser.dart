import "package:test/test.dart";
import 'package:orga/src/options.dart';
import 'package:orga/src/parser.dart';

void main() {


  test("nested Headlines", () {
    var parser = OrgParser(
        ParseOptions(todos: ['TODO', 'DONE'], timezone: 'Pacific/Auckland'));
    var content = '''
* #HEADLINE# 1
Paragraph
** #HEADLINE# 1.1
*** #HEADLINE# 1.1.1
content
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
