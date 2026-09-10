//
//  OrderedSet.swift
//  flutter_inappwebview
//

import Foundation

/// An insertion-ordered collection of unique elements.
///
/// This replaces `OrderedCollections.OrderedSet` from `apple/swift-collections`, which the plugin
/// depended on for **one type in one file** — `WKUserContentController`'s two script dictionaries.
/// The dependency cost more than it looks: SPM resolved `swift-collections` 1.6.0 while the
/// CocoaPods podspec pinned `~> 1.1.1`, because 1.1.1 is the only version ever published to
/// CocoaPods trunk (by a third party, not Apple), so the two integration paths compiled *different
/// versions of a dependency* — and the CocoaPods umbrella pod builds six modules
/// (`BitCollections`, `DequeModule`, `HashTreeCollections`, `HeapModule`, `OrderedCollections` and
/// `InternalCollectionsUtilities`) to supply the single type used here.
///
/// **Deliberately not a general-purpose port.** It implements only the surface
/// `WKUserContentController` uses — `append`, `remove(_:)`, `remove(at:)`, `removeAll`, index
/// subscripting, array-literal construction and iteration — with the same semantics as the original
/// for each. It is `internal`: nothing in the plugin's public API exposes it, so consumers who use
/// `swift-collections` themselves see no name collision.
///
/// **On equality.** Uniqueness is decided by `Element: Hashable`, exactly as the original decided
/// it. For the two element types here that resolves to `NSObject` identity: `UserScript` derives
/// from `WKUserScript` and neither it nor `PluginScript` overrides `hash` or `isEqual:`.
/// `PluginScript`'s `static func ==` does **not** change this — a class inherits its `Equatable`
/// witness from `NSObject`, and a generic context like this one dispatches through that witness
/// rather than through an operator overload found by static lookup. Behaviour is therefore
/// unchanged by the swap, and it was already identity-based before it.
struct OrderedSet<Element: Hashable> {
    /// **One storage, deliberately.** A first version kept a parallel `Set` for membership beside
    /// this array, which is what the real `OrderedCollections.OrderedSet` does for its asymptotics.
    /// It was a mistake at this size: the two can fall out of step, and a mutation test proved the
    /// suite could not tell — removing an element from the array while leaving it in the `Set` kept
    /// every test green, because `append` consulted the array and `remove` consulted the `Set`.
    /// With a single array there is nothing to desynchronise. These collections hold a handful of
    /// injected scripts, so the linear membership scan costs nothing measurable.
    private var elements: [Element] = []

    init() {}

    init<S: Sequence>(_ sequence: S) where S.Element == Element {
        for element in sequence {
            append(element)
        }
    }

    /// Appends [element] if it is not already a member.
    ///
    /// Mirrors the original's return shape: whether it was inserted, and the index it occupies
    /// either way. Both call sites discard it.
    @discardableResult
    mutating func append(_ element: Element) -> (inserted: Bool, index: Int) {
        if let existing = elements.firstIndex(of: element) {
            return (false, existing)
        }
        elements.append(element)
        return (true, elements.count - 1)
    }

    /// Removes [element] if present, returning it. Returns nil when it was not a member.
    @discardableResult
    mutating func remove(_ element: Element) -> Element? {
        guard let index = elements.firstIndex(of: element) else {
            return nil
        }
        return elements.remove(at: index)
    }

    /// Removes and returns the element at [index]. Traps when out of range, like `Array`.
    @discardableResult
    mutating func remove(at index: Int) -> Element {
        elements.remove(at: index)
    }

    mutating func removeAll() {
        elements.removeAll()
    }

    func contains(_ element: Element) -> Bool {
        elements.contains(element)
    }
}

extension OrderedSet: RandomAccessCollection {
    var startIndex: Int { elements.startIndex }
    var endIndex: Int { elements.endIndex }

    subscript(position: Int) -> Element {
        elements[position]
    }

    func index(after i: Int) -> Int { elements.index(after: i) }
    func index(before i: Int) -> Int { elements.index(before: i) }
}

extension OrderedSet: ExpressibleByArrayLiteral {
    init(arrayLiteral literalElements: Element...) {
        self.init(literalElements)
    }
}

extension OrderedSet: Equatable {
    static func == (lhs: OrderedSet<Element>, rhs: OrderedSet<Element>) -> Bool {
        lhs.elements == rhs.elements
    }
}

extension OrderedSet: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(elements)
    }
}

extension OrderedSet: CustomStringConvertible {
    var description: String { "\(elements)" }
}

extension OrderedSet: Sendable where Element: Sendable {}
