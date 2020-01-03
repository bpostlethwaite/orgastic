import '../node.dart';
import '../lexer.dart';
import '../parser.dart';
import '../inline.dart' as inline;

mixin Headline on Parser {
  Node _parsePlanning() {
    var token = this.next();
    if (token == null || token.name != 'planning') return null;
    return PlanningNode(
        keyword: token.data.keyword,
        date: token.data.date,
        end: token.data.end);
  }

  Node _parseDrawer() {
    var begin = this.next();
    var lines = [];
    while (this.hasNext()) {
      var token = this.next();
      if (token.name == "headline") return null;
      if (token.name == "drawer.end") {
        return DrawerNode(drawerType: begin.data.type, value: lines.join("\n"));
      }
      lines.add(token.raw);
    }
    return null;
  }

  Node _parseTimestamp() {
    var token = this.next();
    if (token == null || token.name != "timestamp") return null;
    return TimestampNode(date: token.data.date, end: token.data.end);
  }

  Node headlineProcessor(Token token, Node section) {
    if (section is FootnoteNode) return section; // headline breaks footnote
    var tokenData = token.data;
    var currentLevel = section.level;
    if (tokenData.level <= currentLevel) return section;
    this.consume();
    var textNodes = inline.parse(tokenData.content);
    var headlineNode = HeadlineNode(
            level: tokenData.level,
            keyword: tokenData.keyword,
            priority: tokenData.priority,
            tags: tokenData.tags);

    headlineNode.addAll(textNodes);
    var planningNode = this.tryTo(this._parsePlanning);
    if (planningNode != null) {
      headlineNode.add(planningNode);
    }
    var timestampNode = this.tryTo(this._parseTimestamp);
    if (timestampNode != null) {
      headlineNode.add(timestampNode);
    }

    while (this.hasNext() && this.peek().name == "drawer.begin") {
      var drawerNode = this.tryTo(this._parseDrawer);
      if (drawerNode == null) {
        // broken drawer
        this.downgradeToLine(this.cursor + 1);
        break;
      }
      headlineNode.add(drawerNode);
    }
    var newSection = SectionNode(level: tokenData.level);
    newSection.add(headlineNode);
    section.add(this.parseSection(newSection));
    return this.parseSection(section);
  }
}
