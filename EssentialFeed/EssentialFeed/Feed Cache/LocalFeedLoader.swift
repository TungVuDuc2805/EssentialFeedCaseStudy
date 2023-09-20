//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], completion: @escaping InsertionCompletion)
}

public class LocalFeedLoader {
    private let store: FeedStore
    
    public enum Error: Swift.Error {
        case deletionError
        case insertionError
    }
    
    public init(store: FeedStore) {
        self.store = store
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] deletionError in
            guard self != nil else { return }
            if deletionError == nil {
                self?.insert(items, completion)
            } else {
                completion(Error.deletionError)
            }
        }
    }
    
    private func insert(_ items: [FeedItem], _ completion: @escaping (Error?) -> Void) {
        store.insert(items) { [weak self] insertionError in
            guard self != nil else { return }
            if insertionError != nil {
                completion(Error.insertionError)
            } else {
                completion(nil)
            }
        }
    }
}
