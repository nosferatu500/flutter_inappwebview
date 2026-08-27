import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/models/setting_definition.dart';

List<T> _safeEnumValues<T>(Iterable<T> Function() getter) {
  try {
    return getter().toList();
  } catch (_) {
    return <T>[];
  }
}

/// Get all setting definitions organized by category.
Map<String, List<SettingDefinition>> getSettingDefinitions() {
  return {
    'General': [
      SettingDefinition(
        name: 'JavaScript Enabled',
        description: 'Enable JavaScript execution in the WebView',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.javaScriptEnabled,
      ),
      SettingDefinition(
        name: 'User Agent',
        description: 'Custom user-agent string for the WebView',
        type: SettingType.string,
        defaultValue: '',
        property: InAppWebViewSettingsProperty.userAgent,
      ),
      SettingDefinition(
        name: 'Application Name for User Agent',
        description: 'Append to the existing user-agent',
        type: SettingType.string,
        defaultValue: '',
        property: InAppWebViewSettingsProperty.applicationNameForUserAgent,
      ),
      SettingDefinition(
        name: 'Cache Enabled',
        description: 'Enable browser caching',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.cacheEnabled,
      ),
      SettingDefinition(
        name: 'Incognito Mode',
        description: 'Open browser in incognito/private mode',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.incognito,
      ),
      SettingDefinition(
        name: 'Support Zoom',
        description: 'Enable zoom gestures and controls',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.supportZoom,
      ),
    ],
    'Layout': [
      SettingDefinition(
        name: 'Use Wide ViewPort',
        description: 'Enable support for HTML viewport meta tag',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.useWideViewPort,
      ),
      SettingDefinition(
        name: 'Load With Overview Mode',
        description: 'Zoom out content to fit on screen',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.loadWithOverviewMode,
      ),
      SettingDefinition(
        name: 'Minimum Font Size',
        description: 'Minimum font size in pixels',
        type: SettingType.integer,
        defaultValue: 8,
        property: InAppWebViewSettingsProperty.minimumFontSize,
      ),
      SettingDefinition(
        name: 'Default Font Size',
        description: 'Default font size in pixels',
        type: SettingType.integer,
        defaultValue: 16,
        property: InAppWebViewSettingsProperty.defaultFontSize,
      ),
      SettingDefinition(
        name: 'Default Text Encoding',
        description: 'Default text encoding for HTML pages',
        type: SettingType.string,
        defaultValue: 'UTF-8',
        property: InAppWebViewSettingsProperty.defaultTextEncodingName,
      ),
    ],
    'Content': [
      SettingDefinition(
        name: 'Download Favicons',
        description:
            'Fetch page favicons — this also gates the onReceivedIcon event (Android)',
        type: SettingType.boolean,
        defaultValue: null,
        property: InAppWebViewSettingsProperty.downloadFaviconsEnabled,
      ),
      SettingDefinition(
        name: 'Adaptive Image Glyph',
        description:
            'Allow Genmoji and other adaptive image glyphs in editable content (iOS)',
        type: SettingType.boolean,
        defaultValue: null,
        property: InAppWebViewSettingsProperty.supportsAdaptiveImageGlyph,
      ),
      SettingDefinition(
        name: 'Allow Content Access',
        description: 'Enable content URL access',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.allowContentAccess,
      ),
      SettingDefinition(
        name: 'Allow File Access',
        description: 'Enable file system access',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.allowFileAccess,
      ),
      SettingDefinition(
        name: 'Allow File Access From File URLs',
        description: 'Allow file:// URLs to access other file:// URLs',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.allowFileAccessFromFileURLs,
      ),
      SettingDefinition(
        name: 'Allow Universal Access From File URLs',
        description: 'Allow file:// URLs to access any origin',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.allowUniversalAccessFromFileURLs,
      ),
      SettingDefinition(
        name: 'Block Network Images',
        description: 'Block loading images from the network',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.blockNetworkImage,
      ),
      SettingDefinition(
        name: 'Block Network Loads',
        description: 'Block all network resource loading',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.blockNetworkLoads,
      ),
    ],
    'Media': [
      SettingDefinition(
        name: 'Media Requires User Gesture',
        description: 'Require user interaction to play media',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.mediaPlaybackRequiresUserGesture,
      ),
      SettingDefinition(
        name: 'Allows Inline Media Playback',
        description: 'Allow HTML5 media to play inline',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.allowsInlineMediaPlayback,
      ),
      SettingDefinition(
        name: 'Allows AirPlay',
        description: 'Allow AirPlay for media playback',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.allowsAirPlayForMediaPlayback,
      ),
      SettingDefinition(
        name: 'Allows Picture-in-Picture',
        description: 'Allow videos to play in picture-in-picture',
        type: SettingType.boolean,
        defaultValue: true,
        property:
            InAppWebViewSettingsProperty.allowsPictureInPictureMediaPlayback,
      ),
      SettingDefinition(
        name: 'Auto Adjust Scroll Indicator Insets',
        description: 'Automatically adjust scroll indicator insets',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty
            .automaticallyAdjustsScrollIndicatorInsets,
      ),
    ],
    'JavaScript': [
      SettingDefinition(
        name: 'JS Can Open Windows',
        description: 'Allow JavaScript to open windows automatically',
        type: SettingType.boolean,
        defaultValue: false,
        property:
            InAppWebViewSettingsProperty.javaScriptCanOpenWindowsAutomatically,
      ),
      SettingDefinition(
        name: 'JavaScript Bridge Enabled',
        description: 'Enable the JavaScript bridge',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.javaScriptBridgeEnabled,
      ),
      SettingDefinition(
        name: 'JS Bridge Main Frame Only',
        description: 'Restrict JavaScript bridge to main frame',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.javaScriptBridgeForMainFrameOnly,
      ),
    ],
    'Security': [
      SettingDefinition(
        name: 'Mixed Content Mode',
        description: 'How to handle mixed HTTP/HTTPS content',
        type: SettingType.enumeration,
        defaultValue: null,
        enumValues: _safeEnumValues(() => MixedContentMode.values),
        property: InAppWebViewSettingsProperty.mixedContentMode,
      ),
      SettingDefinition(
        name: 'Use On Show File Chooser',
        description:
            'Route file-upload pickers to the onShowFileChooser event — needed on '
            'iOS 18.4+ as well as Android',
        type: SettingType.boolean,
        defaultValue: null,
        property: InAppWebViewSettingsProperty.useOnShowFileChooser,
      ),
      SettingDefinition(
        name: 'Use Should Intercept Request',
        description: 'Enable request interception events',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.useShouldInterceptRequest,
      ),
      SettingDefinition(
        name: 'Use Should Override URL Loading',
        description: 'Enable URL loading override events',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.useShouldOverrideUrlLoading,
      ),
      SettingDefinition(
        name: 'Use On Load Resource',
        description: 'Enable resource loading events',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.useOnLoadResource,
      ),
      SettingDefinition(
        name: 'Fraudulent Website Warning',
        description: 'Show warnings for suspected phishing/malware',
        type: SettingType.boolean,
        defaultValue: true,
        property:
            InAppWebViewSettingsProperty.isFraudulentWebsiteWarningEnabled,
      ),
      SettingDefinition(
        name: 'Safe Browsing',
        description: 'Enable Google Safe Browsing',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.safeBrowsingEnabled,
      ),
      SettingDefinition(
        name: 'Web Authentication Support',
        description:
            'How much passkey (WebAuthn) support to give web content (Android)',
        type: SettingType.enumeration,
        defaultValue: null,
        enumValues: _safeEnumValues(() => WebAuthenticationSupport.values),
        property: InAppWebViewSettingsProperty.webAuthenticationSupport,
      ),
      SettingDefinition(
        name: 'Lockdown Mode',
        description: 'Apply the system Lockdown Mode restrictions (iOS)',
        type: SettingType.boolean,
        defaultValue: null,
        property: InAppWebViewSettingsProperty.lockdownModeEnabled,
      ),
      SettingDefinition(
        name: 'Security Restriction Mode',
        description:
            'Trade JavaScript/rendering features against attack surface (iOS)',
        type: SettingType.enumeration,
        defaultValue: null,
        enumValues: _safeEnumValues(() => SecurityRestrictionMode.values),
        property: InAppWebViewSettingsProperty.securityRestrictionMode,
      ),
      SettingDefinition(
        name: 'HTTPS Navigation Policy',
        description:
            'What to do when an HTTPS upgrade fails — the one iOS setting that '
            'responds to setSettings on a live WebView',
        type: SettingType.enumeration,
        defaultValue: null,
        enumValues: _safeEnumValues(() => UpgradeToHTTPSPolicy.values),
        property: InAppWebViewSettingsProperty.preferredHTTPSNavigationPolicy,
      ),
    ],
    'Cache': [
      SettingDefinition(
        name: 'Cache Mode',
        description: 'Override the way the cache is used',
        type: SettingType.enumeration,
        defaultValue: CacheMode.LOAD_DEFAULT.toNativeValue(),
        enumValues: _safeEnumValues(() => CacheMode.values),
        property: InAppWebViewSettingsProperty.cacheMode,
      ),
    ],
    'Appearance': [
      SettingDefinition(
        name: 'Transparent Background',
        description: 'Make the WebView background transparent',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.transparentBackground,
      ),
      SettingDefinition(
        name: 'Vertical Scroll Bar',
        description: 'Show vertical scroll bar',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.verticalScrollBarEnabled,
      ),
      SettingDefinition(
        name: 'Horizontal Scroll Bar',
        description: 'Show horizontal scroll bar',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.horizontalScrollBarEnabled,
      ),
      SettingDefinition(
        name: 'Scrollbar Fading',
        description: 'Fade scrollbars when not scrolling',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.scrollbarFadingEnabled,
      ),
      SettingDefinition(
        name: 'Disable Vertical Scroll',
        description: 'Disable vertical scrolling',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.disableVerticalScroll,
      ),
      SettingDefinition(
        name: 'Disable Horizontal Scroll',
        description: 'Disable horizontal scrolling',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.disableHorizontalScroll,
      ),
      SettingDefinition(
        name: 'Disable Context Menu',
        description: 'Disable the long-press context menu',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.disableContextMenu,
      ),
    ],
    'Navigation': [
      SettingDefinition(
        name: 'Back/Forward Cache',
        description:
            'Keep pages alive for instant back/forward navigation (Android). '
            'There is no event for a BFCache eviction yet',
        type: SettingType.boolean,
        defaultValue: null,
        property: InAppWebViewSettingsProperty.backForwardCacheEnabled,
      ),
      SettingDefinition(
        name: 'Back/Forward Gestures',
        description: 'Enable swipe gestures for navigation',
        type: SettingType.boolean,
        defaultValue: true,
        property:
            InAppWebViewSettingsProperty.allowsBackForwardNavigationGestures,
      ),
    ],
    'Rendering': [
      SettingDefinition(
        name: 'Suppress Incremental Rendering',
        description: 'Wait until content is fully loaded before rendering',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.suppressesIncrementalRendering,
      ),
      SettingDefinition(
        name: 'Hardware Acceleration',
        description: 'Enable hardware acceleration',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.hardwareAcceleration,
      ),
      SettingDefinition(
        name: 'Hybrid Composition',
        description: 'Use Flutter Hybrid Composition',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.useHybridComposition,
      ),
    ],
    'Interaction': [
      SettingDefinition(
        name: 'Writing Tools',
        description: 'How much of the system Writing Tools UI to offer (iOS)',
        type: SettingType.enumeration,
        defaultValue: null,
        enumValues: _safeEnumValues(() => WritingToolsBehavior.values),
        property: InAppWebViewSettingsProperty.writingToolsBehavior,
      ),
      SettingDefinition(
        name: 'Link Preview',
        description: 'Show link previews on long press',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.allowsLinkPreview,
      ),
    ],
    'Storage': [
      SettingDefinition(
        name: 'Profile Name',
        description:
            'Which androidx profile this WebView uses — cookies, storage and '
            'geolocation all follow it (Android)',
        type: SettingType.string,
        defaultValue: '',
        property: InAppWebViewSettingsProperty.profileName,
      ),
      SettingDefinition(
        name: 'Third-Party Cookies',
        description: 'Allow third-party cookies',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.thirdPartyCookiesEnabled,
      ),
      SettingDefinition(
        name: 'DOM Storage',
        description: 'Enable DOM local storage',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.domStorageEnabled,
      ),
      SettingDefinition(
        name: 'Database',
        description: 'Enable database storage API',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.databaseEnabled,
      ),
    ],
    'APIs': [
      SettingDefinition(
        name: 'Payment Request API',
        description:
            'Let web content use the Payment Request API, e.g. Google Pay (Android)',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.paymentRequestEnabled,
      ),
      SettingDefinition(
        name: 'Attribution Registration',
        description:
            'Which side registers Attribution Reporting sources and triggers (Android)',
        type: SettingType.enumeration,
        defaultValue: null,
        enumValues: _safeEnumValues(
          () => AttributionRegistrationBehavior.values,
        ),
        property: InAppWebViewSettingsProperty.attributionRegistrationBehavior,
      ),
      SettingDefinition(
        name: 'Geolocation',
        description: 'Enable Geolocation API',
        type: SettingType.boolean,
        defaultValue: true,
        property: InAppWebViewSettingsProperty.geolocationEnabled,
      ),
    ],
    'Developer': [
      SettingDefinition(
        name: 'Inspectable',
        description: 'Allow Web Inspector/DevTools',
        type: SettingType.boolean,
        defaultValue: false,
        property: InAppWebViewSettingsProperty.isInspectable,
      ),
    ],
  };
}
