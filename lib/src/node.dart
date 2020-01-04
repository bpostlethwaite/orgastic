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

  String pad(String content) {
    if (content.isNotEmpty) {
      return " " + content;
    }
    return "";
  }

  String padAll(List<String> contentList) {
    return this.pad(contentList.where((s) => s != "").join(" "));
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

  String toString() => "*" * this.level + this.padAll([this.keyword, super.toString()]);
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

  String toString() => this.value + this.pad(super.toString());
}

class ParagraphNode extends Node {}

class ListNode extends Node {
  bool ordered;
}

class ListItemNode extends Node {
  bool ordered;
  bool checked;
  String tag;
  String bullet;
  int indent;

  ListItemNode({this.ordered, this.checked, this.tag, this.bullet, this.indent});

  String toString() {
    var space = " " * this.indent;
    return space + this.bullet + this.pad(super.toString());
  }
}