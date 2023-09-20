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
        
        assert(sut, toCompleteWith: .failure(LocalFeedLoader.Error.retrievalError)) {
            store.completeRetrievalWith(anyNSError())
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        assert(sut, toCompleteWith: .success([])) {
            store.completeRetrievalSuccessfully(with: [])
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
    
    private func assert(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LoadFeedResult, file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
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
    
}
