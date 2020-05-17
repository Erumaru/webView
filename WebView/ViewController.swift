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
    func webView(_ webView: WebView, didReceiveEvent event: WebViewEvent, withBody body: WebViewEventBody) {
        switch event {
        case .filter:
            guard let body = body as? FilterEventBody else { return }
            
            print(body.open)
        default:
            break
        }
    }
}

