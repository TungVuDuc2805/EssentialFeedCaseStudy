//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 22/09/2023.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    struct CodableCache: Codable {
        let items: [CodableLocalFeedImage]
        let timestamp: Date
        
        init(items: [LocalFeedImage], timestamp: Date) {
            self.items = items.map {
                CodableLocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
            }
            self.timestamp = timestamp
        }
        
        struct CodableLocalFeedImage: Codable {
            let id: UUID
            let description: String?
            let location: String?
            let url: URL
        }
    }
    
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: url) else {
            completion(.empty)
            return
        }
        
        do {
            let cache = try JSONDecoder().decode(CodableCache.self, from: data)
            completion(.success(timestamp: cache.timestamp, locals: cache.items.map {
                LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
            }))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ items: [LocalFeedImage], _ timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let cache = CodableCache(items: items, timestamp: timestamp)
        let data = try! JSONEncoder().encode(cache)
        try! data.write(to: url)
        completion(nil)
    }
}

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
        let sut = makeSUT()
        
        try! "invalid data".write(to: storeURL(), atomically: false, encoding: .utf8)
        
        expectRetrieve(from: sut, completeWith: .failure(anyNSError()))
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(url: storeURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func expectRetrieve(from sut: CodableFeedStore, completeWith expectedResult: RetrievalCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func expectRetrieveTwice(from sut: CodableFeedStore, completeWith expectedResult: RetrievalCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expectRetrieve(from: sut, completeWith: expectedResult)
        expectRetrieve(from: sut, completeWith: expectedResult)
    }
    
    func insert(_ items: [LocalFeedImage], _ timestamp: Date, to sut: CodableFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        sut.insert(items, timestamp) { error in
            XCTAssertNil(error, file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
    
    private func storeURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cleanCacheArtifacts() {
        try? FileManager.default.removeItem(at: storeURL())
    }
    
}
