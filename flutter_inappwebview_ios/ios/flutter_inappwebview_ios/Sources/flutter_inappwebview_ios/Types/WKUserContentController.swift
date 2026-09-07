//
//  UserContentController.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 17/02/21.
//

import Foundation
import ObjectiveC
import WebKit
import Collections

/// Boxes a Swift value so it can be stored as an associated object.
///
/// `objc_setAssociatedObject` takes an `AnyObject`, and none of the three values below
/// (`Set`, `Dictionary`, `OrderedSet`) is one.
private final class AssociatedValueBox<T> {
    var value: T
    init(_ value: T) { self.value = value }
}

extension WKUserContentController {
    static let WINDOW_ID_PREFIX = "WINDOW-ID-"

    // These three cannot be stored properties: an extension of a WebKit class cannot add storage.
    // They are associated objects, so each value lives on its own controller and dies with it.
    //
    // They replaced three `[String: …]` statics keyed by the controller's **pointer address**,
    // formatted with `String(format: "%p", …)` — the shape `WKContentWorld.windowId` had before
    // §96. `TODO.md` P4c argued this one was the more dangerous of the two, because a
    // `WKUserContentController` really is deallocated (unlike an interned content world) and so its
    // address really can be handed to a later one, which would inherit a dead WebView's content
    // worlds and plugin scripts.
    //
    // **Measured before replacing it (§143), and it could not happen**: across a full
    // `in_app_webview` run on iOS 26.5, 127 controllers were initialized and **none** found an
    // existing entry under its address, with the three maps never holding more than two entries at
    // once. The reason is structural rather than lucky — `prepareAndAddUserScripts()` returns early
    // when `windowId != nil`, because a `window.open` child shares its opener's configuration *and
    // therefore its controller*, so only a top-level WebView's controller is ever keyed here, and a
    // top-level WebView always reaches `dispose(windowId: nil)`, which removed the entries.
    //
    // What an associated object changes is that none of that has to stay true. The old code was
    // correct only while "every keyed controller is disposed exactly once" held, and nothing
    // enforced it or would have reported its breaking.

    private static var contentWorldsKey: UInt8 = 0
    var contentWorlds: Set<WKContentWorld> {
        get {
            (objc_getAssociatedObject(self, &WKUserContentController.contentWorldsKey)
                as? AssociatedValueBox<Set<WKContentWorld>>)?.value ?? []
        }
        set {
            objc_setAssociatedObject(
                self,
                &WKUserContentController.contentWorldsKey,
                AssociatedValueBox(newValue),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    private static var userOnlyScriptsKey: UInt8 = 0
    var userOnlyScripts: [WKUserScriptInjectionTime:OrderedSet<UserScript>] {
        get {
            (objc_getAssociatedObject(self, &WKUserContentController.userOnlyScriptsKey)
                as? AssociatedValueBox<[WKUserScriptInjectionTime:OrderedSet<UserScript>]>)?.value ?? [:]
        }
        set {
            objc_setAssociatedObject(
                self,
                &WKUserContentController.userOnlyScriptsKey,
                AssociatedValueBox(newValue),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    private static var pluginScriptsKey: UInt8 = 0
    var pluginScripts: [WKUserScriptInjectionTime:OrderedSet<PluginScript>] {
        get {
            (objc_getAssociatedObject(self, &WKUserContentController.pluginScriptsKey)
                as? AssociatedValueBox<[WKUserScriptInjectionTime:OrderedSet<PluginScript>]>)?.value ?? [:]
        }
        set {
            objc_setAssociatedObject(
                self,
                &WKUserContentController.pluginScriptsKey,
                AssociatedValueBox(newValue),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    public func initialize () {
        contentWorlds = Set([WKContentWorld.page])

        pluginScripts = [
            .atDocumentStart: [],
            .atDocumentEnd: [],
        ]
        userOnlyScripts = [
            .atDocumentStart: [],
            .atDocumentEnd: [],
        ]
    }

    public func dispose (windowId: Int64?) {
        if windowId == nil {
            // The three `removeValue(forKey: tmpAddress)` calls that used to follow each of these
            // are gone: the storage is associated with this controller and is released with it.
            // Emptying eagerly is still worth doing — it drops the scripts and worlds now rather
            // than whenever the controller itself goes.
            contentWorlds.removeAll()
            pluginScripts.removeAll()
            userOnlyScripts.removeAll()
        }
        else if let windowId = windowId {
            let contentWorldsToRemove = contentWorlds.filter({ $0.windowId == windowId })
            for contentWorld in contentWorldsToRemove {
                contentWorlds.remove(contentWorld)
                removeAllScriptMessageHandlers(from: contentWorld)
            }
        }
    }

    /// Registers the plugin's message handlers as **`WKScriptMessageHandlerWithReply`**, so
    /// `postMessage` returns a JavaScript `Promise` that WebKit settles from the reply block.
    ///
    /// The two protocols are mutually exclusive per name **per content world** — the header is
    /// explicit that a `WKScriptMessageHandler` and a `WKScriptMessageHandlerWithReply` "will
    /// conflict with each other if you try to add them to the same `WKContentWorld` with the same
    /// name" — which is why the removes below are not optional and why nothing in this module
    /// registers the plain variant any more.
    ///
    /// There is no name-only overload for the with-reply API; `WKContentWorld.page` is what the
    /// name-only `add(_:name:)` documents itself as being equivalent to.
    public func sync(scriptMessageHandler: WKScriptMessageHandlerWithReply) {
        let pluginScriptsList = pluginScripts.compactMap({ $0.value }).joined()
        for pluginScript in pluginScriptsList {
            if !containsPluginScript(pluginScript: pluginScript) {
                addUserScript(pluginScript)
                for messageHandlerName in pluginScript.messageHandlerNames {
                    removeScriptMessageHandler(forName: messageHandlerName)
                    addScriptMessageHandler(scriptMessageHandler, contentWorld: .page, name: messageHandlerName)
                }
            }
            if pluginScript.requiredInAllContentWorlds {
                for contentWorld in contentWorlds {
                    if !containsPluginScript(pluginScript: pluginScript, in: contentWorld) {
                        let pluginScriptWithContentWorld = pluginScript.copyAndSet(contentWorld: contentWorld)
                        addUserScript(pluginScriptWithContentWorld)
                        for messageHandlerName in pluginScriptWithContentWorld.messageHandlerNames {
                            removeScriptMessageHandler(forName: messageHandlerName, contentWorld: contentWorld)
                            addScriptMessageHandler(scriptMessageHandler, contentWorld: contentWorld, name: messageHandlerName)
                        }
                    }
                }
            }
        }

        let userOnlyScriptsList = userOnlyScripts.compactMap({ $0.value }).joined()
        for userOnlyScript in userOnlyScriptsList {
            if !userScripts.contains(userOnlyScript) {
                addUserScript(userOnlyScript)
            }
        }
    }

    public func addUserOnlyScript(_ userOnlyScript: UserScript) {
        contentWorlds.insert(userOnlyScript.contentWorld)

        userOnlyScripts[userOnlyScript.injectionTime]!.append(userOnlyScript)
    }

    public func addUserOnlyScripts(_ userOnlyScripts: [UserScript]) {
        for userOnlyScript in userOnlyScripts {
            addUserOnlyScript(userOnlyScript)
        }
    }

    public func addPluginScript(_ pluginScript: PluginScript) {
        contentWorlds.insert(pluginScript.contentWorld)

        pluginScripts[pluginScript.injectionTime]!.append(pluginScript)
    }

    public func addPluginScripts(_ pluginScripts: [PluginScript]) {
        for pluginScript in pluginScripts {
            addPluginScript(pluginScript)
        }
    }

    public func getPluginScriptsRequiredInAllContentWorlds() -> [PluginScript] {
        return pluginScripts.compactMap({ $0.value })
            .joined()
            .filter({ $0.injectionTime == .atDocumentStart && $0.requiredInAllContentWorlds })
    }

    public func generateCodeForScriptEvaluation(scriptMessageHandler: WKScriptMessageHandlerWithReply, source: String, contentWorld: WKContentWorld) -> String {
        let (inserted, _) = contentWorlds.insert(contentWorld)
        if inserted {
            var generatedCode = ""
            let pluginScriptsRequired = getPluginScriptsRequiredInAllContentWorlds()
            for pluginScript in pluginScriptsRequired {
                generatedCode += pluginScript.source + "\n"
                for messageHandlerName in pluginScript.messageHandlerNames {
                    removeScriptMessageHandler(forName: messageHandlerName, contentWorld: contentWorld)
                    addScriptMessageHandler(scriptMessageHandler, contentWorld: contentWorld, name: messageHandlerName)
                }
            }
            if let windowId = contentWorld.windowId {
                generatedCode += "\(WindowIdJS.WINDOW_ID_VARIABLE_JS_SOURCE()) = \(String(windowId));\n"
            }
            return generatedCode + "\n" + source
        }
        return source
    }

    public func removeUserOnlyScript(_ userOnlyScript: UserScript) {
        userOnlyScripts[userOnlyScript.injectionTime]!.remove(userOnlyScript)
        removeUserScript(scriptToRemove: userOnlyScript)
    }

    public func removeUserOnlyScript(at index: Int, injectionTime: WKUserScriptInjectionTime) {
        let scriptToRemove = userOnlyScripts[injectionTime]![index]
        userOnlyScripts[injectionTime]!.remove(at: index)
        removeUserScript(scriptToRemove: scriptToRemove)
    }

    public func removeAllUserOnlyScripts() {
        let allUserOnlyScripts = Array(userOnlyScripts.compactMap({ $0.value }).joined())

        userOnlyScripts[.atDocumentStart]!.removeAll()
        userOnlyScripts[.atDocumentEnd]!.removeAll()

        removeUserScripts(scriptsToRemove: allUserOnlyScripts)
    }

    public func removePluginScript(_ pluginScript: PluginScript) {
        pluginScripts[pluginScript.injectionTime]!.remove(pluginScript)
        for messageHandlerName in pluginScript.messageHandlerNames {
            removeScriptMessageHandler(forName: messageHandlerName)
            for contentWorld in contentWorlds {
                removeScriptMessageHandler(forName: messageHandlerName, contentWorld: contentWorld)
            }

        }
        removeUserScript(scriptToRemove: pluginScript)
    }

    public func removeAllPluginScripts() {
        let allPluginScripts = Array(pluginScripts.compactMap({ $0.value }).joined())

        pluginScripts[.atDocumentStart]!.removeAll()
        pluginScripts[.atDocumentEnd]!.removeAll()

        removeUserScripts(scriptsToRemove: allPluginScripts)
    }

    public func removeAllPluginScriptMessageHandlers() {
        let allPluginScripts = pluginScripts.compactMap({ $0.value }).joined()
        for pluginScript in allPluginScripts {
            for messageHandlerName in pluginScript.messageHandlerNames {
                removeScriptMessageHandler(forName: messageHandlerName)
            }
        }
        removeAllScriptMessageHandlers()
        for contentWorld in contentWorlds {
            removeAllScriptMessageHandlers(from: contentWorld)
        }

    }

    public func resetContentWorlds(windowId: Int64?) {
        let allUserOnlyScripts = userOnlyScripts.compactMap({ $0.value }).joined()
        let contentWorldsFiltered = contentWorlds.filter({ $0.windowId == windowId && $0 != WKContentWorld.page })
        for contentWorld in contentWorldsFiltered {
            var found = false
            for script in allUserOnlyScripts {
                if script.contentWorld == contentWorld {
                    found = true
                    break
                }
            }
            if !found {
                contentWorlds.remove(contentWorld)
            }
        }
    }

    private func removeUserScript(scriptToRemove: WKUserScript, shouldAddPreviousScripts: Bool = true) -> Void {
        // there isn't a way to remove a specific user script using WKUserContentController,
        // so we remove all the user scripts and, then, we add them again without the one that has been removed
        let userScripts = useCopyOfUserScripts()

        var userScriptsUpdated: [WKUserScript] = []
        for script in userScripts {
            if script != scriptToRemove {
                userScriptsUpdated.append(script)
            }
        }

        removeAllUserScripts()

        if shouldAddPreviousScripts {
            for script in userScriptsUpdated {
                addUserScript(script)
            }
        }
    }

    private func removeUserScripts(scriptsToRemove: [WKUserScript], shouldAddPreviousScripts: Bool = true) -> Void {
        // there isn't a way to remove a specific user script using WKUserContentController,
        // so we remove all the user scripts and, then, we add them again without the one that has been removed
        let userScripts = useCopyOfUserScripts()

        var userScriptsUpdated: [WKUserScript] = []
        for script in userScripts {
            if !scriptsToRemove.contains(script) {
                userScriptsUpdated.append(script)
            }
        }

        removeAllUserScripts()

        if shouldAddPreviousScripts {
            for script in userScriptsUpdated {
                addUserScript(script)
            }
        }
    }

    public func removeUserOnlyScripts(with groupName: String, shouldAddPreviousScripts: Bool = true) -> Void {
        let allUserOnlyScripts = userOnlyScripts.compactMap({ $0.value }).joined()
        var scriptsToRemove: [UserScript] = []
        for script in allUserOnlyScripts {
            if let scriptName = script.groupName, scriptName == groupName {
                scriptsToRemove.append(script)
                userOnlyScripts[script.injectionTime]!.remove(script)
            }
        }
        removeUserScripts(scriptsToRemove: scriptsToRemove, shouldAddPreviousScripts: shouldAddPreviousScripts)
    }

    public func removePluginScripts(with groupName: String, shouldAddPreviousScripts: Bool = true) -> Void {
        let allPluginScripts = pluginScripts.compactMap({ $0.value }).joined()
        var scriptsToRemove: [PluginScript] = []
        for script in allPluginScripts {
            if let scriptName = script.groupName, scriptName == groupName {
                scriptsToRemove.append(script)
                pluginScripts[script.injectionTime]!.remove(script)
            }
        }
        removeUserScripts(scriptsToRemove: scriptsToRemove, shouldAddPreviousScripts: shouldAddPreviousScripts)
    }

    public func containsPluginScript(pluginScript: PluginScript) -> Bool {
        let userScripts = useCopyOfUserScripts()
        for script in userScripts {
            if let script = script as? PluginScript, script == pluginScript {
                return true
            }
        }
        return false
    }
    
    public func containsPluginScript(with groupName: String) -> Bool {
        let userScripts = useCopyOfUserScripts()
        for script in userScripts {
            if let script = script as? PluginScript, script.groupName == groupName {
                return true
            }
        }
        return false
    }

    public func containsPluginScript(pluginScript: PluginScript, in contentWorld: WKContentWorld) -> Bool {
        let userScripts = useCopyOfUserScripts()
        for script in userScripts {
            if let script = script as? PluginScript, script == pluginScript, script.contentWorld == contentWorld {
                return true
            }
        }
        return false
    }
    
    public func containsPluginScript(with groupName: String, in contentWorld: WKContentWorld) -> Bool {
        let userScripts = useCopyOfUserScripts()
        for script in userScripts {
            if let script = script as? PluginScript, script.groupName == groupName, script.contentWorld == contentWorld {
                return true
            }
        }
        return false
    }

    public func getContentWorlds(with windowId: Int64?) -> Set<WKContentWorld> {
        var contentWorldsFiltered = Set([WKContentWorld.page])
        let contentWorlds = Array(self.contentWorlds)
        for contentWorld in contentWorlds {
            if contentWorld.windowId == windowId {
                contentWorldsFiltered.insert(contentWorld)
            }
        }
        return contentWorldsFiltered
    }

    // use a copy of self.userScripts to avoid EXC_BREAKPOINT at runtime if self.userScripts gets removed when another code is looping them
    private func useCopyOfUserScripts() -> [WKUserScript] {
        return Array(self.userScripts)
    }
}
