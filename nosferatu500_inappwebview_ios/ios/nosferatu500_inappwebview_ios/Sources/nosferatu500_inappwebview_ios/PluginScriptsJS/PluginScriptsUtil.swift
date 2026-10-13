//
//  PluginScripts.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 16/02/21.
//

import Foundation

public class PluginScriptsUtil {
    public static let VAR_PLACEHOLDER_VALUE = "$IN_APP_WEBVIEW_PLACEHOLDER_VALUE"

    public static let GET_SELECTED_TEXT_JS_SOURCE = """
(function(){
    var txt;
    if (window.getSelection) {
      txt = window.getSelection().toString();
    } else if (window.document.getSelection) {
      txt = window.document.getSelection().toString();
    } else if (window.document.selection) {
      txt = window.document.selection.createRange().text;
    }
    return txt;
})();
"""
}
