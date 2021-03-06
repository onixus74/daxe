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

part of daxe;

/**
 * Left panel to insert elements. It only displays the elements that can be inserted at
 * the cursor position, according to the schema.
 */
class InsertPanel {
  DaxeNode _oldParent = null;
  List<x.Element> _oldRefs = null;
  List<x.Element> _oldValidRefs = null;
  
  void update(DaxeNode parent, List<x.Element> refs, List<x.Element> validRefs) {
    Config cfg = doc.cfg;
    if (cfg == null)
      return;
    
    if (!updateNeeded(parent, refs, validRefs))
      return;
    
    h.Element oldDivInsert = h.document.getElementById('insert');
    h.DivElement divInsert = h.document.createElement('div');
    divInsert.id = 'insert';
    if (parent.nodeType == DaxeNode.ELEMENT_NODE && parent.ref != null) {
      divInsert.append(makeHelpButton(parent.ref));
      String name = cfg.elementName(parent.ref);
      h.SpanElement span = new h.SpanElement();
      span.appendText(cfg.menuTitle(name));
      divInsert.append(span);
      divInsert.append(new h.HRElement());
    }
    // Items already in the toolbar are not displayed if there are lots of elements to list.
    List<x.Element> toolbarRefs;
    if (refs.length > 15 && page.toolbar != null)
      toolbarRefs = page.toolbar.elementRefs();
    else
      toolbarRefs = null;
    for (x.Element ref in refs) {
      if (toolbarRefs != null && toolbarRefs.contains(ref))
        continue;
      if (doc.hiddenParaRefs != null && doc.hiddenParaRefs.contains(ref))
        continue;
      divInsert.append(makeHelpButton(ref));
      h.ButtonElement button = new h.ButtonElement();
      button.attributes['type'] = 'button';
      button.classes.add('insertb');
      String name = cfg.elementName(ref);
      button.value = name;
      button.text = cfg.menuTitle(name);
      if (!validRefs.contains(ref))
        button.disabled = true;
      button.onClick.listen((h.Event event) => insert(ref));
      button.onKeyDown.listen((h.KeyboardEvent event) {
        int keyCode = event.keyCode;
        if (keyCode == h.KeyCode.ENTER) {
          event.preventDefault();
          insert(ref);
        }
      });
      divInsert.append(button);
      divInsert.append(new h.BRElement());
    }
    oldDivInsert.replaceWith(divInsert);
  }
  
  bool updateNeeded(DaxeNode parent, List<x.Element> refs, List<x.Element> validRefs) {
    if (parent == _oldParent && _oldRefs != null && _oldValidRefs != null &&
        _oldRefs.length == refs.length && _oldValidRefs.length == validRefs.length) {
      bool same = true;
      for (int i=0; i<refs.length; i++) {
        if (refs[i] != _oldRefs[i]) {
          same = false;
          break;
        }
      }
      if (same) {
        for (int i=0; i<validRefs.length; i++) {
          if (validRefs[i] != _oldValidRefs[i]) {
            same = false;
            break;
          }
        }
      }
      if (same)
        return false;
    }
    _oldParent = parent;
    _oldRefs = refs;
    _oldValidRefs = validRefs;
    return true;
  }
  
  h.ButtonElement makeHelpButton(x.Element ref) {
    h.ButtonElement bHelp = new h.ButtonElement();
    bHelp.attributes['type'] = 'button';
    bHelp.classes.add('help');
    bHelp.value = '?';
    bHelp.text = '?';
    String documentation = doc.cfg.documentation(ref);
    if (documentation != null)
      bHelp.title = documentation;
    bHelp.onClick.listen((h.Event event) => help(ref));
    return(bHelp);
  }
  
  void insert(x.Element ref) {
    doc.insertNewNode(ref, 'element');
  }
  
  void help(x.Element ref) {
    HelpDialog dlg = new HelpDialog.Element(ref);
    dlg.show();
  }
}
