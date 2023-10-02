//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expectRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieveTwice_deliversEmptyTwiceOnEmptyCache() {
        let sut = makeSUT()

        expectRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()

        expectRetrieveDeliversInsertedValuesToEmptyCache(on: sut)
    }
    
    func test_retrieveTwiceAfterInsertingToEmptyCache_deliversInsertedValuesTwice() {
        let sut = makeSUT()

        expectRetrieveDeliversInsertedTwiceValuesToEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        expectInsertionDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        expectInsertionDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        expectInsertOverridesPreviouslyInsertedCacheOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        expectDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_deleteTwice_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expectDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    // MARK: - Helpers
    private func makeSUT() -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut)
        return sut
    }
    
}
