//
//  WebViewMessageHandler.swift
//  WebView
//
//  Created by Abzal Kobenov on 5/11/20.
//  Copyright © 2020 Azimut Labs. All rights reserved.
//

import WebKit

protocol WebViewMessageHandlerDelegate: class {
    func webViewMessageHandler(_ webViewMessageHandler: WebViewMessageHandler, didReceiveEventWithName name: String, body: [String: Any])
}

class WebViewMessageHandler: NSObject, WKScriptMessageHandler {
    let name = "iosCallbackHandler"

    weak var delegate: WebViewMessageHandlerDelegate?

    /**
        **WARNING**
        Post messages must contain event_type.
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == name else { return }

        guard
            let body = message.body as? [String: Any],
            let eventName = body["event_type"] as? String
        else {
            assertionFailure("NO EVENT TYPE")
            return
        }

        delegate?.webViewMessageHandler(self, didReceiveEventWithName: eventName, body: body)
    }
}
