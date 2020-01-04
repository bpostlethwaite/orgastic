import '../parser.dart';
import '../node.dart';
import '../inline.dart' as inline;
import '../lexer.dart';

const TOKENS_BREAK_LINE = ["line", "block.end", "drawer.end"];

mixin Line on Parser {
  
  Node lineProcessor(Token token, Node section) {

    List<Node> nodes = [];
    while (this.hasNext()) {
      var token = this.peek();
      if (!TOKENS_BREAK_LINE.contains(token.name)) break;
      this.consume();
      var line = token.raw.trim();
      var newNodes = inline.parse(line);

      if (nodes.isNotEmpty && newNodes.isNotEmpty && nodes.last == TextNode && newNodes.last == TextNode) {
        var n = newNodes.removeAt(0) as TextNode;
        var last = nodes.removeLast() as TextNode;
        var mergedNode = TextNode(value: "${last.value} ${n.value}");
        nodes.add(mergedNode);
      }

      nodes = [...nodes, ...newNodes];
    }
    var paragraphNode = ParagraphNode();
    paragraphNode.addAll(nodes);
    section.add(paragraphNode);

    return this.parseSection(section);
  }
}
