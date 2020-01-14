import 'package:orga/src/lexer.dart';
import 'package:orga/src/node.dart';
import 'package:orga/src/parser.dart';

mixin Blank on Parser {
  Node blankProcessor(Token token, Node section) {
    this.cel++;
    this.consume();
    if (section is FootnoteNode && this.cel > 1) return section;
    return this.parseSection(section);
  }
}

