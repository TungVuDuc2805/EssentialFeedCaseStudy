//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.messages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }

        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        assert(sut, toCompleteLoadWith: .failure(LocalFeedLoader.Error.retrievalError)) {
            store.completeRetrievalWith(anyNSError())
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        assert(sut, toCompleteLoadWith: .success([])) {
            store.completeRetrievalSuccessfullyWithEmptyCache()
        }
    }
    
    func test_load_deliversImagesOnNonExpirationCache() {
        let currentDate = Date()
        let nonExpirationDate = currentDate.toExpirationDate().adding(second: 1)
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let (items, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
                
        assert(sut, toCompleteLoadWith: .success(items)) {
            store.completeRetrievalSuccessfully(with: locals, timestamp: nonExpirationDate)
        }
    }
    
    func test_load_deliversNoImagesOnExpirationCache() {
        let currentDate = Date()
        let expirationDate = currentDate.toExpirationDate()
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
                
        assert(sut, toCompleteLoadWith: .success([])) {
            store.completeRetrievalSuccessfully(with: locals, timestamp: expirationDate)
        }
    }
    
    func test_load_deliversNoImagesOnExpiratedCache() {
        let currentDate = Date()
        let expirationDate = currentDate.toExpirationDate().adding(second: -1)
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])
                
        assert(sut, toCompleteLoadWith: .success([])) {
            store.completeRetrievalSuccessfully(with: locals, timestamp: expirationDate)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func assert(_ sut: LocalFeedLoader, toCompleteLoadWith expectedResult: LoadFeedResult, file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
        let exp = expectation(description: "wait for completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as LocalFeedLoader.Error), .failure(expectedError as LocalFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()

        wait(for: [exp], timeout: 0.1)
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

extension Date {
    private var expirationDate: Int {
        return 7
    }
    
    func toExpirationDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .day, value: -expirationDate, to: self)!
    }
    
    func adding(second: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .second, value: second, to: self)!
    }
}
