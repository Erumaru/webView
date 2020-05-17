//
//  WebView.swift
//  WebView
//
//  Created by Abzal Kobenov on 5/11/20.
//  Copyright © 2020 Azimut Labs. All rights reserved.
//

import WebKit

public protocol WebViewDelegate: class {
    func webView(_ webView: WebView, didReceiveEvent event: WebViewEvent, withBody body: WebViewEventBody)
}


private enum Constants {
    /**
        **NOTE**
        Scripts to remove some web features.
    */
    static let scripts = [
        "document.documentElement.style.webkitUserSelect='none';",
        "document.documentElement.style.webkitTouchCallout='none';",
        """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            var head = document.getElementsByTagName('head')[0];
            head.appendChild(meta);
        """
    ]
}

public class WebView: WKWebView {
    public weak var delegate: WebViewDelegate?

    /**
        **NOTE**
        Message handler is here to avoid self delegating.
     */
    private let messageHandler = WebViewMessageHandler()

    public init(url: URL) {
        let configurations = WKWebViewConfiguration()
        configurations.userContentController = WKUserContentController()

        super.init(frame: .zero, configuration: configurations)

        configureUserContentController()
        configureScrollView()

        load(URLRequest(url: url))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func configureUserContentController() {
        Constants.scripts.forEach {
            let script = WKUserScript(source: $0,
                                      injectionTime: .atDocumentStart,
                                      forMainFrameOnly: true)
            self.configuration.userContentController.addUserScript(script)
        }
        configuration.userContentController.add(messageHandler, name: messageHandler.name)
        messageHandler.delegate = self
    }

    private func configureScrollView() {
        contentMode = .scaleAspectFill
        contentScaleFactor = 1
        scrollView.clipsToBounds = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .normal
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }

    /**
        **WARNING**
        This initializer returns nil if the provided properties are invalid.
        To successfully create a cookie, you must provide values for (at least)
        the path, name, and value keys, and either the originURL key or the domain key.
     */
    public func addCookie(_ key: String, value: String, completion: (() -> Void)? = nil) {
        guard
            let host = url?.host,
            let cookie = HTTPCookie(properties: [
                .domain: host,
                .path: "/",
                .name: key,
                .value: value,
                .secure: "TRUE",
                .expires: "NO"
            ])
        else {
            assertionFailure("CAN'T ADD COOKIE")
            return
        }
        configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: completion)
    }

    public func addCookies(_ cookies: [String: String], completion: @escaping () -> Void) {
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

    deinit {
        self.configuration.userContentController.removeScriptMessageHandler(forName: self.messageHandler.name)
    }
}

extension WebView: WebViewMessageHandlerDelegate {
    /**
        **WARNING**
        You must add WebViewEvent case.
     */
    func webViewMessageHandler(_ webViewMessageHandler: WebViewMessageHandler, didReceiveEventWithName name: String, body: [String: Any]) {
        guard let event = WebViewEvent(rawValue: name) else {
            assertionFailure("UNKNOWN WEBVIEW EVENT: \(name)")
            return
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            let decoder = JSONDecoder()
            let body = try decoder.decode(event.bodyType, from: data)
            
            delegate?.webView(self, didReceiveEvent: event, withBody: body)
        } catch {
            print(error)
        }
    }
}
