package dev.nosferatu500.inappwebview.credential_database

import android.content.ContentValues
import dev.nosferatu500.inappwebview.types.URLProtectionSpace

class URLProtectionSpaceDao(@JvmField var credentialDatabaseHelper: CredentialDatabaseHelper) {

  @JvmField
  var projection = arrayOf(
    URLProtectionSpaceContract.FeedEntry._ID,
    URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST,
    URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL,
    URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM,
    URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT
  )

  fun getAll(): MutableList<URLProtectionSpace> {
    val cursor = credentialDatabaseHelper.readableDatabase.query(
      URLProtectionSpaceContract.FeedEntry.TABLE_NAME,
      projection,
      null,
      null,
      null,
      null,
      null
    )

    val urlProtectionSpaces = mutableListOf<URLProtectionSpace>()
    while (cursor.moveToNext()) {
      urlProtectionSpaces.add(readRow(cursor))
    }
    cursor.close()

    return urlProtectionSpaces
  }

  fun find(host: String?, protocol: String?, realm: String?, port: Int?): URLProtectionSpace? {
    val selection = URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST + " = ? AND " +
      URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL + " = ? AND " +
      URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM + " = ? AND " +
      URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT + " = ?"
    val selectionArgs = arrayOf(host, protocol, realm, port.toString())

    val cursor = credentialDatabaseHelper.readableDatabase.query(
      URLProtectionSpaceContract.FeedEntry.TABLE_NAME,
      projection,
      selection,
      selectionArgs,
      null,
      null,
      null
    )

    var urlProtectionSpace: URLProtectionSpace? = null
    if (cursor.moveToNext()) {
      urlProtectionSpace = readRow(cursor)
    }
    cursor.close()

    return urlProtectionSpace
  }

  private fun readRow(cursor: android.database.Cursor): URLProtectionSpace = URLProtectionSpace(
    cursor.getLong(cursor.getColumnIndexOrThrow(URLProtectionSpaceContract.FeedEntry._ID)),
    cursor.getString(
      cursor.getColumnIndexOrThrow(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST)
    ),
    cursor.getString(
      cursor.getColumnIndexOrThrow(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL)
    ),
    cursor.getString(
      cursor.getColumnIndexOrThrow(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM)
    ),
    cursor.getInt(
      cursor.getColumnIndexOrThrow(URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT)
    )
  )

  fun insert(urlProtectionSpace: URLProtectionSpace): Long {
    val protectionSpaceValues = ContentValues()
    protectionSpaceValues.put(
      URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_HOST, urlProtectionSpace.host
    )
    protectionSpaceValues.put(
      URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PROTOCOL, urlProtectionSpace.protocol
    )
    protectionSpaceValues.put(
      URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_REALM, urlProtectionSpace.realm
    )
    protectionSpaceValues.put(
      URLProtectionSpaceContract.FeedEntry.COLUMN_NAME_PORT, urlProtectionSpace.port
    )

    return credentialDatabaseHelper.writableDatabase.insert(
      URLProtectionSpaceContract.FeedEntry.TABLE_NAME, null, protectionSpaceValues
    )
  }

  fun delete(urlProtectionSpace: URLProtectionSpace): Long {
    val whereClause = URLProtectionSpaceContract.FeedEntry._ID + " = ?"
    val whereArgs = arrayOf(urlProtectionSpace.id.toString())

    return credentialDatabaseHelper.writableDatabase.delete(
      URLProtectionSpaceContract.FeedEntry.TABLE_NAME, whereClause, whereArgs
    ).toLong()
  }
}
