//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Tung Vu Duc on 20/09/2023.
//

import Foundation

public enum RetrievalResult {
    case success(timestamp: Date, locals: [LocalFeedImage])
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedImage], _ timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
