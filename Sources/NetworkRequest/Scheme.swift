//
//  File.swift
//  
//
//  Created by Kyle Kendall on 3/10/21.
//

import Foundation


public extension Request {
    
    /// The scheme/protocol to make the network request
    enum Scheme {
        case http
        case https
        case websocket
        case none
        
        public var value: String? {
            switch self {
            case .http: return "http"
            case .https: return "https"
            case .websocket: return "ws"
            case .none: return nil
            }
        }
        
    }
    
}
