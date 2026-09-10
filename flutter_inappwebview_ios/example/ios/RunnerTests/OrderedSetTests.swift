import XCTest

@testable import flutter_inappwebview_ios

/// Unit tests for the vendored `OrderedSet`, which replaced `OrderedCollections.OrderedSet` from
/// `apple/swift-collections`.
///
/// Worth stating why these exist at all: the plugin now hand-maintains a collection type, and the
/// only other evidence that it behaves is the integration suite, which would catch a gross failure
/// (no scripts injected) but not an ordering or de-duplication bug. Every assertion below was
/// checked to fail against a deliberately broken implementation before being kept.
class OrderedSetTests: XCTestCase {

    /// A stand-in for `UserScript`: an `NSObject` subclass that does **not** override `hash` or
    /// `isEqual:`, and that declares a value-based `static func ==` exactly as `PluginScript` does.
    private final class ScriptLike: NSObject {
        let name: String
        init(_ name: String) { self.name = name }
        static func == (lhs: ScriptLike, rhs: ScriptLike) -> Bool { lhs.name == rhs.name }
    }

    func testAppendPreservesInsertionOrder() {
        var set: OrderedSet<Int> = []
        set.append(3)
        set.append(1)
        set.append(2)
        XCTAssertEqual(Array(set), [3, 1, 2], "order must be insertion order, not sorted")
    }

    func testAppendIsASetOperation() {
        var set: OrderedSet<Int> = []
        let first = set.append(7)
        let duplicate = set.append(7)

        XCTAssertTrue(first.inserted)
        XCTAssertEqual(first.index, 0)
        XCTAssertFalse(duplicate.inserted, "a duplicate must not be inserted")
        XCTAssertEqual(duplicate.index, 0, "a duplicate reports the existing element's index")
        XCTAssertEqual(Array(set), [7], "the collection neither grew nor reordered")
    }

    func testArrayLiteralDeDuplicatesKeepingFirstPosition() {
        let set: OrderedSet<Int> = [1, 2, 1, 3, 2]
        XCTAssertEqual(Array(set), [1, 2, 3])
    }

    func testRemoveElement() {
        var set: OrderedSet<Int> = [10, 20, 30]

        XCTAssertEqual(set.remove(20), 20, "returns the removed element")
        XCTAssertEqual(Array(set), [10, 30], "order of the survivors is preserved")
        XCTAssertNil(set.remove(99), "removing an absent element returns nil")
        XCTAssertEqual(Array(set), [10, 30], "an absent removal does not mutate")
    }

    /// The bug a naive implementation ships: dropping the element from the backing array but
    /// leaving it in the membership set, so it can never be added again.
    func testRemovedElementCanBeAppendedAgain() {
        var set: OrderedSet<Int> = [10, 20, 30]
        set.remove(20)
        set.append(20)
        XCTAssertEqual(Array(set), [10, 30, 20], "re-appending puts it back, at the end")

        var byIndex: OrderedSet<String> = ["a", "b", "c"]
        byIndex.remove(at: 1)
        byIndex.append("b")
        XCTAssertEqual(Array(byIndex), ["a", "c", "b"], "same, after remove(at:)")

        var cleared: OrderedSet<Int> = [1, 2, 3]
        cleared.removeAll()
        cleared.append(1)
        XCTAssertEqual(Array(cleared), [1], "removeAll clears membership too")
    }

    func testRemoveAtIndex() {
        var set: OrderedSet<String> = ["a", "b", "c"]
        XCTAssertEqual(set.remove(at: 1), "b", "returns the element that was at the index")
        XCTAssertEqual(Array(set), ["a", "c"])
    }

    func testRemoveAll() {
        var set: OrderedSet<Int> = [1, 2, 3]
        set.removeAll()
        XCTAssertTrue(set.isEmpty)
        XCTAssertEqual(set.count, 0)
    }

    func testIndexSubscriptAndCollectionConformance() {
        let set: OrderedSet<String> = ["x", "y", "z"]
        XCTAssertEqual(set[0], "x")
        XCTAssertEqual(set[2], "z")
        XCTAssertEqual(set.count, 3)
        XCTAssertTrue(set.contains("y"))
        XCTAssertFalse(set.contains("q"))
    }

    /// The shape `WKUserContentController` actually uses: a dictionary keyed by injection time,
    /// flattened with `compactMap { $0.value }.joined()`.
    func testJoinedOverADictionaryOfSets() {
        let byInjectionTime: [Int: OrderedSet<String>] = [
            0: ["start1", "start2"],
            1: ["end1"],
        ]
        let flattened = Array(
            byInjectionTime.sorted { $0.key < $1.key }.compactMap({ $0.value }).joined()
        )
        XCTAssertEqual(flattened, ["start1", "start2", "end1"])
    }

    func testEqualityIsOrderSensitive() {
        XCTAssertEqual(OrderedSet<Int>([1, 2]), OrderedSet<Int>([1, 2]))
        XCTAssertNotEqual(
            OrderedSet<Int>([1, 2]), OrderedSet<Int>([2, 1]),
            "an ordered set with a different order is a different value"
        )
    }

    /// Pins the semantics the plugin actually depends on, and the reason it is easy to get wrong.
    ///
    /// `PluginScript` declares a value-based `static func ==`, but neither it nor `UserScript`
    /// overrides `hash`/`isEqual:`. A class inherits its `Equatable`/`Hashable` witness from
    /// `NSObject`, and a generic context dispatches through that witness rather than through an
    /// operator found by static lookup — so de-duplication here is by **identity**. That was true
    /// of `swift-collections`' implementation too, so the swap changed nothing; this test is what
    /// would catch a future "fix" that made the vendored type use the value-based operator.
    func testNSObjectElementsDeDuplicateByIdentityNotByTheValueBasedOperator() {
        let a = ScriptLike("same")
        let b = ScriptLike("same")

        XCTAssertTrue(a == b, "called directly, the static == is value-based")

        var set: OrderedSet<ScriptLike> = []
        set.append(a)
        set.append(b)

        XCTAssertEqual(set.count, 2, "two distinct instances both insert")
        XCTAssertTrue(set.remove(a) === a, "remove matches by identity")
        XCTAssertEqual(set.count, 1)
        XCTAssertTrue(set[0] === b, "the other instance survives")
    }
}
