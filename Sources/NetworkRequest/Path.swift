//
//  Path.swift
//  Network
//
//  Created by Kyle Kendall on 9/14/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import Foundation


/// Simiplify path creation
public class Path {
    
    /// Error when creating a path
    ///
    /// - invalidPathArgument: the path is invalid
    /// - invalidOriginalPath: the original path is invalid
    public enum PathError: Error {
        case invalidPathArgument
        case invalidOriginalPath
    }
    
    public init(originalPath: String, pathArguments: [String: String]) throws {
        self.originalPath = originalPath
        self.pathArguments = pathArguments
        try validatePath()
        try updatePath()
    }
    
    /// The actual path that can be used to make a request.
    public private(set) var path: String = ""
    /// The original path provided to this `Path` instance.
    public private(set) var originalPath: String
    /// The arguments used in the path. Must correspond with `originalPath`
    public private(set) var pathArguments: [String: String]
    
    private func updatePath() throws {
        path = originalPath
        
        for pathArgument in pathArguments {
            let previousPath = path
            path = path.replacingOccurrences(of: "{\(pathArgument.key)}", with: pathArgument.value)
            if path == previousPath {
                throw PathError.invalidPathArgument
            }
        }
    }
    
    private func validatePath() throws {
        if originalPath == "" {
            throw PathError.invalidOriginalPath
        }
    }
    
}

