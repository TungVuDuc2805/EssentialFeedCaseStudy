//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    enum Messages: Equatable {
        case retrieve
        case deletion
        case insertion(items: [LocalFeedImage], timestamp: Date)
    }
    
    var messages = [Messages]()
    var deletionCompletions = [(Error?) -> Void]()
    var insertionCompletions = [(Error?) -> Void]()
    var retrievalCompletions = [RetrievalCompletion]()

    func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
        messages.append(.deletion)
        deletionCompletions.append(completion)
    }
    
    func completeDeletionWith(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [LocalFeedImage], _ timestamp: Date, completion: @escaping (Error?) -> Void) {
        messages.append(.insertion(items: items, timestamp: timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeInsertionWith(_ error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        messages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    
    func completeRetrievalWith(_ error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalSuccessfullyWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.empty)
    }
    
    func completeRetrievalSuccessfully(with locals: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success(timestamp: timestamp, locals: locals))
    }
}
