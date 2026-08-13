#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_inappwebview_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_inappwebview_macos'
  s.version          = '0.0.1'
  s.summary          = 'macOS implementation of the flutter_inappwebview plugin.'
  s.description      = <<-DESC
macOS implementation of the flutter_inappwebview plugin, which allows you to add an
inline webview, to use an headless webview, and to open an in-app browser window.
                       DESC
  s.homepage         = 'https://inappwebview.dev/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Lorenzo Pichilli' => 'pichillilorenzo@gmail.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'flutter_inappwebview_macos/Sources/flutter_inappwebview_macos/**/*.swift'
  s.dependency 'FlutterMacOS'
  s.resource_bundles = {'flutter_inappwebview_macos_privacy' => ['flutter_inappwebview_macos/Sources/flutter_inappwebview_macos/Resources/PrivacyInfo.xcprivacy']}

  # The unofficial swift-collections podspec declares iOS support only, so the
  # CocoaPods build uses the OrderedSet pod instead. The Swift Package Manager
  # build uses apple/swift-collections directly -- see Package.swift and the
  # SWIFT_PACKAGE conditionals in Types/WKUserContentController.swift.
  s.dependency 'OrderedSet', '~>6.0.3'

  s.platform = :osx, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.9'
end
