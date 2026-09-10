import Flutter
import UIKit
import XCTest

@testable import flutter_inappwebview_ios

/// Smoke test for the test target itself.
///
/// This file used to hold the unmodified Flutter template test, which constructed
/// `FlutterInappwebviewIosPlugin` and sent it a `getPlatformVersion` method call. **Neither
/// exists**: the plugin class is `InAppWebViewFlutterPlugin` and it has never implemented a
/// `getPlatformVersion` handler. It did not compile, so nothing in this target had ever run — the
/// target also could not build at all until the example's deployment target was raised to match the
/// plugin's iOS 15.0 floor.
///
/// What is left is deliberately minimal: it proves `@testable import` reaches the plugin module, so
/// that a failure in a sibling test file is a real failure rather than a dead harness.
class RunnerTests: XCTestCase {

    func testPluginModuleIsReachable() {
        XCTAssertNotNil(InAppWebViewFlutterPlugin.self)
    }
}
