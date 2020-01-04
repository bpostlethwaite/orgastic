import '../node.dart';
import '../inline.dart' as inline;
import '../lexer.dart';
import '../parser.dart';

mixin Lists on Parser {
  Node listItemProcessor(Token token, Node section) {
    var parseListItem = () {
      var data = this.next().data;
      var lines = [data.content];
      var item = ListItemNode(
          ordered: data.ordered,
          tag: data.tag,
          checked: data.checked,
          indent: data.indent,
          bullet: data.bullet);

      while (this.hasNext()) {
        var token = this.peek();
        if (token.name != "line") break;
        var lineIndent = token.raw.indexOf(RegExp("\S"));
        if (lineIndent <= data.indent) break;
        lines.add(this.next().raw.trim());
      }
      item.addAll(inline.parse(lines.join(" ")));
      return item;
    };

    Node parseList(int level) {
      var list = ListNode();
      while (this.hasNext()) {
        var token = this.peek();
        if (token.name != "listItem") break;
        if (token.data.indent <= level) break;
        var item = parseListItem();
        var sublist = parseList(token.data.indent);
        if (sublist != null) {
          item.add(sublist);
        }

        list.add(item);
      }
      if (list.children.length > 0) {
        list.ordered = (list.children[0] as ListItemNode).ordered;
        return list;
      }
      return null;
    }

    section.add(parseList(-1));

    return this.parseSection(section);
  }
}
