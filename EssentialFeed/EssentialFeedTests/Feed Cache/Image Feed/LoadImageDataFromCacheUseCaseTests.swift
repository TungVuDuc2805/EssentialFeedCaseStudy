//
//  LoadImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 03/10/2023.
//

import XCTest
import EssentialFeed

class LoadImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, storeSpy) = makeSUT()
        
        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
    func test_loadImageFromURL_requestsStoreRetrieval() {
        let (sut, storeSpy) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(storeSpy.messages, [.retrieval(url)])
    }
    
    func test_loadImageFromURL_deliversErrorOnRetrievalError() {
        let (sut, storeSpy) = makeSUT()
        let retrievalError = anyNSError()
        
        var capturedError: Error?
        sut.loadImageData(from: anyURL()) { result in
            switch result {
            case .failure(let error):
                capturedError = error
            default:
                break
            }
        }
        
        storeSpy.completeRetrievalWith(retrievalError)
        
        XCTAssertEqual(capturedError as NSError?, retrievalError)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalImageDataLoader, storeSpy: ImageDataStoreSpy) {
        let storeSpy = ImageDataStoreSpy()
        let sut = LocalImageDataLoader(store: storeSpy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(storeSpy, file: file, line: line)
        
        return (sut, storeSpy)
    }
}
