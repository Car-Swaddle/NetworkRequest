//
//  File.swift
//  
//
//  Created by Kyle Kendall on 3/10/21.
//

import Foundation



final public class MultipartFormBuilder {
    
    enum MultipartFormBuilderError: Error {
        case unableToCreateData
        case invalidFilePath
    }
    
    public static let defaultBoundary = "MultipartFormBuilderBoundary"
    public static let defaultParameterName = "image"
    
    private let marker = "--"
    private let endLine = "\r\n"
    
    public init(boundary: String = MultipartFormBuilder.defaultBoundary, parameterName: String = MultipartFormBuilder.defaultParameterName) {
        self.boundary = boundary
        self.parameterName = parameterName
    }
    
    public func configure(request: NSMutableURLRequest, withFileURL url: URL, contentType: String) throws {
        let data = try self.data(fromURL: url, contentType: contentType)
        
        let contentType = Request.ContentType.multipartFormContentType(boundary: boundary)
        
        request.setValue(contentType.rawValue, forHTTPHeaderField: Request.ContentType.headerKey)
        request.setValue(String(data.count), forHTTPHeaderField: Request.contentLengthHeaderKey)
        request.setValue("gzip, deflate", forHTTPHeaderField: "accept-encoding")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        request.httpBody = data
        request.httpShouldHandleCookies = false
    }
    
    public let boundary: String
    public let parameterName: String
    
    private var endBoundaryError: Error {
        return MultipartFormBuilderError.unableToCreateData
    }
    
    public func data(fromURL url: URL, contentType: String) throws -> Data {
        let fileData = try Data(contentsOf: url)
        
        let fileName = url.lastPathComponent
        let fullData = NSMutableData()
        
        try fullData.appendEncodedString(startLine)
        try fullData.appendEncodedString(contentDisposition(fileName: fileName))
        try fullData.appendEncodedString(contentTypeLine(contentType: contentType))
        fullData.append(fileData)
        try fullData.appendEncodedString(endLine)
        try fullData.appendEncodedString(endBoundary)
        
        return fullData as Data
    }
    
    private var startLine: String {
        return marker + boundary + endLine
    }
    
    private func contentDisposition(fileName: String) -> String {
        return "Content-Disposition: form-data; name=\"\(parameterName)\"; filename=\"\(fileName)\"\(endLine)"
    }
    
    private func contentTypeLine(contentType: String) -> String {
        return "Content-Type: \(contentType)\(endLine)\(endLine)"
    }
    
    private var endBoundary: String {
        return marker + boundary + marker + endLine
    }
    
}
