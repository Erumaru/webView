//
//  SexyWebView.swift
//  WebView
//
//  Created by erumaru on 5/11/20.
//  Copyright © 2020 kbtu. All rights reserved.
//

import Foundation
import WebKit

protocol WebViewDelegate: class {
    func didReceive(webView: WebView, event: WebViewEvents, with body: [String: Any])
    func onBackPressed(webView: WebView)
    func shouldAuthorize(webView: WebView)
}

extension WebViewDelegate {
    func didReceive(webView: WebView, event: WebViewEvents, with body: [String: Any]) {}
    func onBackPressed(webView: WebView) {}
    func shouldAuthorize(webView: WebView) {}
}

private enum WebViewInternalEvents: String {
    case navBar = "nav_bar"
    case authorization
}

enum WebViewEvents: String {
    case filter
}

class WebView: WKWebView {
    // MARK: - Variables
    private let _scripts = [
        "document.documentElement.style.webkitUserSelect='none';",
        "document.documentElement.style.webkitTouchCallout='none';",
        "var meta = document.createElement('meta'); meta.name = 'viewport'; meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; var head = document.getElementsByTagName('head')[0]; head.appendChild(meta);"
    ]
    weak var delegate: WebViewDelegate?
    
    // MARK: - Lifecycle
    init(url: URL, message handler: WebViewMessageHandler = .init()) {
        let controller = WKUserContentController()
        self._scripts.forEach {
            controller.addUserScript(.init(source: $0,
                                           injectionTime: .atDocumentEnd,
                                           forMainFrameOnly: true))
        }
        controller.add(handler, name: handler.name)
        let configurations = WKWebViewConfiguration()
        configurations.userContentController = controller
        
        super.init(frame: .zero, configuration: configurations)
        
        handler.delegate = self
        self.configureScrollView()
        
        self.load(.init(url: url))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func configureScrollView() {
        /*
            Make web view act more native.
         */
        scrollView.clipsToBounds = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        contentMode = .scaleAspectFill
        contentScaleFactor = 1
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .normal
    }
    
    func addCookie(_ key: String, value: String, completion: (() -> ())? = nil) {
        guard
            let url = self.url,
            let cookie = HTTPCookie(properties: [.domain: url.host!,
                                                 .path: "/",
                                                 .name: key,
                                                 .value: value,
                                                 .secure: "TRUE",
                                                 .expires: "NO"])
        else {
            assertionFailure("CAN'T ADD COOKIE")
            /*
             This initializer returns nil if the provided properties are invalid.
             To successfully create a cookie, you must provide values for (at least)
             the path, name, and value keys, and either the originURL key or the domain key.
             */
            return
        }
        configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: completion)
    }
    
    func addCookies(_ cookies: [String : String], completion: @escaping () -> ()) {
        let group = DispatchGroup()
        cookies.forEach {
            group.enter()
            self.addCookie($0, value: $1) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
}

extension WebView: WebViewMessageHandlerDelegate {
    func didReceive(message name: String, body: [String : Any]) {
        guard
            let event = WebViewEvents(rawValue: name)
        else {
            guard let internalEvent = WebViewInternalEvents(rawValue: name) else {
                assertionFailure("UNKNOWN WEBVIEW EVENT: \(name)")
                return
            }
            
            switch internalEvent {
            case .authorization:
                delegate?.shouldAuthorize(webView: self)
            case .navBar:
                delegate?.onBackPressed(webView: self)
            }
            
            return
        }
            
        delegate?.didReceive(webView: self, event: event, with: body)
    }
}
