//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.messages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueFeedImage(), uniqueFeedImage()]
        
        sut.save(items) { _ in }

        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_doesNotRequestsCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueFeedImage(), uniqueFeedImage()]
        let deletionError = NSError(domain: "test", code: 0)
        
        sut.save(items) { _ in }
        store.completeDeletionWith(deletionError)

        XCTAssertEqual(store.messages, [.deletion])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestmapOnDeletionSuccessfully() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let (items, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.messages, [.deletion, .insertion(items: locals, timestamp: timestamp)])
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
    
    func test_save_doesNotDeliverResultAfterDeletionAndSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        let items = [uniqueFeedImage(), uniqueFeedImage()]
        let deletionError = NSError(domain: "test", code: 0)

        var capturedResult: LocalFeedLoader.Error?
        
        sut?.save(items) {
            capturedResult = $0
        }
        
        sut = nil
        store.completeDeletionWith(deletionError)

        XCTAssertNil(capturedResult)
    }
    
    func test_save_doesNotDeliverResultAfterInsertionAndSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        let items = [uniqueFeedImage(), uniqueFeedImage()]
        let insertionError = NSError(domain: "test", code: 0)

        var capturedResult: LocalFeedLoader.Error?
        
        sut?.save(items) {
            capturedResult = $0
        }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertionWith(insertionError)

        XCTAssertNil(capturedResult)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func assert(_ sut: LocalFeedLoader, toCompleteWith error: LocalFeedLoader.Error?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let items = [uniqueFeedImage(), uniqueFeedImage()]

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
    
    private func uniqueFeedImage(
        id: UUID = UUID(),
        description: String? = "any description",
        location: String? = "any location",
        image: URL = URL(string: "any-url")!
    ) -> FeedImage {
        return FeedImage(id: id, description: description, location: location, url: image)
    }
    
    private func uniqueItems(_ models: [FeedImage]) -> (models: [FeedImage], locals: [LocalFeedImage]) {
        let locals = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }

        return (models, locals)
    }
    
}
