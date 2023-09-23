//
//  FeedCacheSpecs.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 23/09/2023.
//

import XCTest
import EssentialFeed

protocol FeedCacheSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieveTwice_deliversEmptyTwiceOnEmptyCache()
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues()
    func test_retrieveTwiceAfterInsertingToEmptyCache_deliversInsertedValuesTwice()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()


    func test_delete_keepsTheCacheEmptyOnEmptyCache()
    func test_deleteTwice_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieveTwice_deliversFailureTwiceOnRetrievalError()
}

protocol FailableInsertFeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
}

typealias CodableFeedStoreSpecs = FeedCacheSpecs & FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

extension FeedCacheSpecs where Self: XCTestCase {
    func expectRetrieve(from sut: FeedStore, completeWith expectedResult: RetrievalCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.empty, .empty):
                break
            case let (.success(receivedTimestamp, receivedLocals), .success(expectedTimestamp, expectedLocals)):
                XCTAssertEqual(expectedTimestamp, receivedTimestamp, file: file, line: line)
                XCTAssertEqual(expectedLocals, receivedLocals, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func expectRetrieveTwice(from sut: FeedStore, completeWith expectedResult: RetrievalCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expectRetrieve(from: sut, completeWith: expectedResult)
        expectRetrieve(from: sut, completeWith: expectedResult)
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for completion")
        
        var capturedError: Error?
        sut.deleteCachedFeed {
            capturedError = $0
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
        
        return capturedError
    }
    
    @discardableResult
    func insert(_ items: [LocalFeedImage], _ timestamp: Date, to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for completion")
        
        var capturedError: Error?
        sut.insert(items, timestamp) { error in
            capturedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        
        return capturedError
    }
}
