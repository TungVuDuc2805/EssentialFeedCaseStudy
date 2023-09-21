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
        
        assert(sut, toCompleteLoadWith: .failure(anyNSError())) {
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
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalWith(anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalSuccessfullyWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNonExpirationCache() {
        let currentDate = Date()
        let nonExpirationDate = currentDate.toExpirationDate().adding(second: 1)
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        sut.load { _ in }
        store.completeRetrievalSuccessfully(with: locals, timestamp: nonExpirationDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpirationCache() {
        let currentDate = Date()
        let expirationDate = currentDate.toExpirationDate()
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        sut.load { _ in }
        store.completeRetrievalSuccessfully(with: locals, timestamp: expirationDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let currentDate = Date()
        let expiredDate = currentDate.toExpirationDate().adding(second: -1)
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        sut.load { _ in }
        store.completeRetrievalSuccessfully(with: locals, timestamp: expiredDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var capturedResult: LoadFeedResult?
        sut?.load {
            capturedResult = $0
        }
        
        sut = nil
        store.completeRetrievalWith(anyNSError())
        
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
    
    private func assert(_ sut: LocalFeedLoader, toCompleteLoadWith expectedResult: LoadFeedResult, file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
        let exp = expectation(description: "wait for completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
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
    
}
