//
//  NetworkTests.swift
//  NetworkTests
//
//  Created by Kyle Kendall on 9/14/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import XCTest
@testable import NetworkRequest

class NetworkTests: XCTestCase {

    func testPerformanceExample() {
        do {
            let path = try Path(originalPath: "/api/profile-picture/{image}", pathArguments: ["image": "name"])
            XCTAssert(path.path != "", "Should have non empty path")
        } catch {
            XCTAssert(false, "Error with path ")
        }
        
    }
    
}
