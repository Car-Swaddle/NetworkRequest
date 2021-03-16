//
//  File.swift
//  
//
//  Created by Kyle Kendall on 3/10/21.
//

import Foundation

extension Request {
    
    /// The method used to make network request
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
}
