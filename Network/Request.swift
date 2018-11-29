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
        public static let any = ContentType(rawValue: "*/*")
        
    }
    
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
    
    public func downloadTask(with request: URLRequest, completion: @escaping (_ data: URL?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        return urlSession.downloadTask(with: request) { data, urlResponse, error in
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

