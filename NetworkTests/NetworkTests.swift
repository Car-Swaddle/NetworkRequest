//
//  NetworkTests.swift
//  NetworkTests
//
//  Created by Kyle Kendall on 9/14/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import NetworkRequest

private let domain = "carswaddle.com"

public let serviceRequest: Request = {
    let request = Request(domain: domain)
    request.port = 3000
    request.timeout = 15
    request.defaultScheme = .http
    return request
}()

class NetworkTests: XCTestCase {

    func testPerformanceExample() {
        do {
            let path = try Path(originalPath: "/api/profile-picture/{image}", pathArguments: ["image": "name"])
            XCTAssert(path.path != "", "Should have non empty path")
        } catch {
            XCTAssert(false, "Error with path ")
        }
        
    }
    
    func multipartFormRequest() {
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "png") else {
            XCTAssert(false, "Should have file: image.jpeg in test bundle")
            return
        }
        
        let request = serviceRequest.multipartFormDataPost(withPath: "/api/profile-picture")
        serviceRequest.uploadMultipartFormDataTask(with: request, fileURL: fileURL, contentType: <#T##String#>, completion: <#T##(Data?, HTTPURLResponse?, Error?) -> Void#>)
    }
    
}
