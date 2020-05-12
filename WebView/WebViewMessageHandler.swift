//
//  WebViewMessageHandler.swift
//  WebView
//
//  Created by erumaru on 5/11/20.
//  Copyright © 2020 kbtu. All rights reserved.
//

import Foundation
import WebKit

protocol WebViewMessageHandlerDelegate: class {
    func didReceive(message name: String, body: [String: Any])
}

class WebViewMessageHandler: NSObject, WKScriptMessageHandler {
    // MARK: - Variables
    let name = "iosCallbackHandler"
    weak var delegate: WebViewMessageHandlerDelegate?
    
    // MARK: - Methods
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            message.name == self.name,
            let body = message.body as? [String : Any],
            let eventName = body["event_type"] as? String
        else { return }
        
        delegate?.didReceive(message: eventName, body: body)
    }
}

