package dev.nosferatu500.inappwebview.credential_database

import android.webkit.WebViewDatabase
import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import dev.nosferatu500.inappwebview.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CredentialDatabaseHandler(plugin: InAppWebViewFlutterPlugin) :
  ChannelDelegateImpl(MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME)) {

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = plugin

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    this.plugin?.let { init(it) }
    val database = credentialDatabase

    when (call.method) {
      "getAllAuthCredentials" -> {
        val allCredentials = mutableListOf<Map<String, Any?>>()
        if (database != null) {
          for (protectionSpace in database.protectionSpaceDao.getAll()) {
            val credentials = database.credentialDao
              .getAllByProtectionSpaceId(protectionSpace.id)
              .map { it.toMap() }
            allCredentials.add(
              hashMapOf(
                "protectionSpace" to protectionSpace.toMap(),
                "credentials" to credentials
              )
            )
          }
        }
        result.success(allCredentials)
      }

      "getHttpAuthCredentials" -> {
        val credentials = mutableListOf<Map<String, Any?>>()
        if (database != null) {
          val found = database.getHttpAuthCredentials(
            call.argument("host"),
            call.argument("protocol"),
            call.argument("realm"),
            call.argument("port")
          )
          for (credential in found) {
            credentials.add(credential.toMap())
          }
        }
        result.success(credentials)
      }

      "setHttpAuthCredential" -> {
        if (database != null) {
          database.setHttpAuthCredential(
            call.argument("host")!!,
            call.argument("protocol")!!,
            call.argument("realm"),
            call.argument("port")!!,
            call.argument("username"),
            call.argument("password")
          )
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "removeHttpAuthCredential" -> {
        if (database != null) {
          database.removeHttpAuthCredential(
            call.argument("host"),
            call.argument("protocol"),
            call.argument("realm"),
            call.argument("port"),
            call.argument("username"),
            call.argument("password")
          )
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "removeHttpAuthCredentials" -> {
        if (database != null) {
          database.removeHttpAuthCredentials(
            call.argument("host"),
            call.argument("protocol"),
            call.argument("realm"),
            call.argument("port")
          )
          result.success(true)
        } else {
          result.success(false)
        }
      }

      "clearAllAuthCredentials" -> {
        if (database != null) {
          database.clearAllAuthCredentials()
          this.plugin?.let {
            WebViewDatabase.getInstance(it.applicationContext).clearHttpAuthUsernamePassword()
          }
          result.success(true)
        } else {
          result.success(false)
        }
      }

      else -> result.notImplemented()
    }
  }

  override fun dispose() {
    super.dispose()
    plugin = null
    credentialDatabase = null
  }

  companion object {
    protected const val LOG_TAG = "CredentialDatabaseHandler"
    const val METHOD_CHANNEL_NAME =
      "dev.nosferatu500.inappwebview/inappwebview_credential_database"

    @JvmField
    var credentialDatabase: CredentialDatabase? = null

    @JvmStatic
    fun init(plugin: InAppWebViewFlutterPlugin) {
      if (credentialDatabase == null) {
        credentialDatabase = CredentialDatabase.getInstance(plugin.applicationContext)
      }
    }
  }
}
