package dev.nosferatu500.inappwebview.types

class FindSession(var resultCount: Int, var highlightedResultIndex: Int) {
  var searchResultDisplayStyle: Int = 2 // matches NONE of iOS

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "resultCount" to resultCount,
    "highlightedResultIndex" to highlightedResultIndex,
    "searchResultDisplayStyle" to searchResultDisplayStyle
  )

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as FindSession
    if (resultCount != other.resultCount) return false
    if (highlightedResultIndex != other.highlightedResultIndex) return false
    return searchResultDisplayStyle == other.searchResultDisplayStyle
  }

  override fun hashCode(): Int {
    var result = resultCount
    result = 31 * result + highlightedResultIndex
    result = 31 * result + searchResultDisplayStyle
    return result
  }

  override fun toString(): String =
    "FindSession{resultCount=$resultCount, highlightedResultIndex=$highlightedResultIndex, " +
      "searchResultDisplayStyle=$searchResultDisplayStyle}"
}
