//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 03/10/2023.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            do {
                try ManagedFeed.find(in: context).map(context.delete)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ items: [LocalFeedImage], _ timestamp: Date, completion: @escaping InsertionCompletion) {
        performAsync { context in
            do {
                let cache = try ManagedFeed.uniqueInstance(in: context)
                cache.insert(timestamp, items, to: context)

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        performAsync { context in
            do {
                let result = try ManagedFeed.find(in: context)
                guard let cache = result else {
                    return completion(.empty)
                }
                
                let images = cache.feed.map { $0.toLocal }
                
                completion(.success(timestamp: cache.timestamp, locals: images))
            } catch {
                completion(.failure(error))
            }
            
            try? context.save()
        }
    }
    
}
