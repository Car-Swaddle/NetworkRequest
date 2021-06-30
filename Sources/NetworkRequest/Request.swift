//
//  Request.swift
//  Network
//
//  Created by Kyle Kendall on 9/14/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation
import UIKit
import Combine

public typealias DataTaskPublisher<ResponseType: Decodable> = Publishers.Decode<Publishers.MapKeyPath<URLSession.DataTaskPublisher, JSONDecoder.Input>, ResponseType, JSONDecoder>

/// Use this to make an HTTP request.
final public class Request {
    
    /// The domain used to make the http request.
    public private(set) var domain: String
    
    public var timeout: TimeInterval = 45
    public private(set) var urlSession = URLSession(configuration: URLSessionConfiguration.default)
    public var defaultScheme: Scheme = .https
    public var port: Int?
    public var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    
    enum RequestError: Error {
        case noData
    }
    
    public struct UnsuccessfulStatusCode: Error {
        public let statusCode: Int
        public let localizedDescription: String
    }
    
    
    /// Provide a domain on which all request will be based
    ///
    /// - Parameter domain: domain to base all requests.
    public init(domain: String) {
        self.domain = domain
    }
    
    
    public func dataTask<Response: Decodable>(with request: URLRequest, decoder: JSONDecoder = JSONDecoder(), completion: @escaping (_ response: Response?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return urlSession.dataTask(with: request) { [weak self] data, urlResponse, error in
            self?.complete(data: data, jsonDecoder: decoder, error: error, completion: completion)
        }
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
    
    private var multipartFormBuilder = MultipartFormBuilder(boundary: "XXX")
    
    public func uploadMultipartFormDataTask(with mutableRequest: NSMutableURLRequest, fileURL: URL, contentType: String, completion: @escaping (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        do {
            try multipartFormBuilder.configure(request: mutableRequest, withFileURL: fileURL, contentType: contentType)
        } catch { return nil }
        
        return urlSession.dataTask(with: mutableRequest as URLRequest) { data, urlResponse, error in
            completion(data, urlResponse as? HTTPURLResponse, error)
        }
    }
    
    // MARK: - Publisher
    
    public func dataTaskPublisher<Response: Decodable>(with request: URLRequest, jsonDecoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response, Error> {
        let value = urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Response.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
        return value
    }
    
    public func uploadMultipartFormPublisher(with mutableRequest: NSMutableURLRequest, fileURL: URL, contentType: String) -> URLSession.DataTaskPublisher? {
        do {
            try multipartFormBuilder.configure(request: mutableRequest, withFileURL: fileURL, contentType: contentType)
        } catch { return nil }
        
        return urlSession.dataTaskPublisher(for: mutableRequest as URLRequest)
    }

    // MARK: - HTTP
    
    /// Create a url session data task to make a network call.
    ///
    /// - Parameters:
    ///   - path: path to the resource(s) requested
    ///   - queryItems: queryItems used to specify resource
    ///   - completion: closure called when request returns
    /// - Returns: Data task used to make request
    public func get(withPath path: String, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, contentType: ContentType = .applicationJSON) -> URLRequest? {
        guard let url = self.url(with: path, queryItems: queryItems, scheme: scheme) else { return nil }
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
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
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
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
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
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
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.httpMethod = Method.post.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: ContentType.headerKey)
        request.httpBody = body
        
        return request
    }
    
    public func multipartFormDataPost(withPath path: String, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil) -> NSMutableURLRequest? {
        guard let url = self.url(with: path, queryItems: queryItems, scheme: scheme) else { return nil }
        let request = NSMutableURLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.httpMethod = Method.post.rawValue
        
        return request
    }
    
    public func delete(withPath path: String, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, body: Data?, contentType: ContentType = .applicationJSON) -> URLRequest? {
        guard let url = self.url(with: path, queryItems: queryItems, scheme: scheme) else { return nil }
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
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
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.httpMethod = Method.get.rawValue
        
        return request        
    }
    
    public func send<Response: Decodable>(urlRequest: URLRequest, jsonDecoder: JSONDecoder = JSONDecoder(), completion: @escaping (_ response: Response?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return send(urlRequest: urlRequest) { [weak self] data, error in
            self?.complete(data: data, jsonDecoder: jsonDecoder, error: error, completion: completion)
        }
    }
    
    public func send(urlRequest: URLRequest, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        return send(urlRequest: urlRequest) { data, response, error in
            guard let response = response else {
                completion(data, error)
                return
            }
            if response.statusCode >= 200 && response.statusCode < 300 {
                completion(data, error)
            } else {
                let statusCodeError = UnsuccessfulStatusCode(statusCode: response.statusCode, localizedDescription: "Error status code: \(response.statusCode)")
                completion(data, error ?? statusCodeError)
            }
        }
    }
    
    public func send(urlRequest: URLRequest, completion: @escaping (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = self.dataTask(with: urlRequest, completion: completion)
        task?.resume()
        return task
    }
    
    public func send<Response: Decodable>(with request: URLRequest, decoder: JSONDecoder = JSONDecoder(), completion: @escaping (_ response: Response?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = self.dataTask(with: request, decoder: decoder, completion: completion)
        task?.resume()
        return task
    }
    
    /// Sends a request to download a file from another server via network.
    /// `resume` will be called before returning from this method
    ///
    /// - Parameters:
    ///   - path: Path to the file to be downloaded
    ///   - queryItems: queryItems used to specify file specs
    ///   - completion: closure called on completion. Contains the filepath where the file was downloaded
    /// - Returns: Download task used to make request.
    public func download(urlRequest: URLRequest, completion: @escaping (_ url: URL?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        let task = self.downloadTask(with: urlRequest, completion: completion)
        task?.resume()
        return task
    }
    
    public func download(urlRequest: URLRequest, completion: @escaping (_ url: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        return download(urlRequest: urlRequest) { url, response, error in
            guard let response = response else {
                completion(url, error)
                return
            }
            if response.statusCode >= 200 && response.statusCode < 300 {
                completion(url, error)
            } else {
                let statusCodeError = UnsuccessfulStatusCode(statusCode: response.statusCode, localizedDescription: "Error status code: \(response.statusCode)")
                completion(url, error ?? statusCodeError)
            }
        }
    }
    
    
    public func upload(urlRequest: URLRequest, fileURL: URL, completion: @escaping (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionUploadTask? {
        let task = self.uploadTask(with: urlRequest, file: fileURL, completion: completion)
        task?.resume()
        return task
    }
    
    public func uploadMultipartFormData(urlRequest: NSMutableURLRequest, fileURL: URL, contentType: String, completion: @escaping (_ data: Data?, _ response: HTTPURLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask? {
        let task = self.uploadMultipartFormDataTask(with: urlRequest, fileURL: fileURL, contentType: contentType, completion: completion)
        task?.resume()
        return task
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


extension Request: Hashable {
    
    public static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.timeout == rhs.timeout &&
            lhs.domain == rhs.domain &&
            lhs.urlSession == rhs.urlSession &&
            lhs.defaultScheme == rhs.defaultScheme &&
            lhs.port == rhs.port &&
            lhs.cachePolicy == rhs.cachePolicy
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(timeout)
        hasher.combine(domain)
        hasher.combine(urlSession)
        hasher.combine(defaultScheme)
        hasher.combine(port)
        hasher.combine(cachePolicy)
    }
    
}



extension Request {
    
    private func complete<Response: Decodable>(data: Data?, jsonDecoder: JSONDecoder, error: Error?, completion: (_ response: Response?, _ error: Error?) -> ()) {
        var response: Response?
        var error: Error? = error
        defer { completion(response, error) }
        
        guard let data = data else {
            error = error ?? RequestError.noData
            return
        }
        
        do {
            response = try jsonDecoder.decode(Response.self, from: data)
        } catch let decodeError {
            #if DEBUG
            print("ERROR: Error decoding response: \(decodeError). Check the Decodable \(Response.self)")
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("json: \(json)")
            }
            #endif
            
            error = error ?? decodeError
        }
    }
    
}
