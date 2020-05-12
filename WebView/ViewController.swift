//
//  ViewController.swift
//  WebView
//
//  Created by erumaru on 5/8/20.
//  Copyright © 2020 kbtu. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    lazy var webView: WebView = {
        let view = WebView(url: URL(string: "https://extrorse-semiconduc.000webhostapp.com")!)
        view.delegate = self
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.snp.makeConstraints() {
            $0.edges.equalToSuperview()
        }
    }


}

extension ViewController: WebViewDelegate {
    func onBackPressed(webView: WebView) {
        print("back")
    }
    
    func didReceive(webView: WebView, event: WebViewEvents, with body: [String : Any]) {
        print("\(event.rawValue) \(body)")
        switch event {
        default: break
        }
    }
    
    func shouldAuthorize(webView: WebView) {
        webView.addCookies(["token" : "token"]) {
            print("done")
        }
    }
}

