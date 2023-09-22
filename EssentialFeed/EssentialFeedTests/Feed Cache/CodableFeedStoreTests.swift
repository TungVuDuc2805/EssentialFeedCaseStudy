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
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "wait for completion")
        sut.retrieve { result in
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
        let sut = CodableFeedStore()
        
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
    
}
