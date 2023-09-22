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
        let cache = try! JSONDecoder().decode(CodableCache.self, from: data)
        
        completion(.success(timestamp: cache.timestamp, locals: cache.items.map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }))
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
        let exp = expectation(description: "wait for completion")
        makeSUT().retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let timestamp = Date()
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        
        let exp = expectation(description: "wait for completion")
        sut.insert(locals, timestamp) { insertionError in
            if let error = insertionError {
                XCTFail("Expected insertion successfully but got \(error) instead")
            } else {
                sut.retrieve { secondResult in
                    switch secondResult {
                    case let .success(receivedTimestamp, receivedLocals):
                        XCTAssertEqual(timestamp, receivedTimestamp)
                        XCTAssertEqual(receivedLocals, locals)
                    default:
                        XCTFail("Expected empty result, but got \(secondResult) instead")
                    }
                }
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(url: storeURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func storeURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cleanCacheArtifacts() {
        try? FileManager.default.removeItem(at: storeURL())
    }
    
}
