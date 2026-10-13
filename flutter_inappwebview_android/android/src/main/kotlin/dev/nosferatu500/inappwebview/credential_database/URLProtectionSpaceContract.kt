package dev.nosferatu500.inappwebview.credential_database

import android.provider.BaseColumns

object URLProtectionSpaceContract {
  /* Inner class that defines the table contents */
  object FeedEntry : BaseColumns {
    const val _ID = BaseColumns._ID
    const val TABLE_NAME = "protection_space"
    const val COLUMN_NAME_HOST = "host"
    const val COLUMN_NAME_PROTOCOL = "protocol"
    const val COLUMN_NAME_REALM = "realm"
    const val COLUMN_NAME_PORT = "port"
  }
}
