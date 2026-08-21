package dev.nosferatu500.inappwebview.types

import android.annotation.SuppressLint
import android.content.Context

class AndroidResource(
  var name: String,
  var defType: String?,
  var defPackage: String?
) {

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "name" to name,
    "defType" to defType,
    "defPackage" to defPackage
  )

  // Resource reflection is the point of this type: the resource name/type/package arrive at
  // runtime from Dart (e.g. a custom menu icon named by the app), so they cannot be resolved to
  // an R constant at build time. Callers accept getIdentifier()'s 0-on-miss contract.
  @SuppressLint("DiscouragedApi")
  fun getIdentifier(ctx: Context): Int = ctx.resources.getIdentifier(name, defType, defPackage)

  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || javaClass != other.javaClass) return false

    other as AndroidResource
    if (name != other.name) return false
    if (defType != other.defType) return false
    return defPackage == other.defPackage
  }

  override fun hashCode(): Int {
    var result = name.hashCode()
    result = 31 * result + (defType?.hashCode() ?: 0)
    result = 31 * result + (defPackage?.hashCode() ?: 0)
    return result
  }

  override fun toString(): String =
    "AndroidResource{name='$name', type='$defType', defPackage='$defPackage'}"

  companion object {
    @JvmStatic
    fun fromMap(map: Map<String, Any?>?): AndroidResource? {
      if (map == null) {
        return null
      }
      val name = map["name"] as String
      val defType = map["defType"] as String?
      val defPackage = map["defPackage"] as String?
      return AndroidResource(name, defType, defPackage)
    }
  }
}
