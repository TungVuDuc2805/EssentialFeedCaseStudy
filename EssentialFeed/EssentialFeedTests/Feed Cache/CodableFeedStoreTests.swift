//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 22/09/2023.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        cleanCacheArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cleanCacheArtifacts()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expectRetrieve(from: sut, completeWith: .empty)
    }
    
    func test_retrieveTwice_deliversEmptyTwiceOnEmptyCache() {
        let sut = makeSUT()
        expectRetrieveTwice(from: sut, completeWith: .empty)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let timestamp = Date()
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        
        insert(locals, timestamp, to: sut)
        
        expectRetrieve(from: sut, completeWith: .success(timestamp: timestamp, locals: locals))
    }
    
    func test_retrieveTwiceAfterInsertingToEmptyCache_deliversInsertedValuesTwice() {
        let sut = makeSUT()
        let timestamp = Date()
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        
        insert(locals, timestamp, to: sut)
                
        expectRetrieveTwice(from: sut, completeWith: .success(timestamp: timestamp, locals: locals))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let url = storeURL()
        let sut = makeSUT(url: url)
        
        try! "invalid data".write(to: url, atomically: false, encoding: .utf8)
        
        expectRetrieve(from: sut, completeWith: .failure(anyNSError()))
    }
    
    func test_retrieveTwice_deliversFailureTwiceOnRetrievalError() {
        let url = storeURL()
        let sut = makeSUT(url: url)
        
        try! "invalid data".write(to: url, atomically: false, encoding: .utf8)
        
        expectRetrieveTwice(from: sut, completeWith: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let url = storeURL()
        let sut = makeSUT(url: url)
        let timestamp1 = Date.distantPast
        let (_, locals1) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        let timestamp2 = Date.distantFuture
        let (_, locals2) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        XCTAssertNil(insert(locals1, timestamp1, to: sut))
        XCTAssertNil(insert(locals2, timestamp2, to: sut))

        expectRetrieve(from: sut, completeWith: .success(timestamp: timestamp2, locals: locals2))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(url: invalidURL)
        let timestamp = Date.distantPast
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        XCTAssertNotNil(insert(locals, timestamp, to: sut), "Expected cache insertion to fail with an error")
    }
    
    func test_delete_keepsTheCacheEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        XCTAssertNil(deleteCache(from: sut))
        expectRetrieve(from: sut, completeWith: .empty)
    }
    
    func test_deleteTwice_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        XCTAssertNil(deleteCache(from: sut))
        XCTAssertNil(deleteCache(from: sut))
        expectRetrieve(from: sut, completeWith: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        
        insert(locals, timestamp, to: sut)
        
        XCTAssertNil(deleteCache(from: sut))
        
        expectRetrieve(from: sut, completeWith: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noPermissionURL = FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
        let sut = makeSUT(url: noPermissionURL)
        
        XCTAssertNotNil(deleteCache(from: sut))
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
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
    // MARK: - Helpers
    private func makeSUT(url: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(url: url ?? storeURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
    
    private func storeURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cleanCacheArtifacts() {
        try? FileManager.default.removeItem(at: storeURL())
    }
    
}
