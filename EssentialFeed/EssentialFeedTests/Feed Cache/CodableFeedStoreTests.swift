//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 22/09/2023.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
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
    
    func test_retrieveTwice_deliversEmptyTwiceOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        sut.retrieve { firstResult in
            switch firstResult {
            case .empty:
                sut.retrieve { secondResult in
                    switch secondResult {
                    case .empty:
                        break
                    default:
                        XCTFail("Expected empty result, but got \(secondResult) instead")
                    }
                }
            default:
                XCTFail("Expected empty result, but got \(firstResult) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> CodableFeedStore {
        let sut = CodableFeedStore()
        
        return sut
    }
    
}
