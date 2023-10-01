//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 01/10/2023.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    public init() {}
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ items: [LocalFeedImage], _ timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
}
