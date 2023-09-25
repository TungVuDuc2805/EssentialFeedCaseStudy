//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 25/09/2023.
//

import XCTest
import EssentialFeed

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func expectDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotNil(deleteCache(from: sut), file: file, line: line)
    }
    
    func expectDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)
        expectRetrieve(from: sut, completeWith: .empty)
    }
}
