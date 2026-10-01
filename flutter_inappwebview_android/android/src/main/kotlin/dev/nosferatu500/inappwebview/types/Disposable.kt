package dev.nosferatu500.inappwebview.types

// Several of the plugin's objects publish `this` from their constructor (a Pigeon handler, the
// activity-result listener list, the static manager registries), before construction completes.
// Safe here: everything it is published to is only ever reached from the platform/main-thread
// message loop, and these objects are also constructed on that thread, so no callback can
// interleave with the constructor. Restructuring to a two-phase init would change the lifecycle of
// a dozen classes for no real-world gain. The classes that do this point here. (The note lived in
// `ChannelDelegateImpl` until §217 deleted it with the per-WebView MethodChannel.)
interface Disposable {
  fun dispose()
}
