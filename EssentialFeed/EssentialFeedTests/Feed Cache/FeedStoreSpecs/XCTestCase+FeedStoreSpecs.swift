//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 25/09/2023.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
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
    
    func expectStoreSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        var completions = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(anyUniqueItems().locals, Date()) { _ in
            completions.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completions.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 2")
        sut.insert(anyUniqueItems().locals, Date()) { _ in
            completions.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(completions, [op1, op2, op3])
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
