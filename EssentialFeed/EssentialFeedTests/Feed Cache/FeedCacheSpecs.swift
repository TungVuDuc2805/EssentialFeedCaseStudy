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

    func test_delete_deliversNoErrorOnEmptyCache()
    func test_deleteTwice_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedCacheSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieveTwice_deliversFailureTwiceOnRetrievalError()
}

protocol FailableInsertFeedStoreSpecs: FeedCacheSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedCacheSpecs {
    func test_delete_deliversErrorOnDeletionError()
}

typealias CodableFeedStoreSpecs = FeedCacheSpecs & FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

extension FeedCacheSpecs where Self: XCTestCase {
    func expectRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expectRetrieve(from: sut, completeWith: .empty, file: file, line: line)
    }
    
    func expectRetrieveDeliversEmptyTwiceOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expectRetrieveTwice(from: sut, completeWith: .empty, file: file, line: line)
    }
    
    func expectRetrieveDeliversInsertedValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timestamp = Date()
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        
        insert(locals, timestamp, to: sut)
        
        expectRetrieve(from: sut, completeWith: .success(timestamp: timestamp, locals: locals), file: file, line: line)
    }
    
    func expectRetrieveDeliversInsertedTwiceValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timestamp = Date()
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        
        insert(locals, timestamp, to: sut)
        
        expectRetrieveTwice(from: sut, completeWith: .success(timestamp: timestamp, locals: locals), file: file, line: line)
    }
    
    func expectInsertionDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timestamp = Date()
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        XCTAssertNil(insert(locals, timestamp, to: sut), file: file, line: line)
    }
    
    func expectInsertionDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timestamp1 = Date.distantPast
        let (_, locals1) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        let timestamp2 = Date.distantFuture
        let (_, locals2) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        insert(locals1, timestamp1, to: sut)
        
        XCTAssertNil(insert(locals2, timestamp2, to: sut), file: file, line: line)
    }
    
    func expectInsertOverridesPreviouslyInsertedCacheOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timestamp1 = Date.distantPast
        let (_, locals1) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        let timestamp2 = Date.distantFuture
        let (_, locals2) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        insert(locals1, timestamp1, to: sut)
        insert(locals2, timestamp2, to: sut)

        expectRetrieve(from: sut, completeWith: .success(timestamp: timestamp2, locals: locals2), file: file, line: line)
    }
    
    func expectDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNil(deleteCache(from: sut), file: file, line: line)
    }
    
    func expectDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)
        
        expectRetrieve(from: sut, completeWith: .empty, file: file, line: line)
    }
    
    func expectDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timestamp = Date()
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        
        insert(locals, timestamp, to: sut)
        
        XCTAssertNil(deleteCache(from: sut), file: file, line: line)
    }
    
    func expectDeleteEmptiesCacheOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let timestamp = Date()
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        
        insert(locals, timestamp, to: sut)
        deleteCache(from: sut)
        
        expectRetrieve(from: sut, completeWith: .empty, file: file, line: line)
    }
    
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

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func expectDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotNil(deleteCache(from: sut), file: file, line: line)
    }
    
    func expectDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)
        expectRetrieve(from: sut, completeWith: .empty)
    }
}
