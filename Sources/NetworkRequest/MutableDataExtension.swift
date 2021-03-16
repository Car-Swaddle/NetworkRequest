//
//  File.swift
//  
//
//  Created by Kyle Kendall on 3/10/21.
//

import Foundation


public extension NSMutableData {
    
    struct EncodingError: Error {
        public static let error = EncodingError()
    }
    
    func appendEncodedString(_ string: String) throws {
        guard let data = string.data(using: .utf8, allowLossyConversion: true) else { throw EncodingError.error }
        append(data)
    }
    
}
