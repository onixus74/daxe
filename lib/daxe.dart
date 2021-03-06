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

/**
 * This class' [main] method is called to initialize Daxe. It is also possible
 * to create a customized editor derived from Daxe by creating a separate class
 * and setting custom display types before calling [initDaxe].
 * 
 * The URL must have the file and config parameters with the path to the XML file and Jaxe config file.
 * It can also have a save parameter with the path to a server script to save the document.
 */
library daxe;

import 'dart:async';
import 'dart:collection';
//import 'dart:convert';
import 'dart:html' as h;

//import 'package:meta/meta.dart';
//import 'package:js/js.dart' as js;

import 'src/xmldom/xmldom.dart' as x;
import 'src/strings.dart';

import 'src/interface_schema.dart';
import 'src/wxs/wxs.dart' show DaxeWXS, WXSException;
import 'src/simple_schema.dart';
import 'src/nodes/nodes.dart';

part 'src/attribute_dialog.dart';
part 'src/css_map.dart';
part 'src/cursor.dart';
part 'src/daxe_document.dart';
part 'src/daxe_exception.dart';
part 'src/config.dart';
part 'src/daxe_node.dart';
part 'src/daxe_attr.dart';
part 'src/find_dialog.dart';
part 'src/find_element_dialog.dart';
part 'src/help_dialog.dart';
part 'src/insert_panel.dart';
part 'src/left_panel.dart';
part 'src/locale.dart';
part 'src/menu.dart';
part 'src/menubar.dart';
part 'src/menu_item.dart';
part 'src/node_factory.dart';
part 'src/file_chooser.dart';
part 'src/position.dart';
part 'src/node_offset_position.dart';
part 'src/left_offset_position.dart';
part 'src/right_offset_position.dart';
part 'src/source_window.dart';
part 'src/symbol_dialog.dart';
part 'src/tag.dart';
part 'src/toolbar.dart';
part 'src/toolbar_item.dart';
part 'src/toolbar_box.dart';
part 'src/toolbar_menu.dart';
part 'src/toolbar_button.dart';
part 'src/toolbar_style_info.dart';
part 'src/tree_item.dart';
part 'src/tree_panel.dart';
part 'src/undoable_edit.dart';
part 'src/unknown_element_dialog.dart';
part 'src/validation_dialog.dart';
part 'src/web_page.dart';


/// A function with no argument
typedef void ActionFunction();

/// The current web page
WebPage page;
/// The current XML document
DaxeDocument doc;
/// Map name->function of functions callable from menus defined in the config
Map<String,ActionFunction> customFunctions = new Map<String,ActionFunction>();

void main() {
  NodeFactory.addCoreDisplayTypes();
  
  Strings.load().then((bool b) {
    initDaxe();
  }).catchError((e) {
    h.document.body.appendText('Error when loading the strings in LocalStrings_en.properties.');
  });
}

/**
 * This Future can be used to initialize Daxe and customize the user interface afterwards.
 * The display types and the strings have to be loaded before this method is called
 * (with [NodeFactory.addCoreDisplayTypes] and [Strings.load]).
 * In the Daxe application, the results of the Future are not used.
 * The optional [left] parameter can be used to extend the LeftPanel class.
 * An optional [saveFunction] parameter can be passed to customize saving documents.
 * An optional [customizeToolbar] parameter can be passed to customize the toolbar
 * (it is called after page.toolbar is created but before the HTML is generated).
 */
Future initDaxe({LeftPanel left, ActionFunction saveFunction,
    ActionFunction customizeToolbar}) {
  Completer completer = new Completer();
  
  // check parameters for a config and file to open
  String file = null;
  String config = null;
  String saveURL = null; // URL for saving file, will trigger the display of the save menu
  bool application = false; // Desktop application (open and quit menus)
  h.Location location = h.window.location;
  String search = location.search;
  if (search.startsWith('?'))
    search = search.substring(1);
  List<String> parameters = search.split('&');
  for (String param in parameters) {
    List<String> lparam = param.split('=');
    if (lparam.length != 2)
      continue;
    if (lparam[0] == 'config')
      config = lparam[1];
    else if (lparam[0] == 'file')
      file = Uri.decodeComponent(lparam[1]);
    else if (lparam[0] == 'save')
      saveURL = lparam[1];
    else if (lparam[0] == 'application' && lparam[1] == 'true')
      application = true;
  }
  doc = new DaxeDocument();
  page = new WebPage(application:application, left:left, saveFunction:saveFunction,
    customizeToolbar: customizeToolbar);
  if (saveURL != null)
    doc.saveURL = saveURL;
  if (config != null && file != null)
    page.openDocument(file, config).then((v) => completer.complete());
  else if (config != null)
    page.newDocument(config).then((v) => completer.complete());
  else {
    h.window.alert(Strings.get('daxe.missing_config'));
    completer.completeError(Strings.get('daxe.missing_config'));
  }
  return(completer.future);
}

/**
 * Adds a custom display type or changes a core one.
 * Two constructors are required to define the display type:
 * 
 * * one to create a new node, with the element reference in the schema as a parameter;
 *   [Config] methods can be used via doc.cfg to obtain useful information with the reference.
 * * another one to create a new Daxe node based on a DOM [x.Node];
 *   it takes the future [DaxeNode] parent as a 2nd parameter.
 */
void setDisplayType(String displayType, ConstructorFromRef cref, ConstructorFromNode cnode) {
  NodeFactory.setDisplayType(displayType, cref, cnode);
}

/**
 * Adds a custom function which can be called by name with a menu defined in the configuration file.
 */
void addCustomFunction(String functionName, ActionFunction fct) {
  customFunctions[functionName] = fct;
}
