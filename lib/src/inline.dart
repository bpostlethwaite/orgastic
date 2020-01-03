import './node.dart';
// import './uri.dart'; TODO: NOT IMPLEMENTED

List<Node> parse(String text) => [TextNode(value: text)];

//var LINK_PATTERN = RegExp(r"/(.*?)\[\[([^\]]*)\](?:\[([^\]]*)\])?\](.*)", multiLine: true); // \1 => link, \2 => text
//var FOOTNOTE_PATTERN = RegExp("(.*?)\[fn:(\w+)\](.*)");
//
//var PRE = "(?:[\\s\\({'\"]|^)";
//var POST = r"(?:[\s-\.,:!?'\)}]|$)";
//var BORDER = "[^,'\"\\s]";
//
//String uri(String str) => str; // TODO: NOT IMPLEMENTED
//
//RegExp markup(String marker) {
//  return RegExp("(.*?$PRE)$marker($BORDER(?:.*?(?:$BORDER))??)$marker($POST.*)", multiLine: true);
//}
//
//Node parse(String text) {
//  text = _parse(LINK_PATTERN, text, (Match m) {
//    return new LinkNode(uri: uri(m.group(0)), desc: m.group(1));
//  });
//
//  text = _parse(FOOTNOTE_PATTERN, text, (Match m) {
//    return FootnoteReferenceNode(label: m.group(0))
//  });
//
//  var markups = [
//    { "name": "bold", "marker": "\\*" },
//    { "name": "verbatim", "marker": "=" },
//    { "name": "italic", "marker": "/" },
//    { "name": "strikeThrough", "marker": "\\+" },
//    { "name": "underline", "marker": "_" },
//    { "name": "code", "marker": "~" },
//  ];
//  markups.forEach((name, marker) {
//    text = _parse(markup(marker), text, (captures) => {
//        return new Node(name, captures[0])
//    });
//  });
//  return text;
//}
//
//typedef Node
//    (Token, Node);
//
//List<Node> _parse(RegExp pattern, String text, subParser) {
//  var m = pattern.firstMatch(text);
//  if (m == null) return [TextNode(value: text)];
//  var groupCount = m.groupCount;
//  var before = m.group(1);
//  var after = m.group(groupCount);
//  var nodes = [];
//  if ( before.length > 0 ) {
//    nodes.add(TextNode(value: before));
//  }
//  if (m.length > 0) {
//    nodes.addAll(subParser(m));
//  }
//  if (after) {
//    nodes.addAll(_parse(pattern, after, subParser));
//  }
//  return nodes;
//}
//
//
//if (Array.isArray(text)) {
//  return text.reduce((all, node) => {
//    if (node.hasOwnProperty(`type`) && node.type !== `text`) {
//      return all.concat(node)
//    }
//    return all.concat(_parse(pattern, node, post))
//  }, [])
//}
//
//if (typeof text.value == "string") {
//return _parse(pattern, text.value, post)
//}
//return undefined
//}