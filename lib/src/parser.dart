import 'options.dart';
import 'lexer.dart';
import 'node.dart';
import 'processors.dart';
import 'dart:mirrors';

typedef Node Processor(Token, Node);
typedef Node SubParser();

T cast<T>(x) => x is T ? x : null;

abstract class Parser {
  ParseOptions options;
  Lexer lexer;
  List<Token> prefix;
  Map<String, Processor> processors;
  InstanceMirror im;
  num _cel;
  num cursor;
  List<String> lines;
  List<Token> tokens;

  Node parse(String text) {
    var document = new RootNode();
    this.cursor = -1;
    this.lines = text.split('\n'); // TODO: more robust lines?
    this.tokens = [];
    return this.parseSection(document);
  }

  Token peek() {
    if (this.prefix.length > 0) return this.prefix[0];
    return this.getToken(this.cursor + 1);
  }

  bool hasNext() {
    return this.prefix.length > 0 || this.cursor + 1 < this.lines.length;
  }

  Token next() {
    return this.consume();
  }

  Token consume() {
    if (this.prefix.length > 0) return this.prefix.removeAt(0);
    this.cursor++;
    return this.getToken(this.cursor);
  }

  Token getToken(num index) {
    if (index >= this.lines.length) return null; // TODO: RETURNS NULL TOKEN
    if (index >= this.tokens.length) {
      var start = this.tokens.length;
      for (var i = start; i <= index; i++) {
        this.tokens.add(this.lexer.tokenize(this.lines[i]));
      }
    }
    return this.tokens[index];
  }

  Node tryTo(SubParser subParser) {
    var restorePoint = this.cursor;
    var node = subParser();
    if (node != null) return node;
    this.cursor = restorePoint;
    return null;
  }

  void downgradeToLine(num index) {
    var token = this.tokens[index];
    this.tokens[index] = Token(
        name: "line",
        raw: token.raw,
        data: TokenData(content: token.raw.trim()));
  }

  Node parseSection(Node section) {
    var token = this.peek();
    if (token == null) return section;
    if (token.name != "blank") this._cel = 0; // reset consecutive empty lines
    var methodSymbol = Symbol("${token.name}Processor");
    if (im.type.instanceMembers.containsKey(methodSymbol)) {
      InstanceMirror f = im.invoke(methodSymbol, [token, section]);
      return cast<Node>(f.reflectee);
    }

    this.consume();
    return this.parseSection(section);
  }
}

class OrgParser extends Parser with Headline, Line, Lists {
  OrgParser(ParseOptions options) {
    this.prefix = [];
    this.options = options;
    this.lexer = Lexer(options);
    this._cel = 0;
    this.im = reflect(this);

    //this.registerProcessor();
  }
}
