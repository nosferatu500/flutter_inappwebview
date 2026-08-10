#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_inappwebview_ios.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_inappwebview_ios'
  s.version          = '0.0.1'
  s.summary          = 'iOS implementation of the flutter_inappwebview plugin.'
  s.description      = <<-DESC
iOS implementation of the flutter_inappwebview plugin, which allows you to add an
inline webview, to use an headless webview, and to open an in-app browser window.
                       DESC
  s.homepage         = 'https://inappwebview.dev/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Lorenzo Pichilli' => 'pichillilorenzo@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_inappwebview_ios/Sources/flutter_inappwebview_ios/**/*.swift'
  s.resources = 'flutter_inappwebview_ios/Sources/flutter_inappwebview_ios/Resources/**/*.storyboard'
  s.dependency 'Flutter'
  s.resource_bundles = {'flutter_inappwebview_ios_privacy' => ['flutter_inappwebview_ios/Sources/flutter_inappwebview_ios/Resources/PrivacyInfo.xcprivacy']}

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.dependency 'swift-collections', '~>1.1.1'

  s.swift_version = '5.9'

  s.platform = :ios, '13.0'
end
