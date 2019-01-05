//
//  Request.swift
//  Network
//
//  Created by Kyle Kendall on 9/14/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
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


public extension Request {
    
    /// The scheme/protocol to make the network request
    public enum Scheme {
        case http
        case https
        case websocket
        case none
        
        var value: String? {
            switch self {
            case .http: return "http"
            case .https: return "https"
            case .websocket: return "ws"
            case .none: return nil
            }
        }
        
    }
    
}

public extension Request {
    
    struct ContentType {
        var rawValue: String
        
        public static let headerKey = "Content-Type"
        
        public static let applicationFormURLEncoded = ContentType(rawValue: "application/x-www-form-urlencoded")
        public static let applicationOctetStream = ContentType(rawValue: "application/octet-stream")
        public static let applicationJSON = ContentType(rawValue: "application/json")
        public static let applicationZIP = ContentType(rawValue: "application/zip")
        public static let imageJPEG = ContentType(rawValue: "image/jpeg")
        public static let imagePNG = ContentType(rawValue: "image/png")
        public static let textHTML = ContentType(rawValue: "text/html;charset=utf-8")
        public static let multipartFormData = ContentType(rawValue: "multipart/form-data")
        public static let any = ContentType(rawValue: "*/*")
        
        static func multipartFormContentType(boundary: String) -> ContentType {
            return ContentType(rawValue: "multipart/form-data; boundary=" + boundary)
        }
        
    }
    
    public static let contentLengthHeaderKey = "Content-Length"
    
}

/// Use this to make an HTTP request.
final public class Request {
    
    /// The domain used to make the http request.
    public private(set) var domain: String
    
    public var timeout: TimeInterval = 45
    public private(set) var urlSession = URLSession(configuration: URLSessionConfiguration.default)
    public var defaultScheme: Scheme = .https
    public var port: Int?
    
    
    /// Provide a domain on which all request will be based
    ///
    /// - Parameter domain: domain to base all requests.
    public init(domain: String) {
        self.domain = domain
    }
    
    public func dataTask(with request: URLRequest, completion: @escaping (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return urlSession.dataTask(with: request) { data, urlResponse, error in
            completion(data, urlResponse as? HTTPURLResponse, error)
        }
    }
    
    public func downloadTask(with request: URLRequest, completion: @escaping (_ url: URL?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        return urlSession.downloadTask(with: request) { data, urlResponse, error in
            completion(data, urlResponse as? HTTPURLResponse, error)
        }
    }
    
    public func uploadTask(with request: URLRequest, file: URL, completion: @escaping (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionUploadTask? {
        return urlSession.uploadTask(with: request, fromFile: file) { (data, urlResponse, error) in
            completion(data, urlResponse as? HTTPURLResponse, error)
        }
    }
    
    private var multipartFormBuilder = MultipartFormBuilder(boundary: "XXX", parameterName: "file")
    
    public func uploadMultipartFormDataTask(with mutableRequest: NSMutableURLRequest, fileURL: URL, completion: @escaping (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        do {
            try multipartFormBuilder.configure(request: mutableRequest, withFileURL: fileURL)
        } catch { return nil }
        
        return urlSession.dataTask(with: mutableRequest as URLRequest) { data, urlResponse, error in
            completion(data, urlResponse as? HTTPURLResponse, error)
        }
    }
    
    /// Create a url session data task to make a network call.
    ///
    /// - Parameters:
    ///   - path: path to the resource(s) requested
    ///   - queryItems: queryItems used to specify resource
    ///   - completion: closure called when request returns
    /// - Returns: Data task used to make request
    public func get(withPath path: String, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, contentType: ContentType = .applicationJSON) -> URLRequest? {
        guard let url = self.url(with: path, queryItems: queryItems, scheme: scheme) else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpMethod = Method.get.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: ContentType.headerKey)
        
        return request
    }
    
    /// Create a url session data task to make a PATCH network call.
    ///
    /// - Parameters:
    ///   - path: path to the resource(s) requested
    ///   - queryItems: queryItems used to specify resource
    ///   - completion: closure called when request returns
    /// - Returns: Data task used to make request
    public func patch(withPath path: String, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, body: Data?, contentType: ContentType = .applicationJSON) -> URLRequest? {
        guard let url = self.url(with: path, queryItems: queryItems, scheme: scheme) else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpMethod = Method.patch.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: ContentType.headerKey)
        request.httpBody = body
        
        return request
    }
    
    /// Create a url session data task to make a PATCH network call.
    ///
    /// - Parameters:
    ///   - path: path to the resource(s) requested
    ///   - queryItems: queryItems used to specify resource
    ///   - completion: closure called when request returns
    /// - Returns: Data task used to make request
    public func put(withPath path: String, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, body: Data?, contentType: ContentType = .applicationJSON) -> URLRequest? {
        guard let url = self.url(with: path, queryItems: queryItems, scheme: scheme) else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpMethod = Method.put.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: ContentType.headerKey)
        request.httpBody = body
        
        return request
    }
    
    
    /// Make more convenient for dictionary instead of Data for `body`
    ///
    /// - Parameters:
    ///   - path: path to the resource(s) requested
    ///   - queryItems: queryItems used to specify resource
    ///   - body: POST body
    ///   - completion: closure called when request returns
    /// - Returns: Task used to make network request
    public func post(withPath path: String, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, body: Data?, contentType: ContentType = .applicationJSON) -> URLRequest? {
        guard let url = self.url(with: path, queryItems: queryItems, scheme: scheme) else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpMethod = Method.post.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: ContentType.headerKey)
        request.httpBody = body
        
        return request
    }
    
    public func multipartFormDataPost(withPath path: String, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil) -> NSMutableURLRequest? {
        guard let url = self.url(with: path, queryItems: queryItems, scheme: scheme) else { return nil }
        let request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpMethod = Method.post.rawValue
        
        return request
    }
    
    public func delete(withPath path: String, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, body: Data?, contentType: ContentType = .applicationJSON) -> URLRequest? {
        guard let url = self.url(with: path, queryItems: queryItems, scheme: scheme) else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpMethod = Method.delete.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: ContentType.headerKey)
        request.httpBody = body
        
        return request
    }
    
    /// Download a file from another server via network
    ///
    /// - Parameters:
    ///   - path: Path to the file to be downloaded
    ///   - queryItems: queryItems used to specify file specs
    ///   - completion: closure called on completion. Contains the filepath where the file was downloaded
    /// - Returns: Download task used to make request.
    public func download(withPath path: String, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, contentType: ContentType = .applicationJSON) -> URLRequest? {
        guard let url = self.url(with: path, queryItems: queryItems, scheme: scheme) else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpMethod = Method.get.rawValue
        
        return request        
    }
    
    private func url(with path: String, queryItems: [URLQueryItem], scheme: Scheme? = nil) -> URL? {
        var components = URLComponents()
        components.host = domain
        components.path = path
        components.scheme = scheme?.value ?? self.defaultScheme.value
        if queryItems.count > 0 {
            components.queryItems = queryItems
        }
        components.port = self.port
        return components.url
    }
    
}




extension Request {
    
//    func multipartFormData(with data: Data, boundary: String, fileName: String) throws -> Data {
//        var fullData = NSMutableData()
//
//        // 1 - Boundary should start with --
//        let lineOne = "--" + boundary + "\r\n"
////        fullData.appendData(lineOne.dataUsingEncoding(
////            .utf8,
////            allowLossyConversion: false)!)
//        fullData.append(lineOne.data(using: .utf8))
//
//        // 2
//        let lineTwo = "Content-Disposition: form-data; name=\"image\"; filename=\"" + fileName + "\"\r\n"
//        NSLog(lineTwo)
//        fullData.appendData(lineTwo.dataUsingEncoding(
//            NSUTF8StringEncoding,
//            allowLossyConversion: false)!)
//
//        // 3
//        let lineThree = "Content-Type: image/jpg\r\n\r\n"
//        fullData.appendData(lineThree.dataUsingEncoding(
//            NSUTF8StringEncoding,
//            allowLossyConversion: false)!)
//
//        // 4
//        fullData.appendData(data)
//
//        // 5
//        let lineFive = "\r\n"
//        fullData.appendData(lineFive.dataUsingEncoding(
//            NSUTF8StringEncoding,
//            allowLossyConversion: false)!)
//
//        // 6 - The end. Notice -- at the start and at the end
//        let lineSix = "--" + boundary + "--\r\n"
//        fullData.appendData(lineSix.dataUsingEncoding(
//            NSUTF8StringEncoding,
//            allowLossyConversion: false)!)
//
//        return fullData as Data
//    }
    
}



final public class MultipartFormBuilder {
    
    enum MultipartFormBuilderError: Error {
        case unableToCreateData
    }
    
    public static let defaultBoundary = "MultipartFormBuilderBoundary"
    public static let defaultParameterName = "image"
    
    private let marker = "--"
    private let endLineMarker = "\r\n"
    
    public init(boundary: String = MultipartFormBuilder.defaultBoundary, parameterName: String = MultipartFormBuilder.defaultParameterName) {
        self.boundary = boundary
        self.parameterName = parameterName
    }
    
    public func configure(request: NSMutableURLRequest, withFileURL url: URL) throws {
        let data = try self.data(fromURL: url)
        
        let contentType = Request.ContentType.multipartFormContentType(boundary: boundary)
        
        request.setValue(contentType.rawValue, forHTTPHeaderField: Request.ContentType.headerKey)
        request.setValue(String(data.count), forHTTPHeaderField: Request.contentLengthHeaderKey)
        
        request.httpBody = data
        request.httpShouldHandleCookies = false
    }
    
    public let boundary: String
    public let parameterName: String
    
    public func data(fromURL url: URL) throws -> Data {
        
        let data = try Data(contentsOf: url)
        
        let fileExtension = url.pathExtension
        let fileName = url.lastPathComponent
        
        let fullData = NSMutableData()
        
        let lineOne = marker + boundary + endLineMarker
        guard let lineOneData = lineOne.data(using: .utf8) else {
            throw MultipartFormBuilderError.unableToCreateData
        }
        fullData.append(lineOneData)
        
        // 2
//        let lineTwo = "Content-Disposition: form-data; name=\"image\"; filename=\"" + fileName + "\"\r\n"
        let lineTwo = contentDisposition(fileName: fileName)
        guard let lineTwoData = lineTwo.data(using: .utf8) else {
            throw MultipartFormBuilderError.unableToCreateData
        }
//        NSLog(lineTwo)
        fullData.append(lineTwoData)
        
        // 3
//        let lineThree = "Content-Type: image/jpg\r\n\r\n"
        let lineThree = contentType(fileExtension: fileExtension)
        guard let lineThreeData = lineThree.data(using: .utf8) else {
            throw MultipartFormBuilderError.unableToCreateData
        }
        fullData.append(lineThreeData)
//        fullData.appendData(lineThree.dataUsingEncoding(
//            NSUTF8StringEncoding,
//            allowLossyConversion: false)!)
        
        // 4
        fullData.append(data)
        guard let endLineData = endLineMarker.data(using: .utf8) else {
            throw MultipartFormBuilderError.unableToCreateData
        }
        fullData.append(endLineData)
        
        
        // 5
//        let lineFive = "\r\n"
//        fullData.appendData(lineFive.dataUsingEncoding(
//            NSUTF8StringEncoding,
//            allowLossyConversion: false)!)
        
        // 6 - The end. Notice -- at the start and at the end
//        let lineSix = "--" + boundary + "--\r\n"
//        fullData.appendData(lineSix.dataUsingEncoding(
//            NSUTF8StringEncoding,
//            allowLossyConversion: false)!)
        guard let endBoundaryData = endBoundary().data(using: .utf8) else {
            throw MultipartFormBuilderError.unableToCreateData
        }
        fullData.append(endBoundaryData)
        
        return fullData as Data
    }
    
    private func contentDisposition(fileName: String) -> String {
        return "Content-Disposition: form-data; name=\"\(parameterName)\"; filename=\"\(fileName)\"\(endLineMarker)"
    }
    
    private func contentType(fileExtension: String) -> String {
        return "Content-Type: \(parameterName)/\(fileExtension)\(endLineMarker)"
    }
    
    private func endBoundary() -> String {
        return "\(marker)\(boundary)\(marker)\(endBoundary)"
    }
    
}

