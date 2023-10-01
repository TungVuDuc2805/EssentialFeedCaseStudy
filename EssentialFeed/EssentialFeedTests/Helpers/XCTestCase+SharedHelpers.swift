//
//  XCTestCase+SharedHelpers.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated.Potential memory leaks.", file: file, line: line)
        }
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "test", code: 0)
    }
    
    func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
}
