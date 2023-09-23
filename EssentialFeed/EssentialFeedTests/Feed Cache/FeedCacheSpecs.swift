//
//  FeedCacheSpecs.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 23/09/2023.
//

import Foundation

protocol FeedCacheSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieveTwice_deliversEmptyTwiceOnEmptyCache()
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues()
    func test_retrieveTwiceAfterInsertingToEmptyCache_deliversInsertedValuesTwice()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()


    func test_delete_keepsTheCacheEmptyOnEmptyCache()
    func test_deleteTwice_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieveTwice_deliversFailureTwiceOnRetrievalError()
}

protocol FailableInsertFeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
}

typealias CodableFeedStoreSpecs = FeedCacheSpecs & FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
