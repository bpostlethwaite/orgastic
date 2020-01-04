import 'options.dart';

class Token {
  String name;
  String raw;
  TokenData data;

  Token({this.name, this.raw, this.data});
}

class TokenData {
  int level;
  String type;
  String keyword;
  String priority;
  String content;
  DateTime date;
  DateTime end;
  List<String> tags;
  int indent;
  bool ordered;
  bool checked;
  String tag;
  String bullet;

  TokenData(
      {this.level,
      this.keyword,
      this.priority,
      this.content,
      this.tags,
      this.type,
      this.indent,
      this.ordered,
      this.checked,
      this.tag,
      this.bullet});
}

typedef TokenData Tokenize(Match m);

class _Rule {
  String _name;
  RegExp _pattern;
  Tokenize tokenize;

  _Rule(this._name, this._pattern, this.tokenize);
}

List<_Rule> _rules = [
  _Rule(
      "headline",
      RegExp(
          r"^(\*+)\s+(?:(TODO|DONE)\s+)?(?:\[#(A|B|C)\]\s+)?(.*?)\s*(:(?:\w+:)+)?$"),
      (Match m) {
    var level = m.group(1).length;
    var keyword = m.group(2) ?? "";
    var priority = m.group(3) ?? "";
    var content = m.group(4) ?? "";
    var tag_group = m.group(5) ?? "";
    List<String> tags;
    if (tag_group != null && tag_group.length > 0) {
      tags = tag_group.split(':').map((String str) => str.trim()).toList();
    } else {
      tags = [];
    }
    return TokenData(
        level: level,
        keyword: keyword,
        priority: priority,
        content: content,
        tags: tags);
  }),
  _Rule(
    "listItem",
    RegExp(
      r"^(\s*)([-+]|\d+[.)])\s+(?:\[(x|X|-| )\][ \t]+)?(?:([^\n]+)[ \t]+::[ \t]*)?(.*)$"
    ),
      (Match m) {
      var indent = m.group(1).length;
      var bullet = m.group(2);
      var checked = m.group(3) != " ";
      var tag = m.group(4);
      var content = m.group(5);

      var ordered = true;
      if (bullet == "-" || bullet == "+") {
        ordered == false;
      }
      return TokenData(
        indent: indent,
        ordered: ordered,
        checked: checked,
        content: content,
        bullet: bullet,
        tag: tag);
      }
  )
];

class Lexer {
  ParseOptions options;

  Lexer(ParseOptions this.options);

  Token tokenize(String input) {
    for (var i = 0; i < _rules.length; i++) {
      var rule = _rules[i];
      var m = rule._pattern.firstMatch(input);
      if (m == null) {
        continue;
      }
      var tokenData = rule.tokenize(m);
      return Token(name: rule._name, raw: input, data: tokenData);
    }

    if (input.trim() == "") {
      return Token(name: "blank", raw: input);
    }

    return Token(name: 'line', raw: input);
  }
}
