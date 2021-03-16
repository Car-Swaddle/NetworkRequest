//
//  File.swift
//  
//
//  Created by Kyle Kendall on 3/10/21.
//

import Foundation

public extension Request {
    
    struct ContentType {
        public var rawValue: String
        
        public static let headerKey = "Content-Type"
        
        public static let applicationFormURLEncoded = ContentType(rawValue: "application/x-www-form-urlencoded")
        public static let applicationOctetStream = ContentType(rawValue: "application/octet-stream")
        public static let applicationJSON = ContentType(rawValue: "application/json")
        public static let applicationZIP = ContentType(rawValue: "application/zip")
        public static let imageJPEG = ContentType(rawValue: "image/jpeg")
        public static let imagePNG = ContentType(rawValue: "image/png")
        public static let textHTML = ContentType(rawValue: "text/html;charset=utf-8")
        public static let any = ContentType(rawValue: "*/*")
        
        public static func multipartFormContentType(boundary: String) -> ContentType {
            return ContentType(rawValue: "multipart/form-data; boundary=\(boundary)")
        }
        
    }
    
    static let contentLengthHeaderKey = "Content-Length"
    
}
