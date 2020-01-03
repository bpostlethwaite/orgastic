class Node {
  List<Node> children;
  Node parent;
  num _level;

  Node({level}) {
    this._level = level;
    this.children = [];
  }

  num get level {
    if (this._level != null) {
      return this._level;
    } else
      return this.parent._level;
  }

  add(Node node) {
    if (this.children == null) {
      this.children = [];
    }

    this.children.add(node);
  }

  addAll(List<Node> nodes) {
    if (this.children == null) {
      this.children = [];
    }

    this.children.addAll(nodes);
  }

  String padIfNotEmpty(String content) {
    if (content.isNotEmpty) {
      return " " + content;
    }
    return "";
  }

  String toString() {
    return "" + this.children.map((node) => node.toString()).join("\n");
  }
}

class RootNode extends Node {
  RootNode() : super(level: 0);

  String toString() =>  super.toString() + "\n";
}

class TimestampNode extends Node {
  DateTime date;
  DateTime end;

  TimestampNode({this.date, this.end});
}

class PlanningNode extends TimestampNode {
  String keyword;
  DateTime date;
  DateTime end;

  PlanningNode({this.keyword, date, end}) : super(date: date, end: end);
}

class DrawerNode extends Node {
  String drawerType;
  String value;

  DrawerNode({this.drawerType, this.value});
}

class HeadlineNode extends Node {
  String keyword;
  String priority;
  List<String> tags;

  HeadlineNode({this.keyword, this.priority, this.tags, level})
      : super(level: level);

  String toString() => "*" * this.level + this.padIfNotEmpty(super.toString());
}

class SectionNode extends Node {
  SectionNode({level}) : super(level: level);
}

class FootnoteNode extends Node {}

class FootnoteReferenceNode extends Node {
  String label;

  FootnoteReferenceNode({this.label});
}

class LinkNode extends Node {
  String uri;
  String desc;

  LinkNode({this.uri, this.desc});
}

class TextNode extends Node {
  String value;

  TextNode({this.value});

  String toString() => this.value + this.padIfNotEmpty(super.toString());
}

class ParagraphNode extends Node {}
