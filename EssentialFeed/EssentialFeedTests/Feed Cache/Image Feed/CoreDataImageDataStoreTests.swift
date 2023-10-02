//
//  CoreDataImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 03/10/2023.
//

import XCTest
import EssentialFeed

class CoreDataImageDataStoreTests: XCTestCase {
    
    func test_retrieve_deliversNotFoundOnEmptyCache() {
        let sut = makeSUT()
        
        var capturedError: CoreDataFeedStore.ImageDataStoreError?
        sut.retrieve(from: anyURL()) { result in
            switch result {
            case .failure(let error as CoreDataFeedStore.ImageDataStoreError?):
                capturedError = error
            default:
                break
            }
        }
        
        XCTAssertEqual(capturedError, .notFound)
    }
 
    // MARK: - Helpers
    private func makeSUT() -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut)
        return sut
    }
    
}
