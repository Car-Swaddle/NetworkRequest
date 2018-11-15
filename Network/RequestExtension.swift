//
//  RequestExtension.swift
//  NetworkRequest
//
//  Created by Kyle Kendall on 9/17/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation

public extension NetworkRequest.Request {
    
    public struct Endpoint {
        public var rawValue: String
        public init(rawValue: String) {
            if rawValue.first != "/" {
                print("Endpoints must start with `/`")
            }
            self.rawValue = rawValue
        }
    }
    
    /// Create a url session data task to make a network call.
    ///
    /// - Parameters:
    ///   - endpoint: Endpoint to hit
    ///   - queryItems: queryItems used to specify resource
    ///   - completion: closure called when request returns
    /// - Returns: Data task used to make request
    public func get(with endpoint: Endpoint, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, contentType: ContentType = .applicationJSON) -> URLRequest? {
        return self.get(withPath: endpoint.rawValue, queryItems: queryItems, scheme: scheme, contentType: contentType)
    }
    
    /// Make more convenient for dictionary instead of Data for `body`
    ///
    /// - Parameters:
    ///   - endpoint: Endpoint to hit
    ///   - queryItems: queryItems used to specify resource
    ///   - body: POST body
    ///   - completion: closure called when request returns
    /// - Returns: Task used to make network request
    public func put(with endpoint: Endpoint, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, body: Data, contentType: ContentType = .applicationFormURLEncoded) -> URLRequest? {
        return self.put(withPath: endpoint.rawValue, queryItems: queryItems, scheme: scheme, body: body, contentType: contentType)
    }
    
    /// Make more convenient for dictionary instead of Data for `body`
    ///
    /// - Parameters:
    ///   - endpoint: Endpoint to hit
    ///   - queryItems: queryItems used to specify resource
    ///   - body: POST body
    ///   - completion: closure called when request returns
    /// - Returns: Task used to make network request
    public func patch(with endpoint: Endpoint, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, body: Data, contentType: ContentType = .applicationFormURLEncoded) -> URLRequest? {
        return self.patch(withPath: endpoint.rawValue, queryItems: queryItems, scheme: scheme, body: body, contentType: contentType)
    }
    
    public func delete(with endpoint: Endpoint, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, body: Data, contentType: ContentType = .applicationFormURLEncoded) -> URLRequest? {
        return self.delete(withPath: endpoint.rawValue, queryItems: queryItems, scheme: scheme, body: body, contentType: contentType)
    }
    
    /// Make more convenient for dictionary instead of Data for `body`
    ///
    /// - Parameters:
    ///   - endpoint: Endpoint to hit
    ///   - queryItems: queryItems used to specify resource
    ///   - body: POST body
    ///   - completion: closure called when request returns
    /// - Returns: Task used to make network request
    public func post(with endpoint: Endpoint, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil, body: Data, contentType: ContentType = .applicationFormURLEncoded) -> URLRequest? {
        return self.post(withPath: endpoint.rawValue, queryItems: queryItems, scheme: scheme, body: body, contentType: contentType)
    }
    
    /// Download a file from another server via network
    ///
    /// - Parameters:
    ///   - endpoint: Endpoint to hit
    ///   - queryItems: queryItems used to specify file specs
    ///   - completion: closure called on completion. Contains the filepath where the file was downloaded
    /// - Returns: Download task used to make request.
    public func download(with endpoint: Endpoint, queryItems: [URLQueryItem] = [], scheme: Scheme? = nil) -> URLRequest? {
        return self.download(withPath: endpoint.rawValue, queryItems: queryItems, scheme: scheme)
    }
    
}

