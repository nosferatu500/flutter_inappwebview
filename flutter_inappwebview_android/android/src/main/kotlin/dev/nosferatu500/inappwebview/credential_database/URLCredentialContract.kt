package dev.nosferatu500.inappwebview.credential_database

import android.provider.BaseColumns

object URLCredentialContract {
  /* Inner class that defines the table contents */
  object FeedEntry : BaseColumns {
    const val _ID = BaseColumns._ID
    const val TABLE_NAME = "credential"
    const val COLUMN_NAME_USERNAME = "username"
    const val COLUMN_NAME_PASSWORD = "password"
    const val COLUMN_NAME_PROTECTION_SPACE_ID = "protection_space_id"
  }
}
