package dev.nosferatu500.inappwebview.chrome_custom_tabs

import dev.nosferatu500.inappwebview.InAppWebViewFlutterPlugin
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.lang.reflect.Modifier

/**
 * The lifecycle callbacks must reach the plugin only through the `plugin` property, which
 * `dispose()` nulls.
 *
 * The callbacks object is built in a property initializer, where a constructor parameter named
 * `plugin` is also in scope and wins over the property. Reading it there captured the non-null
 * parameter in a synthetic field, so after `dispose()` the callbacks still held the plugin and
 * would still close browsers through it. `onActivityResumed` itself needs a `FlutterActivity`,
 * which a plain JVM test can't construct, so this checks the reference instead.
 */
class NoHistoryCustomTabsActivityCallbacksTest {

  @Test
  fun `after dispose the lifecycle callbacks hold no reference to the plugin`() {
    val plugin = InAppWebViewFlutterPlugin()
    val callbacks = NoHistoryCustomTabsActivityCallbacks(plugin)

    callbacks.dispose()

    assertNull(callbacks.plugin)
    val anonymous = callbacks.activityLifecycleCallbacks
    val holders = anonymous.javaClass.declaredFields
      .filter { !Modifier.isStatic(it.modifiers) }
      .filter { field ->
        field.isAccessible = true
        field.get(anonymous) === plugin
      }
      .map { it.name }
    assertTrue("the callbacks still hold the plugin in $holders", holders.isEmpty())
  }
}
