/*
  This file is part of Daxe.

  Daxe is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Daxe is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Daxe.  If not, see <http://www.gnu.org/licenses/>.
*/

part of nodes;

/**
 * Invisible style node using a style attribute with CSS.
 * Tags are displayed if the span is empty or if the style attribute is empty.
 * The style can be changed with the toolbar.
 * 
 * Display type: 'stylespan'.
 * 
 * Parameters:
 * 
 * * `styleAtt`: name of the attribute with the CSS
 */
class DNStyleSpan extends DNStyle {
  String _styleAtt;
  
  DNStyleSpan.fromRef(x.Element elementRef) : super.fromRef(elementRef) {
    _styleAtt = doc.cfg.elementParameterValue(ref, 'styleAtt', 'style');
  }
  
  DNStyleSpan.fromNode(x.Node node, DaxeNode parent) : super.fromNode(node, parent) {
    _styleAtt = doc.cfg.elementParameterValue(ref, 'styleAtt', 'style');
  }
  
  @override
  h.Element html() {
    h.Element span = new h.SpanElement();
    span.id = "$id";
    span.classes.add('dn');
    if (noDelimiter) { // TODO: test for empty sub-styles, support CSS class
      h.SpanElement contents = new h.SpanElement();
      DaxeNode dn = firstChild;
      while (dn != null) {
        contents.append(dn.html());
        dn = dn.nextSibling;
      }
      if (css != null)
        contents.setAttribute('style', css);
      span.append(contents);
    } else {
      // let's make this invisible style visible !
      // TODO: use the toolbar instead
      Tag b1 = new Tag(this, Tag.START);
      Tag b2 = new Tag(this, Tag.END);
      span.append(b1.html());
      h.SpanElement contents = new h.SpanElement();
      if (css != null)
        contents.setAttribute('style', css);
      DaxeNode dn = firstChild;
      while (dn != null) {
        contents.append(dn.html());
        dn = dn.nextSibling;
      }
      span.append(contents);
      span.append(b2.html());
    }
    return(span);
  }
  
  @override
  bool get noDelimiter {
    return(firstChild != null && getAttribute('style') != null);
  }
  
  void set css(String css) {
    setAttribute(_styleAtt, css);
  }
  
  String get css {
    return(getAttribute(_styleAtt));
  }
  
  String get styleAtt {
    return(_styleAtt);
  }
  
  @override
  void updateHTMLAfterChildrenChange(List<DaxeNode> changed) {
    super.updateHTML();
  }
  
  @override
  h.Element getHTMLContentsNode() {
    if (noDelimiter)
      return(getHTMLNode().nodes.first);
    else
      return(getHTMLNode().nodes[1]);
  }
  
  static x.Element styleSpanRef() {
    return(doc.cfg.firstElementWithType('stylespan'));
  }
  
  @override
  void updateAttributes() {
    super.updateHTML();
  }
  
  @override
  bool matches(DNStyle dn) {
    if (dn is DNStyleSpan) {
      CSSMap cssMap1 = new CSSMap(css);
      CSSMap cssMap2 = new CSSMap(dn.css);
      return(cssMap1.equivalent(cssMap2));
    } else {
      return(false);
    }
  }
  
  @override
  bool matchesCss(String cssName, String cssValue) {
    if (css == null)
      return(false);
    CSSMap cssMap = new CSSMap(css);
    return(cssMap[cssName] == cssValue);
  }
  
  @override
  bool matchesCssName(String cssName) {
    if (css == null)
      return(false);
    CSSMap cssMap = new CSSMap(css);
    return(cssMap[cssName] != null);
  }
}
