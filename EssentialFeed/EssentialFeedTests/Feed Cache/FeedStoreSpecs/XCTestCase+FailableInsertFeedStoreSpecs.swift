//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 25/09/2023.
//

import XCTest
import EssentialFeed

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func expectInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timestamp = Date.distantPast
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        XCTAssertNotNil(insert(locals, timestamp, to: sut), "Expected cache insertion to fail with an error")
    }
    
    func expectInsertHasNoSideEffectsInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timestamp = Date.distantPast
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        
        insert(locals, timestamp, to: sut)

        expectRetrieve(from: sut, completeWith: .empty)
    }
}
