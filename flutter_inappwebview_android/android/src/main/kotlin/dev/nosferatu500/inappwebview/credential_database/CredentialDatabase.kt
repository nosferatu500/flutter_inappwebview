package dev.nosferatu500.inappwebview.credential_database

import android.content.Context
import dev.nosferatu500.inappwebview.types.URLCredential
import dev.nosferatu500.inappwebview.types.URLProtectionSpace

class CredentialDatabase private constructor(
  @JvmField var db: CredentialDatabaseHelper,
  @JvmField var protectionSpaceDao: URLProtectionSpaceDao,
  @JvmField var credentialDao: URLCredentialDao
) {

  fun getHttpAuthCredentials(
    host: String?,
    protocol: String?,
    realm: String?,
    port: Int?
  ): List<URLCredential> {
    val protectionSpace = protectionSpaceDao.find(host, protocol, realm, port)
      ?: return ArrayList()
    return credentialDao.getAllByProtectionSpaceId(protectionSpace.id)
  }

  fun clearAllAuthCredentials() {
    db.clearAllTables(db.writableDatabase)
  }

  fun removeHttpAuthCredentials(host: String?, protocol: String?, realm: String?, port: Int?) {
    protectionSpaceDao.find(host, protocol, realm, port)?.let { protectionSpaceDao.delete(it) }
  }

  fun removeHttpAuthCredential(
    host: String?,
    protocol: String?,
    realm: String?,
    port: Int?,
    username: String?,
    password: String?
  ) {
    val protectionSpace = protectionSpaceDao.find(host, protocol, realm, port) ?: return
    // Matches the Java: find() may return null and delete() dereferences it, so a missing
    // credential still throws rather than being ignored.
    credentialDao.delete(credentialDao.find(username, password, protectionSpace.id)!!)
  }

  fun setHttpAuthCredential(
    host: String,
    protocol: String,
    realm: String?,
    port: Int,
    username: String?,
    password: String?
  ) {
    val protectionSpace = protectionSpaceDao.find(host, protocol, realm, port)
    val protectionSpaceId = protectionSpace?.id
      ?: protectionSpaceDao.insert(URLProtectionSpace(null, host, protocol, realm, port))

    val credential = credentialDao.find(username, password, protectionSpaceId)
    if (credential != null) {
      var needUpdate = false
      if (credential.username != username) {
        credential.username = username
        needUpdate = true
      }
      if (credential.password != password) {
        credential.password = password
        needUpdate = true
      }
      if (needUpdate) {
        credentialDao.update(credential)
      }
    } else {
      val newCredential = URLCredential(null, username, password, protectionSpaceId)
      newCredential.id = credentialDao.insert(newCredential)
    }
  }

  companion object {
    const val LOG_TAG = "CredentialDatabase"

    // If you change the database schema, you must increment the database version.
    const val DATABASE_VERSION = 2
    const val DATABASE_NAME = "CredentialDatabase.db"

    private var instance: CredentialDatabase? = null

    @JvmStatic
    fun getInstance(context: Context): CredentialDatabase {
      instance?.let { return it }
      val db = CredentialDatabaseHelper(context)
      val created = CredentialDatabase(db, URLProtectionSpaceDao(db), URLCredentialDao(db))
      instance = created
      return created
    }
  }
}
