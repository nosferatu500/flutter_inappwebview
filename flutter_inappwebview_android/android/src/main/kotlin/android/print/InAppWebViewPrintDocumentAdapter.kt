// Deliberately in the android.print package: PrintDocumentAdapter.LayoutResultCallback and
// WriteResultCallback have package-private constructors, so a subclass of either can only be
// declared from inside android.print.
package android.print

import android.os.Bundle
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor

class InAppWebViewPrintDocumentAdapter(
  private val delegate: PrintDocumentAdapter,
  private val callback: PrintDocumentAdapterCallback?
) : PrintDocumentAdapter() {

  override fun onStart() {
    delegate.onStart()
    callback?.onStart()
  }

  override fun onLayout(
    oldAttributes: PrintAttributes?,
    newAttributes: PrintAttributes?,
    cancellationSignal: CancellationSignal?,
    layoutResultCallback: LayoutResultCallback,
    extras: Bundle?
  ) {
    delegate.onLayout(
      oldAttributes, newAttributes, cancellationSignal,
      object : LayoutResultCallback() {
        override fun onLayoutFinished(info: PrintDocumentInfo?, changed: Boolean) {
          layoutResultCallback.onLayoutFinished(info, changed)
          callback?.onLayoutFinished(info, changed)
        }

        override fun onLayoutFailed(error: CharSequence?) {
          layoutResultCallback.onLayoutFailed(error)
          callback?.onLayoutFailed(error)
        }

        override fun onLayoutCancelled() {
          layoutResultCallback.onLayoutCancelled()
          callback?.onLayoutCancelled()
        }
      },
      extras
    )

    callback?.onLayout(
      oldAttributes, newAttributes, cancellationSignal, layoutResultCallback, extras
    )
  }

  override fun onWrite(
    pages: Array<PageRange>?,
    destination: ParcelFileDescriptor?,
    cancellationSignal: CancellationSignal?,
    writeResultCallback: WriteResultCallback
  ) {
    delegate.onWrite(
      pages, destination, cancellationSignal,
      object : WriteResultCallback() {
        override fun onWriteFinished(pages: Array<PageRange>?) {
          writeResultCallback.onWriteFinished(pages)
          callback?.onWriteFinished(pages)
        }

        override fun onWriteFailed(error: CharSequence?) {
          writeResultCallback.onWriteFailed(error)
          callback?.onWriteFailed(error)
        }

        override fun onWriteCancelled() {
          writeResultCallback.onWriteCancelled()
          callback?.onWriteCancelled()
        }
      }
    )
    callback?.onWrite(pages, destination, cancellationSignal, writeResultCallback)
  }

  override fun onFinish() {
    delegate.onFinish()
    callback?.onFinish()
  }

  open class PrintDocumentAdapterCallback {
    open fun onStart() {
      /* do nothing - stub */
    }

    open fun onFinish() {
      /* do nothing - stub */
    }

    open fun onLayout(
      oldAttributes: PrintAttributes?,
      newAttributes: PrintAttributes?,
      cancellationSignal: CancellationSignal?,
      layoutResultCallback: LayoutResultCallback?,
      extras: Bundle?
    ) {
      /* do nothing - stub */
    }

    open fun onLayoutFinished(info: PrintDocumentInfo?, changed: Boolean) {
      /* do nothing - stub */
    }

    open fun onLayoutFailed(error: CharSequence?) {
      /* do nothing - stub */
    }

    open fun onLayoutCancelled() {
      /* do nothing - stub */
    }

    open fun onWrite(
      pages: Array<PageRange>?,
      destination: ParcelFileDescriptor?,
      cancellationSignal: CancellationSignal?,
      writeResultCallback: WriteResultCallback?
    ) {
      /* do nothing - stub */
    }

    open fun onWriteFinished(pages: Array<PageRange>?) {
      /* do nothing - stub */
    }

    open fun onWriteFailed(error: CharSequence?) {
      /* do nothing - stub */
    }

    open fun onWriteCancelled() {
      /* do nothing - stub */
    }
  }
}
