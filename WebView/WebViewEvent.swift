//
//  WebViewEvent.swift
//  WebView
//
//  Created by no on 5/17/20.
//  Copyright © 2020 kbtu. All rights reserved.
//

import Foundation

public enum WebViewEvent: String, Decodable {
    case filter
    case navigationBar = "nav_bar"
    case authorization
    
    var bodyType: WebViewEventBody.Type {
        switch self {
        case .filter:
            return FilterEventBody.self
        default:
            return WebViewEventBody.self
        }
    }
}

public class WebViewEventBody: Decodable {
    
}

public class FilterEventBody: WebViewEventBody {
    var open: Bool
    
    private enum CodingKeys: String, CodingKey {
        case open
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        open = try container.decode(Bool.self, forKey: .open)
          
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }
}


