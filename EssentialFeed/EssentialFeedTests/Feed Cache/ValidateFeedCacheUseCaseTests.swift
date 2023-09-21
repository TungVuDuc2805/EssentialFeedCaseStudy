//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 21/09/2023.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.messages, [])
    }
    
    func test_validate_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrievalWith(anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieve, .deletion])
    }
    
    func test_validate_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrievalSuccessfullyWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validate_doesNotDeleteCacheOnNonExpirationCache() {
        let currentDate = Date()
        let nonExpirationDate = currentDate.toExpirationDate().adding(second: 1)
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        sut.validateCache()
        store.completeRetrievalSuccessfully(with: locals, timestamp: nonExpirationDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validate_deletesCacheOnExpirationCache() {
        let currentDate = Date()
        let expirationDate = currentDate.toExpirationDate()
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        sut.validateCache()
        store.completeRetrievalSuccessfully(with: locals, timestamp: expirationDate)
        
        XCTAssertEqual(store.messages, [.retrieve, .deletion])
    }
    
    func test_validate_deletesCacheOnExpiredCache() {
        let currentDate = Date()
        let expiredDate = currentDate.toExpirationDate().adding(second: -1)
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let (_, locals) = uniqueItems([uniqueFeedImage(), uniqueFeedImage()])

        sut.validateCache()
        store.completeRetrievalSuccessfully(with: locals, timestamp: expiredDate)
        
        XCTAssertEqual(store.messages, [.retrieve, .deletion])
    }
    
    func test_validate_doesNotDeleteCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        
        sut = nil
        store.completeRetrievalWith(anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
}
