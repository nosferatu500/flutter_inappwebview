package dev.nosferatu500.inappwebview.credential_database

import android.content.ContentValues
import dev.nosferatu500.inappwebview.types.URLCredential

class URLCredentialDao(@JvmField var credentialDatabaseHelper: CredentialDatabaseHelper) {

  @JvmField
  var projection = arrayOf(
    URLCredentialContract.FeedEntry._ID,
    URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME,
    URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD,
    URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID
  )

  fun getAllByProtectionSpaceId(protectionSpaceId: Long?): MutableList<URLCredential> {
    val selection = URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " = ?"
    val selectionArgs = arrayOf(protectionSpaceId.toString())

    val cursor = credentialDatabaseHelper.readableDatabase.query(
      URLCredentialContract.FeedEntry.TABLE_NAME,
      projection,
      selection,
      selectionArgs,
      null,
      null,
      null
    )

    val urlCredentials = mutableListOf<URLCredential>()
    while (cursor.moveToNext()) {
      val id = cursor.getLong(
        cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry._ID)
      )
      val username = cursor.getString(
        cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME)
      )
      val password = cursor.getString(
        cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD)
      )
      urlCredentials.add(URLCredential(id, username, password, protectionSpaceId))
    }
    cursor.close()

    return urlCredentials
  }

  fun find(username: String?, password: String?, protectionSpaceId: Long?): URLCredential? {
    val selection = URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME + " = ? AND " +
      URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD + " = ? AND " +
      URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " = ?"
    val selectionArgs = arrayOf(username, password, protectionSpaceId.toString())

    val cursor = credentialDatabaseHelper.readableDatabase.query(
      URLCredentialContract.FeedEntry.TABLE_NAME,
      projection,
      selection,
      selectionArgs,
      null,
      null,
      null
    )

    var urlCredential: URLCredential? = null
    if (cursor.moveToNext()) {
      val rowId = cursor.getLong(
        cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry._ID)
      )
      val rowUsername = cursor.getString(
        cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME)
      )
      val rowPassword = cursor.getString(
        cursor.getColumnIndexOrThrow(URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD)
      )
      urlCredential = URLCredential(rowId, rowUsername, rowPassword, protectionSpaceId)
    }
    cursor.close()

    return urlCredential
  }

  fun insert(urlCredential: URLCredential): Long {
    val credentialValues = ContentValues()
    credentialValues.put(
      URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME, urlCredential.username
    )
    credentialValues.put(
      URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD, urlCredential.password
    )
    credentialValues.put(
      URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID,
      urlCredential.protectionSpaceId
    )

    return credentialDatabaseHelper.writableDatabase.insert(
      URLCredentialContract.FeedEntry.TABLE_NAME, null, credentialValues
    )
  }

  fun update(urlCredential: URLCredential): Long {
    val credentialValues = ContentValues()
    credentialValues.put(
      URLCredentialContract.FeedEntry.COLUMN_NAME_USERNAME, urlCredential.username
    )
    credentialValues.put(
      URLCredentialContract.FeedEntry.COLUMN_NAME_PASSWORD, urlCredential.password
    )

    val whereClause = URLCredentialContract.FeedEntry.COLUMN_NAME_PROTECTION_SPACE_ID + " = ?"
    val whereArgs = arrayOf(urlCredential.protectionSpaceId.toString())

    return credentialDatabaseHelper.writableDatabase.update(
      URLCredentialContract.FeedEntry.TABLE_NAME, credentialValues, whereClause, whereArgs
    ).toLong()
  }

  fun delete(urlCredential: URLCredential): Long {
    val whereClause = URLCredentialContract.FeedEntry._ID + " = ?"
    val whereArgs = arrayOf(urlCredential.id.toString())

    return credentialDatabaseHelper.writableDatabase.delete(
      URLCredentialContract.FeedEntry.TABLE_NAME, whereClause, whereArgs
    ).toLong()
  }
}
