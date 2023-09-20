//
//  XCTestCase+Helpers.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import XCTest

extension XCTestCase {
    func anyNSError() -> NSError {
        NSError(domain: "test", code: 0)
    }
}
