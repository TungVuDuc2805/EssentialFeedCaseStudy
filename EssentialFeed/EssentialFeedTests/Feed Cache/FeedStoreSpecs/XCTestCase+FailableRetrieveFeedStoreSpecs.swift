//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 25/09/2023.
//

import XCTest
import EssentialFeed

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieveTwice_deliversFailureTwiceOnRetrievalError()
}

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func expectRetrieveDeliversFailureOnRetrieveError(on sut: FeedStore, url: URL, file: StaticString = #filePath, line: UInt = #line) {
        
        try! "invalid data".write(to: url, atomically: false, encoding: .utf8)
        
        expectRetrieve(from: sut, completeWith: .failure(anyNSError()), file: file, line: line)
    }
    
    func expectRetrieveDeliversFailureTwiceOnRetrieveError(on sut: FeedStore, url: URL, file: StaticString = #filePath, line: UInt = #line) {
        
        try! "invalid data".write(to: url, atomically: false, encoding: .utf8)
        
        expectRetrieve(from: sut, completeWith: .failure(anyNSError()), file: file, line: line)
    }
}
