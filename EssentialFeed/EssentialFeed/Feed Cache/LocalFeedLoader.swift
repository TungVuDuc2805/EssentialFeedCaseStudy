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
    
    public enum Error: Swift.Error {
        case deletionError
        case insertionError
        case retrievalError
    }
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedImage], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] deletionError in
            guard self != nil else { return }
            if deletionError == nil {
                self?.insert(items, completion)
            } else {
                completion(Error.deletionError)
            }
        }
    }
    
    private func insert(_ items: [FeedImage], _ completion: @escaping (Error?) -> Void) {
        store.insert(items.toLocals, currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            if insertionError != nil {
                completion(Error.insertionError)
            } else {
                completion(nil)
            }
        }
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        store.retrieve { result in
            switch result {
            case .failure:
                completion(.failure(Error.retrievalError))
            case .success:
                completion(.success([]))
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
