//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertionCachedFeedCallCount = 0
    var deletionCompletions = [(Error?) -> Void]()
    var insertionCompletions = [(Error?) -> Void]()

    func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletionWith(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        insertionCachedFeedCallCount += 1
        insertionCompletions.append(completion)
    }
    
    func completeInsertionWith(_ error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    enum Error: Swift.Error {
        case deletionError
        case insertionError
    }
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] deletionError in
            if deletionError == nil {
                self?.store.insert(items) { insertionError in
                    if insertionError != nil {
                        completion(Error.insertionError)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(Error.deletionError)
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }

        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestsCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = NSError(domain: "test", code: 0)
        
        sut.save(items) { _ in }
        store.completeDeletionWith(deletionError)

        XCTAssertEqual(store.insertionCachedFeedCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnDeletionSuccessfully() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertionCachedFeedCallCount, 1)
    }
    
    func test_save_deliversErrorOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = NSError(domain: "test", code: 0)
        
        assert(sut, toCompleteWith: .deletionError) {
            store.completeDeletionWith(deletionError)
        }
    }
    
    func test_save_deliversErrorOnCacheInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = NSError(domain: "test", code: 0)
        
        assert(sut, toCompleteWith: .insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertionWith(insertionError)
        }
    }
    
    func test_save_delviersNoErrorOnCacheInsertionSuccessfully() {
        let (sut, store) = makeSUT()
        
        assert(sut, toCompleteWith: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func assert(_ sut: LocalFeedLoader, toCompleteWith error: LocalFeedLoader.Error?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let items = [uniqueItem(), uniqueItem()]

        var capturedError: LocalFeedLoader.Error?
        let exp = expectation(description: "wait for completion")
        
        sut.save(items) {
            capturedError = $0
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(capturedError, error, file: file, line: line)
    }
    
    private func uniqueItem(
        id: UUID = UUID(),
        description: String? = "any description",
        location: String? = "any location",
        image: URL = URL(string: "any-url")!
    ) -> FeedItem {
        return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
    
}
