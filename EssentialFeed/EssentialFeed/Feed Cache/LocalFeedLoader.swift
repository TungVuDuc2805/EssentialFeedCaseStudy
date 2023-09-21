//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionError in
            guard self != nil else { return }
            if deletionError == nil {
                self?.insert(items, completion)
            } else {
                completion(deletionError)
            }
        }
    }
    
    private func insert(_ items: [FeedImage], _ completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocals, currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            if insertionError != nil {
                completion(insertionError)
            } else {
                completion(nil)
            }
        }
    }
}
 
extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .empty:
                completion(.success([]))
            case let .success(timestamp, locals):
                if FeedCachePolicy.validate(timestamp, with: currentDate()) {
                    completion(.success(locals.toModels))
                } else {
                    completion(.success([]))
                }
            }
        }
    }
    
}
  
extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                store.deleteCachedFeed { _ in }
            case .empty:
                break
            case let .success(timestamp, _):
                if !FeedCachePolicy.validate(timestamp, with: currentDate()) {
                    store.deleteCachedFeed { _ in }
                }
            }
        }
    }
}

extension Array where Element == FeedImage {
    var toLocals: [LocalFeedImage] {
        self.map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}


extension Array where Element == LocalFeedImage {
    var toModels: [FeedImage] {
        self.map {
            FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}
