//
//  DownloadStartRequest.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 17/04/22.
//

import Foundation
import WebKit

public class DownloadStartRequest: NSObject {
    var url: String
    var userAgent: String?
    var contentDisposition: String?
    var mimeType: String?
    var contentLength: Int64
    var suggestedFilename: String?
    var textEncodingName: String?
    /// `nil` below iOS 18.2, where `WKDownload` does not report it — distinct from `false`, which
    /// means WebKit actively said the download was not user-initiated.
    var isUserInitiated: Bool?
    /// `WKFrameInfo.toMap()` of `WKDownload.originatingFrame`, or `nil` below iOS 18.2.
    var originatingFrame: [String: Any?]?

    public init(url: String, userAgent: String?, contentDisposition: String?,
                mimeType: String?, contentLength: Int64,
                suggestedFilename: String?, textEncodingName: String?) {
        self.url = url
        self.userAgent = userAgent
        self.contentDisposition = contentDisposition
        self.mimeType = mimeType
        self.contentLength = contentLength
        self.suggestedFilename = suggestedFilename
        self.textEncodingName = textEncodingName
    }

    /// Fills in the iOS 18.2+ fields from the `WKDownload` that triggered the event.
    ///
    /// Deliberately a method on this type rather than inline at the call sites: `DownloadStartRequest`
    /// is built in **two** places — `download(_:decideDestinationUsing:suggestedFilename:...)` and
    /// `webView(_:navigationResponse:didBecome:)` — and a field populated in only one of them is a
    /// silent hole, not a compile error. One implementation means the two cannot drift.
    @available(iOS 18.2, *)
    @MainActor
    public func apply(download: WKDownload) {
        isUserInitiated = download.isUserInitiated
        originatingFrame = download.originatingFrame.toMap()
    }

    public func toMap () -> [String:Any?] {
        return [
            "url": url,
            "userAgent": userAgent,
            "contentDisposition": contentDisposition,
            "mimeType": mimeType,
            "contentLength": contentLength,
            "suggestedFilename": suggestedFilename,
            "textEncodingName": textEncodingName,
            "isUserInitiated": isUserInitiated,
            "originatingFrame": originatingFrame
        ]
    }
}
