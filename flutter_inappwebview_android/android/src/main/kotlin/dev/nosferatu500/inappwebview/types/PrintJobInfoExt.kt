package dev.nosferatu500.inappwebview.types

import android.print.PrintJobInfo

class PrintJobInfoExt {
  var state: Int = 0
  var copies: Int = 0
  var numberOfPages: Int? = null
  var creationTime: Long = 0
  var label: String = ""
  var printerId: String? = null
  var attributes: PrintAttributesExt? = null

  fun toMap(): MutableMap<String, Any?> = hashMapOf(
    "state" to state,
    "copies" to copies,
    "numberOfPages" to numberOfPages,
    "creationTime" to creationTime,
    "label" to label,
    "printer" to hashMapOf<String, Any?>("id" to printerId),
    "attributes" to attributes?.toMap()
  )

  companion object {
    @JvmStatic
    fun fromPrintJobInfo(info: PrintJobInfo?): PrintJobInfoExt? {
      if (info == null) {
        return null
      }
      val printJobInfoExt = PrintJobInfoExt()
      printJobInfoExt.state = info.state
      printJobInfoExt.copies = info.copies
      printJobInfoExt.numberOfPages = info.pages?.size
      printJobInfoExt.creationTime = info.creationTime
      printJobInfoExt.label = info.label.toString()
      printJobInfoExt.printerId = info.printerId?.localId
      printJobInfoExt.attributes = PrintAttributesExt.fromPrintAttributes(info.attributes)
      return printJobInfoExt
    }
  }
}
