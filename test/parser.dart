import 'package:orga/src/node.dart';
import "package:test/test.dart";
import 'package:orga/src/options.dart';
import 'package:orga/src/parser.dart';

OrgParser testParser() {
  return OrgParser(
      ParseOptions(todos: ['TODO', 'DONE'], timezone: 'Pacific/Auckland'));
}

void main() {
  test("Core functionality", () {
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

    var document = testParser().parse(content);

    expect(document.toString(), content);
  });

  test("basic parser features", () {
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

    expect(testParser().parse(content).toString(), content);
  }, skip: true);

  test('can handle timestamp after headline', () {
    var content = '''
* headline
<2019-08-19 Mon 19:00>--<2019-08-20 Tue 19:00>
Paragraph
''';
    expect(testParser().parse(content).toString(), content);
  });

  test("it can handle unordered list", () {
    const content = '''
- apple
- banana
- orange
''';
    var document = testParser().parse(content);
    expect(document.toString(), content);

    const expectedListItems = 3;
    var actualListItems = 0;
    document.forEach((node) {
      if (node is ListItemNode) actualListItems++;
    });
    expect(actualListItems, expectedListItems);
  });

  test('can handle ordered list', () {
    var content = '''
1. apple
5. banana
- orange
''';
    var document = testParser().parse(content);
    expect(document.toString(), content);

    const expectedLists = 2;
    var actualLists = 0;
    document.forEach((node) {
      if (node is ListNode) actualLists++;
    });
    expect(actualLists, expectedLists);
  });
}
