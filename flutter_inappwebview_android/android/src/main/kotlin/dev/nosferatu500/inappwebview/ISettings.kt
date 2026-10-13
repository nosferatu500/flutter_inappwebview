package dev.nosferatu500.inappwebview

interface ISettings<T> {
  fun parse(settings: Map<String, Any?>): ISettings<T>

  // Mutable on purpose: getRealSettings() implementations build on the map toMap() returns.
  fun toMap(): MutableMap<String, Any?>

  fun getRealSettings(obj: T): MutableMap<String, Any?>
}
