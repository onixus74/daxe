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

class MenuItem {
  static int itemidcount = 0;
  String itemid;
  String _title;
  Object parent; // Menu, Menubar or Toolbar
  ActionFunction action;
  String shortcut;
  Object data;
  bool enabled;
  bool selected;
  bool is_separator;
  String toolTipText;
  bool checked;
  
  MenuItem(this._title, this.action, {this.shortcut, this.data}) {
    this.itemid = "item_$itemidcount";
    itemidcount++;
    parent = null;
    enabled = true;
    selected = false;
    is_separator = false;
    checked = false;
  }
  
  MenuItem.separator() {
    is_separator = true;
    enabled = false;
    checked = false;
    selected = false;
  }
  
  h.Element htmlItem() {
    h.TableRowElement tr = new h.TableRowElement();
    if (is_separator) {
      h.TableCellElement td = new h.TableCellElement();
      td.append(new h.HRElement());
      tr.append(td);
    } else {
      tr.id = itemid;
      tr.setAttribute('tabindex', '-1');
      tr.onKeyDown.listen((h.KeyboardEvent event) {
        int keyCode = event.keyCode;
        if (keyCode == h.KeyCode.ENTER) {
          event.preventDefault();
          closeMenu();
          activate();
        } else if (keyCode == h.KeyCode.UP) {
          (parent as Menu).selectPrevious(this);
        } else if (keyCode == h.KeyCode.DOWN) {
          (parent as Menu).selectNext(this);
        } else if (keyCode == h.KeyCode.LEFT) {
          if ((parent as Menu).parent is Menu) {
            (parent as Menu).hide();
            (parent as Menu).getItemHTMLNode().focus();
            event.preventDefault();
            event.stopPropagation();
          }
          else if ((parent as Menu).parent is MenuBar)
            ((parent as Menu).parent as MenuBar).selectPrevious(parent as Menu);
        } else if (keyCode == h.KeyCode.RIGHT) {
          Object ancestor = parent;
          while (ancestor is Menu)
            ancestor = (ancestor as Menu).parent;
          if (ancestor is MenuBar)
            ancestor.selectNext(null);
        } else if (keyCode == h.KeyCode.TAB) {
          Timer.run(closeMenu);
        }
      });
      h.TableCellElement td = new h.TableCellElement();
      td.text = _title;
      td.onMouseUp.listen((h.MouseEvent event) => activate());
      td.onMouseOver.listen((h.MouseEvent event) {
        if (enabled)
          select();
      });
      td.onMouseOut.listen((h.MouseEvent event) => deselect());
      tr.append(td);
      td = new h.TableCellElement();
      if (this.shortcut != null)
        td.text = "Ctrl+$shortcut";
      td.onMouseUp.listen((h.MouseEvent event) => activate());
      td.onMouseOver.listen((h.MouseEvent event) {
        if (enabled)
          select();
      });
      td.onMouseOut.listen((h.MouseEvent event) => deselect());
      if (checked)
        tr.classes.add('checked');
      tr.append(td);
      if (!enabled)
        tr.classes.add('disabled');
    }
    if (toolTipText != null)
      tr.title = toolTipText;
    return(tr);
  }
  
  h.Element getItemHTMLNode() {
    return(h.querySelector("#$itemid"));
  }
  
  void activate() {
    if (!enabled)
      return;
    page.focusCursor();
    action();
  }
  
  void select() {
    if (selected)
      return;
    selected = true;
    h.Element tr = getItemHTMLNode();
    tr.classes.add('selected');
    if (this is Menu) {
      (this as Menu).show();
    }
    if (parent is Menu)
      (parent as Menu).deselectOtherItems(this);
    tr.focus();
  }
  
  void deselect() {
    if (!selected)
      return;
    selected = false;
    h.Element tr = getItemHTMLNode();
    if (tr != null) {
      tr.classes.remove('selected');
      tr.blur();
    }
    if (this is Menu) {
      (this as Menu).hide();
    }
  }
  
  void disable() {
    if (!enabled)
      return;
    enabled = false;
    h.Element tr = getItemHTMLNode();
    tr.classes.remove('selected');
    tr.classes.add('disabled');
    if (parent is Menu)
      (parent as Menu).checkEnabled();
  }
  
  void enable() {
    if (enabled)
      return;
    enabled = true;
    h.Element tr = getItemHTMLNode();
    tr.classes.remove('disabled');
    if (parent is Menu)
      (parent as Menu).checkEnabled();
  }
  
  void check() {
    if (checked)
      return;
    checked = true;
    h.Element tr = getItemHTMLNode();
    tr.classes.add('checked');
  }
  
  void uncheck() {
    if (!checked)
      return;
    checked = false;
    h.Element tr = getItemHTMLNode();
    tr.classes.remove('checked');
  }
  
  /*
  void close() {
    if (parent != null)
      parent.close();
  }
  */
  
  String get title {
    return(_title);
  }
  
  void set title(String title) {
    _title = title;
    h.TableRowElement tr = h.querySelector("#$itemid");
    h.TableCellElement td = tr.nodes.first;
    td.text = title;
  }
  
  void closeMenu() {
    if (parent is! Menu)
      return;
    Menu ancestorMenu = parent;
    while (ancestorMenu.parent is Menu)
      ancestorMenu = ancestorMenu.parent;
    if (ancestorMenu.parent is MenuBar)
      (ancestorMenu.parent as MenuBar).hideVisibleMenu();
    else
      ancestorMenu.hide();
  }
}
