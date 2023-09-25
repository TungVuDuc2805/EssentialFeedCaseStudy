//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 22/09/2023.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, CodableFeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        
        cleanCacheArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cleanCacheArtifacts()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        expectRetrieveDeliversEmptyOnEmptyCache(on: makeSUT())
    }
    
    func test_retrieveTwice_deliversEmptyTwiceOnEmptyCache() {
        expectRetrieveDeliversEmptyTwiceOnEmptyCache(on: makeSUT())
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        expectRetrieveDeliversInsertedValuesOnNonEmptyCache(on: makeSUT())
    }
    
    func test_retrieveTwiceAfterInsertingToEmptyCache_deliversInsertedValuesTwice() {
        expectRetrieveDeliversInsertedTwiceValuesOnNonEmptyCache(on: makeSUT())
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let url = storeURL()
        let sut = makeSUT(url: url)
        expectRetrieveDeliversFailureOnRetrieveError(on: sut, url: url)
    }
    
    func test_retrieveTwice_deliversFailureTwiceOnRetrievalError() {
        let url = storeURL()
        let sut = makeSUT(url: url)
        expectRetrieveDeliversFailureTwiceOnRetrieveError(on: sut, url: url)
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
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(url: invalidURL)
        expectInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(url: invalidURL)
        
        expectInsertHasNoSideEffectsInsertionError(on: sut)
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
        let sut = makeSUT()
        expectDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        expectDeleteEmptiesCacheOnNonEmptyCache(on: sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noPermissionURL = FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
        let sut = makeSUT(url: noPermissionURL)

        expectDeleteDeliversErrorOnDeletionError(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noPermissionURL = FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
        let sut = makeSUT(url: noPermissionURL)
        
        expectDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        expectStoreSideEffectsRunSerially(on: sut)
    }
    // MARK: - Helpers
    private func makeSUT(url: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(url: url ?? storeURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func storeURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cleanCacheArtifacts() {
        try? FileManager.default.removeItem(at: storeURL())
    }
    
}
